# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.7 Ensure SSH MaxAuthTries is set to 4 or less" 
echo -e ${YELLOW} $benchmark ${NC}
MaxAuthTries="MaxAuthTries = 4"
MaxAuthTriesCheck=`grep "^MaxAuthTries = 4" /etc/ssh/sshd_config | wc -l`
if [ "$MaxAuthTriesCheck" == "0" ]
then 
    echo -e "--->${RED}there are no MaxAuthTries entries in /etc/ssh/sshd_config${NC}"
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 4/g' /etc/ssh/sshd_config
    echo -e "--->${GREEN}Updated /etc/ssh/sshd_config with MaxAuthTries entry${NC}"
    echo -e ${GREEN} $benchmark "is configured properly" ${NC}
else
    echo -e "--->${GREEN}MaxAuthTries is already configured in /etc/ssh/sshd_config${NC}"
    echo -e ${GREEN} $benchmark "is configured properly" ${NC}
fi