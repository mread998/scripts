#!/usr/bin/env bash

# Exit if any command exits with non-zero exit code (even in pipes)
set -eu -o pipefail

DATE=$(date +%F)
SUBDIR=server-certificate-history
OUTFILE=${DATE}_server-certificates.txt

# Switch to a role that can perform potentially sensitve AWS API calls
AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
OUTPUT=$(aws sts assume-role \
  --role-arn "arn:aws:iam::${AWS_ACCOUNT}:role/maintenance-role" \
  --role-session-name maintenance-$DATE)
export AWS_ACCESS_KEY_ID=$(echo $OUTPUT | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $OUTPUT | jq -r '.Credentials.SessionToken')

S3_BUCKET=s3://$(aws s3 ls | grep vaec-automation | head -n 1 | awk '{print $3}')
tmpfile=$(mktemp)


echo -e "Certificates metadata gathered on ${DATE}\n" > $tmpfile
aws iam list-server-certificates  | \
  jq --raw-output \
    '.ServerCertificateMetadataList[] |
         ["ServerCertificateName",.ServerCertificateName],
         ["Expiration           ",.Expiration],
         ["UploadDate           ",.UploadDate],
         [] |
       join(" : ")
    ' >> $tmpfile

# If first arg is --test, just print out results, not copy file to S3
if echo $@ | grep -q -- "--test"; then
  cat $tmpfile
else
  aws s3 cp --content-type text/plain \
    $tmpfile $S3_BUCKET/${SUBDIR}/${OUTFILE}
fi

# Clean up after yourself
rm $tmpfile

# vim: set bg=dark expandtab tw=80 sw=2 ts=2 sts=2 :
