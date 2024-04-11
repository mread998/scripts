# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.5 Ensure SSH LogLevel is appropriate" 
echo -e ${YELLOW} $benchmark ${NC}
loglevel="LogLevel = INFO"
loglevelcheck=`grep "^LogLevel" /etc/ssh/sshd_config | wc -l`
if [ "$loglevelcheck" == "0" ]
then 
    echo -e "---> ${RED}there are no loglevel entries in /etc/ssh/sshd_config${NC}"
    sed -i 's/#LogLevel INFO/LogLevel INFO/g' /etc/ssh/sshd_config
    echo -e "---> ${GREEN}Updated /etc/ssh/sshd_config with LogLevel entry${NC}"
    echo -e ${GREEN} $benchmark "is configured properly" ${NC}
else
    echo -e "---> ${GREEN}Loglevel is already configured${NC}"
    echo -e ${GREEN} $benchmark "is configured properly" ${NC}
fi