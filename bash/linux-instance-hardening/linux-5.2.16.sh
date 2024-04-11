# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.16 Ensure SSH Idle Timeout Interval is configured"
echo -e ${YELLOW} $benchmark ${NC}
ClientAliveInterval="ClientAliveInterval 300"
ClientAliveIntervalCheck=`grep "^ClientAliveInterval 0" /etc/ssh/sshd_config | wc -l`
ClientAliveCountMax="ClientAliveCountMax 3"
ClientAliveCountMaxCheck=`grep "^ClientAliveCountMax 3" /etc/ssh/sshd_config | wc -l`
echo "test"
 if [ "$ClientAliveIntervalCheck" == "1" ]
 then
    echo -e "--->${RED}The ClientAliveInterval entries in /etc/ssh/sshd_config are incorrect ${NC}"
    sed -i 's/ClientAliveInterval 0/ClientAliveInterval 300/g' /etc/ssh/sshd_config
    echo -e "${GREEN} Updated /etc/ssh/sshd_config with ClientAliveInterval entry ${NC}"
    echo -e ${GREEN} $benchmark "1 of 2 is configured properly" ${NC}
 else
     echo -e "${GREEN} ClientAliveInterval is already configured in /etc/ssh/sshd_config ${NC}"
     echo -e ${GREEN} $benchmark "1 of 2 is configured properly" ${NC}

 fi

 if [ "$ClientAliveCountMaxCheck" == "1"  ]
 then
    echo -e "--->${RED}The ClientAliveCountMax entries in /etc/ssh/sshd_config are incorrect${NC}"
    sed -i 's/ClientAliveCountMax 3/ClientAliveCountMax 0/g' /etc/ssh/sshd_config
    echo -e "${GREEN} Updated /etc/ssh/sshd_config with ClientAliveCountMax entry ${NC}"
    echo -e ${GREEN} $benchmark "2 of 2 is configured properly" ${NC}
 else
     echo -e " ${GREEN} ClientAliveCountMax is already configured in /etc/ssh/sshd_config ${NC}"
     echo -e ${GREEN} $benchmark "2 of 2 is configured properly" ${NC}

 fi



echo -e ${GREEN} $benchmark "is configured properly" ${NC}