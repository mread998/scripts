#!/usr/bin/env bash

set -eu -o pipefail

SECRETNAME="<choose yoru secret"   # Name of secret in AWS Secrets Manager
SECRETFILE="$HOME/${SECRETNAME%.base64}" # Strip ".base64" from the secret name

# Test for presence of required tools
RETVAL=0
for TOOL in aws jq sed mktemp base64; do
  if ! which ${TOOL} >/dev/null; then
    echo "${TOOL} not found"
    RETVAL=$(($RETVAL + 1))
  fi
done
[ ${RETVAL} -ne 0 ] && exit ${RETVAL}

if [ -f ${SECRETFILE} ]; then
  echo "The ssh key ${SECRETFILE} already exists."
  echo "Cowardly refusing to overwrite it."
  exit 3
fi

KEYFILE=$(mktemp)

aws --no-verify-ssl secretsmanager get-secret-value \
	--secret-id "prod/${SECRETNAME}" \
	--region <choose your region> 2>/dev/null | \
  jq -r '.SecretString | fromjson."'${SECRETNAME}'" ' | \
  sed -e 's/ /\n/g' \
  > ${KEYFILE}

SIZE=$(stat -c %s ${KEYFILE})
if [ "${SIZE}" = "0" ]; then
  echo "Cannot obtain secret '${SECRETNAME}'"
  exit 4
fi

base64 -d ${KEYFILE} > ${SECRETFILE}

SIZE=$(stat -c %s ${SECRETFILE})
if [ "${SIZE}" = "0" ]; then
  echo "Did not properly extract ssh key from '${SECRETNAME}'"
  exit 5
fi

echo "Decrypted ssh key into ${SECRETFILE}"

rm ${KEYFILE}
