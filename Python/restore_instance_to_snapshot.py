#!/usr/bin/python

"""
Overview:
    Find volumes of a specific instance.
    Find snapshots for each volume on that instance.
        If no date filter, use latest (first in list).
        If date filter, apply.
            If more than 1 result, list and exit.
    For each volume, restore snapshot to volume.
    Stop instance.
    Detach existing volume(s).
    Attach restored volume(s).
    Start instance if told to.
Params:
    Region
    ID for EC2 instance
    Snapshot filter - use latest if no filter
        Date - limit discovered snapshots to YYYY-MM-DD
            Ex: 2021-04-22*
                2021-04-22*10:33*  (if more than one exists on 04-22)
        Tag - search for snapshots based on tag Key=Value
            Ex: Name=OHAZ2ALDAP-encrypted
    Start instance when finished
    Test mode - discover resources and print info, no actions taken.
    List Snapshots - discover snapshots, print out, exit
    Profile - which locally configured aws profile to use
Conditions:
    In list mode, discover resources according to params and filter and
        print out findings, then exit with success.
    In test mode, discover resources according to params and filter and
        simulate steps would take, then exit with success.
    In filter-by-tag mode, snapshot does not have to be linked to the
        volume currently attached to the instance.
    Return if volume attached is already from the snapshot detected,
        exit with success.

Based on original code from:
https://github.com/dwbelliston/aws_volume_encryption/blob/master/volume_encryption.py
"""

import sys
import boto3
import botocore     # Needed to handle botocore exceptions
import argparse
import time
from traceback import print_exc

def main(argv):
    parser = argparse.ArgumentParser(
             description='Reverts instance volume to previous snapshot.')
    # Order of args in code is order it appears on help output.
    # First list required cli args
    parser.add_argument('-i', '--instance',
                        help='Instance to restore volume on.',
                        required=True)
    parser.add_argument('-r', '--region',
                        help='Region of instance/volume',
                        required=True)
    # Followed by optional cli args
    parser.add_argument('--filter-date',
                        help='Limit snapshots to specific date. Use * for wildcard.',
                        default='*',
                        required=False)
    parser.add_argument('--filter-by-tag',
                        help='Discover snapshots by tag instead of volume link.',
                        action='append',
                        nargs="+",
                        type=str,
                        required=False)
    parser.add_argument('--profile',
                        help='Local profile to use',
                        required=False)
    parser.add_argument('--start',
                        help='Start instance with restored volumes.',
                        action='store_true',
                        required=False)
    parser.add_argument('--test',
                        help='Test mode, print out resources discovered.',
                        action='store_true',
                        required=False)
    parser.add_argument('--list',
                        help='List discovered snapshots and exit.',
                        action='store_true',
                        required=False)
    parser.add_argument('--force',
                        help='Do not check if volume is already from selected snapshot.',
                        action='store_true',
                        required=False)
    parser.add_argument('-k','--no-verify-ssl',
                        help='If corporate firewalls MitM TLS, skip cert verification',
                        action='store_true',
                        required=False)
    args = parser.parse_args()

    print('{} Beginning restore of {} on {}'
            .format(time.strftime("%X"),
                    args.instance.strip(),
                    time.strftime("%x")) )

    """ Set up AWS Session, client to access resources, and waiters. """
    if args.profile:
        print('{} Using profile {}'
                .format(time.strftime("%X"),args.profile))
        session = boto3.session.Session(profile_name=args.profile)
    else:
        session = boto3.session.Session()

    client = session.client('ec2',args.region,verify=not args.no_verify_ssl)
    ec2 = session.resource('ec2',args.region,verify=not args.no_verify_ssl)

    print('{} Getting caller identity'
            .format(time.strftime("%X")) )
    try:
        account = boto3.client('sts',verify=not args.no_verify_ssl).get_caller_identity()['Account']
        my_arn = boto3.client('sts',verify=not args.no_verify_ssl).get_caller_identity()['Arn']
        my_user = my_arn.split(':')[-1]
        account_metadata = boto3.client('iam',verify=not args.no_verify_ssl).list_account_aliases()
        my_account_name = account_metadata['AccountAliases'][0]
        print('{} In AWS Account {} ({}) as {} in {}'
                .format(time.strftime("%X"),account,my_account_name,my_user,args.region))
    except Exception as e:
        print('!!!Error getting AWS Account ID')
        print_exc()
        return 6

    waiter_instance_exists = client.get_waiter('instance_exists')
    waiter_instance_stopped = client.get_waiter('instance_stopped')
    waiter_instance_running = client.get_waiter('instance_running')
    waiter_volume_available = client.get_waiter('volume_available')

    """ Check instance exists """
    instance_id = args.instance.strip()
    print('{} Discovering resources on instance ({})'
            .format(time.strftime("%X"),instance_id))
    instance = ec2.Instance(instance_id)

    waiter_instance_exists.config.max_attempts = 1
    try:
        waiter_instance_exists.wait(
            InstanceIds=[
               instance_id,
            ]
        )
    except botocore.exceptions.WaiterError as e:
        sys.exit('ERROR: {}'.format(e))

    all_mappings = []
    block_device_mappings = instance.block_device_mappings

    # Save copy of mount mappings before starting
    for device_mapping in block_device_mappings:
        original_mappings = {
            'DeleteOnTermination': device_mapping['Ebs']['DeleteOnTermination'],
            'VolumeId': device_mapping['Ebs']['VolumeId'],
            'DeviceName': device_mapping['DeviceName'],
        }
        all_mappings.append(original_mappings)
        print('{} {} has {} mounted at {}'
              .format(time.strftime("%X"),
                      instance_id,
                      device_mapping['Ebs']['VolumeId'],
                      device_mapping['DeviceName']) )

    volume_data = []
    volumes = [v for v in instance.volumes.all()]

    for volume in volumes:
        current_volume_data = {}
        for mapping in all_mappings:
            if mapping['VolumeId'] == volume.volume_id:
                current_volume_data = {
                    'volume': volume,
                    'DeleteOnTermination': mapping['DeleteOnTermination'],
                    'DeviceName': mapping['DeviceName'],
                }

        print('{} Current volume\'s snapshot is {}'
                .format(time.strftime("%X"),volume.snapshot_id))

        """ Find snapshot(s) for this volume """
        snapshot_filter = [
            {
                'Name': 'owner-id',
                'Values': [
                    str(account)
                ]
            },
            # filter_date defaults to '*', but can be overridden on cli
            {
                'Name': 'start-time',
                'Values': [
                    str(args.filter_date)
                ]
            },
        ]
        # User requested to filter by tags instead of snapshots linked to
        # the current volume. It is a list, so loop through them, prepend
        # "tag:" if not present, and append to the snapshot_filter list.
        if args.filter_by_tag:
            for f in args.filter_by_tag:
                filter = f[0].split('=')
                filter_key = 'tag:'+filter[0] if not filter[0].startswith('tag:') else filter[0]
                snapshot_filter.append(
                    {
                        'Name': filter_key,
                        'Values': [ filter[1] ]
                    },
                )
        # Otherwise only search for snapshots linked to the current volume
        # attached to the instance.
        else:
            snapshot_filter.append(
                {
                    'Name': 'volume-id',
                    'Values': [
                            volume.id
                    ]
                },
            )
        # Using client lookup instead of using ec2 volume snapshots collection
        # because the collection has insufficient filtering.
        snapshot_lookup = client.describe_snapshots(Filters=snapshot_filter)

        if args.list:
            if len(snapshot_lookup['Snapshots']) == 0:
                print('!!! Zero snapshots found')
            for snap in snapshot_lookup['Snapshots']:
                print('{} Potential snapshot: {} {} {}'
                      .format(time.strftime("%X"),
                              current_volume_data['DeviceName'],
                              snap['SnapshotId'],
                              snap['StartTime']) )
            continue

        # If no snapshots found, exit with an error
        if not snapshot_lookup['Snapshots']:
            print('!!!Found no snapshots for {} volume {}'.format(instance_id,volume.id))
            return 1

        # A date filter was provided, but matched more than one snapshot.
        # Don't guess.  Exit with an error.
        if not args.filter_date == "*" and len(snapshot_lookup['Snapshots']) > 1:
            print('!!!Too many snapshots found, cowardly refusing to choose the wrong one')
            for snap in snapshot_lookup['Snapshots']:
                print('{} Potential {} at {}'
                      .format(time.strftime("%X"),snap['SnapshotId'],snap['StartTime']) )
            return 2

        # A tag filter was provided, but matched more than one snapshot.
        # Don't guess.  Exit with an error.
        if args.filter_by_tag and len(snapshot_lookup['Snapshots']) > 1:
            print('!!!Too many snapshots found with this tag, cowardly refusing to choose the wrong one')
            for snap in snapshot_lookup['Snapshots']:
                print('{} Potential {} of {} at {}'
                      .format(time.strftime("%X"),snap['SnapshotId'],snap['VolumeId'],snap['StartTime']) )
            return 2

        print('{} Found {} snapshot{}'
              .format(
                    time.strftime("%X"),
                    len(snapshot_lookup['Snapshots']),
                    's' if len(snapshot_lookup['Snapshots']) != 1 else '') )
        snapshot = ec2.Snapshot(snapshot_lookup['Snapshots'][0]['SnapshotId'])
        if args.force:
            print('{} Skipping sanity check if volume already from this snapshot'
                    .format(time.strftime("%X")) )
        else:
            if volume.snapshot_id == snapshot.snapshot_id:
                print('!!!Abort: {} already created from {}'
                      .format(volume.id,snapshot.snapshot_id) )
                return 5
            else:
                print('{} Selected snapshot passes sanity check'
                        .format( time.strftime("%X")) )

        print('{} Selected {} dated {}'
                .format(time.strftime("%X"), snapshot.snapshot_id, snapshot.start_time) )

        # Stop instance
        if args.test:
            print('{} Would stop {}'
                    .format(time.strftime("%X"),instance_id))
        else:
            # Exit if instance is pending, shutting-down (terminating), or terminated
            instance_exit_states = [0, 32, 48]
            if instance.state['Code'] in instance_exit_states:
                print('!!!ERROR: Instance is {} please make sure this instance is active'
                      .format(instance.state['Name']) )
                return 3

            # Validate successful shutdown if it is running or stopping
            if instance.state['Code'] in [16]:
                print('{} Stopping {}'
                        .format(time.strftime("%X"),instance_id))
                instance.stop()
            else:
                print('{} Instance {} is already stopped'
                        .format(time.strftime("%X"),instance_id))
            # wait on instance to be stopped
            try:
                print('{} Waiting for {} to stop'
                        .format(time.strftime("%X"),instance_id))
                waiter_instance_stopped.wait(
                    InstanceIds=[
                        instance_id,
                    ]
                )
            except botocore.exceptions.WaiterError as e:
                print('!!!ERROR: {}'.format(e))
                return 4

        # Fake volume object for test mode output
        class Vol:
            def __init__(self,vol_id):
                self.id=vol_id

        # Restore snapshot to volume
        if args.test:
            print('{} Would create {} volume from {}'
                  .format(time.strftime("%X"),volume.volume_type, snapshot.snapshot_id) )
            new_volume=Vol('vol-foorestore')
        else:
            print('{} Creating {} volume from {}'
                  .format(time.strftime("%X"),volume.volume_type, snapshot.snapshot_id) )
            if volume.volume_type == 'io1':
                new_volume = ec2.create_volume(
                    SnapshotId=snapshot.snapshot_id,
                    VolumeType=volume.volume_type,
                    Iops=volume.iops,
                    AvailabilityZone=instance.placement['AvailabilityZone']
                )
            else:
                new_volume = ec2.create_volume(
                    SnapshotId=snapshot.snapshot_id,
                    VolumeType=volume.volume_type,
                    AvailabilityZone=instance.placement['AvailabilityZone']
                )
            # wait on volume to be available
            print('{} Waiting on {} to be available'
                  .format(time.strftime("%X"),new_volume.id) )
            try:
                waiter_volume_available.wait(
                    VolumeIds=[
                        new_volume.id,
                    ],
                )
            except botocore.exceptions.WaiterError as e:
                new_volume.delete()
                print('!!!ERROR: {}'.format(e))

            ### # Add original tags to new volume
            if volume.tags:
                print('{} Adding previous tags to {}'
                      .format( time.strftime("%X"),new_volume.id) )
                new_volume.create_tags(Tags=volume.tags)

            volume_attributes = client.describe_volume_attribute(
                Attribute='autoEnableIO',
                VolumeId=volume.id,
            )
            if volume_attributes['AutoEnableIO']['Value']:
                print('{} Setting autoIO {} on {}'
                      .format(time.strftime("%X"),
                              volume_attributes['AutoEnableIO']['Value'],
                              new_volume.id) )
                client.modify_volume_attribute(
                    AutoEnableIO={
                        'Value': volume_attributes['AutoEnableIO']['Value']
                    },
                    VolumeId=new_volume.id,
                )

        # Detach volume from instance
        if args.test:
            print('{} Would detach {} from {} at {}'
                  .format(time.strftime("%X"),volume.id,instance_id,current_volume_data['DeviceName']) )
        else:
            print('{} Detaching {} from {} at {}'
                  .format(time.strftime("%X"),volume.id,instance_id,current_volume_data['DeviceName']) )
            instance.detach_volume(
                VolumeId=volume.id,
                Device=current_volume_data['DeviceName']
            )
            try:
                waiter_volume_available.wait(
                    VolumeIds=[
                        volume.id,
                    ],
                )
            except botocore.exceptions.WaiterError as e:
                print('!!!ERROR: current {} will not detach'
                      .format(volume.id) )
                print(e)
                return 8

        # Attach restored volume in its place
        if args.test:
            print('{} Would attach restored {} to {} at {}'
                  .format(time.strftime("%X"),new_volume.id,instance_id,current_volume_data['DeviceName']) )
        else:
            print('{} Attaching restored {} to {} at {}'
                  .format(time.strftime("%X"),new_volume.id,instance_id,current_volume_data['DeviceName']) )
            try:
                waiter_volume_available.wait(
                    VolumeIds=[
                        new_volume.id,
                    ],
                )
            except botocore.exceptions.WaiterError as e:
                print('!!!ERROR: new {} not available'
                      .format(new_volume.id) )
                print(e)
                return 8

            instance.attach_volume(
                VolumeId=new_volume.id,
                Device=current_volume_data['DeviceName']
            )
            volume_data.append(current_volume_data)

        for bdm in volume_data:
            # Modify instance attributes
            instance.modify_attribute(
                BlockDeviceMappings=[
                    {
                        'DeviceName': bdm['DeviceName'],
                        'Ebs': {
                            'DeleteOnTermination': bdm['DeleteOnTermination'],
                        },
                    },
                ],
            )

    # If just listing snapshots, exit cleanly
    if args.list:
        return 0

    # Start instance if requested
    if args.start:
        if args.test:
            print('{} Would start {}'
                    .format(time.strftime("%X"),instance_id) )
        else:
            print('{} Starting {}'
                    .format(time.strftime("%X"),instance_id) )
            instance.start()
            # wait on instance to start
            try:
                print('{} Waiting for {} to start'
                        .format(time.strftime("%X"),instance_id))
                waiter_instance_running.wait(
                    InstanceIds=[
                        instance_id,
                    ]
                )
            except botocore.exceptions.WaiterError as e:
                print('!!!ERROR: {}'.format(e))
                return 5
    # Clean up
    print('{} Fin!'
            .format( time.strftime("%X")) )


if __name__ == "__main__":
    retval = main(sys.argv[1:])
    sys.exit(retval)
