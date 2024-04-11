# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.15 Ensure that strong Key Exchange algorithms are used" 
echo -e ${YELLOW} $benchmark ${NC}
KexAlgorithms="KexAlgorithms diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512"

KexAlgorithmsCheck=`grep "^KexAlgorithms diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512" /etc/ssh/sshd_config | wc -l`
if [ "$KexAlgorithmsCheck" == "0" ]
then 
    echo -e "--->${RED}there are no KexAlgorithms entries in /etc/ssh/sshd_config${NC}"
    echo "$KexAlgorithms" >> /etc/ssh/sshd_config
    echo -e "--->  ${GREEN}Updated /etc/ssh/sshd_config with MaxAutKexAlgorithmshTries entry${NC}"
else
    echo -e "--->  ${GREEN}KexAlgorithms is already configured in /etc/ssh/sshd_config${NC}"

fi



echo -e ${GREEN} $benchmark "is configured properly" ${NC}