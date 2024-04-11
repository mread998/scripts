#!/usr/bin/env bash

set -e -u -o pipefail

S3_BUCKET=s3://<choose your bucket>

WORKDIR=$(mktemp -d)

cd $WORKDIR

DATE=$(date +%F)

for REGION in us-west-2 us-east-2; do
  aws ec2 describe-instances --output json --region ${REGION}  --query "Reservations[*].Instances[*].[Placement.AvailabilityZone, InstanceId, [Tags[?Key=='Name'].Value] [0][0], [Tags[?Key=='ApplicationRole'].Value] [0][0], [Tags[?Key=='BackupDailyKeepDays'].Value] [0][0], [Tags[?Key=='BackupWeeklyKeepDays'].Value] [0][0], [Tags[?Key=='BackupMonthlyKeepDays'].Value] [0][0], [Tags[?Key=='Owner'].Value] [0][0], [Tags[?Key=='Appliance'].Value] [0][0], [Tags[?Key=='SpecialInstructions'].Value] [0][0]]"  | jq -r '["Avail Zone","Name","Instance ID","Application Role","Daily Backups Kept","Weekly Backups Kept","Monthly Backups Kept","Owner","Appliance?","Special Instructions"], (.[][] | [ .[0], .[2], .[1], .[3], .[4], .[5], .[6], .[7], .[8], .[9], .[10]]) | @csv' | tr -d '"' | sort > ${DATE}_${REGION}_instances.csv
  aws s3 cp ${DATE}_${REGION}_instances.csv ${S3_BUCKET}/ec2-inventory/
done

cd /tmp
rm -rf ${WORKDIR}