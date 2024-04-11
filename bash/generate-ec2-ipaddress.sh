#!/usr/bin/env bash

set -e -u -o pipefail

S3_BUCKET=s3://<choose your bucket>

WORKDIR=$(mktemp -d)

cd $WORKDIR

DATE=$(date +%F)

for REGION in us-west-2 us-east-2; do
  aws ec2 describe-instances --output json --region ${REGION}  --query "Reservations[*].Instances[*].[Placement.AvailabilityZone, InstanceId, PrivateIpAddress, PublicIpAddress, [Tags[?Key=='Name'].Value] [0][0], [Tags[?Key=='ApplicationRole'].Value] [0][0]]"  | jq -r '["Avail Zone","Name","Instance ID","Private IP","Public IP","Application Role"], (.[][] | [ .[0], .[4], .[1], .[2], .[3], .[5]]) | @csv' | tr -d '"' | sort > ${DATE}_${REGION}_instance_ipaddress.csv
  aws s3 cp ${DATE}_${REGION}_instance_ipaddress.csv ${S3_BUCKET}/ec2-inventory/
done

cd /tmp
rm -rf ${WORKDIR}