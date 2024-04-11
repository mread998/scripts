# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.17 Ensure SSH LoginGraceTime is set to one minute or less"
echo -e ${YELLOW} $benchmark ${NC}
LoginGraceTime="LoginGraceTime 60"
LoginGraceTimeCheck=`grep "^LoginGraceTime 60" /etc/ssh/sshd_config | wc -l`

if [ "$LoginGraceTimeCheck" == "0" ]
then
    echo -e "--->${RED}there are no LoginGraceTime entries in /etc/ssh/sshd_config ${NC}"
    echo "$LoginGraceTime" >> /etc/ssh/sshd_config
    echo -e "--->${GREEN}Updated /etc/ssh/sshd_config with MaxAutLoginGraceTimehTries entry ${NC}"
else
    echo -e "--->${GREEN}LoginGraceTime is already configured in /etc/ssh/sshd_config ${NC}"

fi






echo -e ${GREEN} $benchmark "is configured properly" ${NC}