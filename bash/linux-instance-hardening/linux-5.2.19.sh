# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.19 Ensure SSH warning banner is configured"
echo -e ${YELLOW} $benchmark ${NC}
Banner="Banner /etc/issue.net"
BannerCheck=`grep "^Banner /etc/issue.net" /etc/ssh/sshd_config | wc -l`

if [ "$BannerCheck" == "0" ]
then
    echo -e "--->${RED}there are no Banner entries in /etc/ssh/sshd_config ${NC}"
    echo "$Banner" >> /etc/ssh/sshd_config
    echo -e "--->${GREEN}Updated /etc/ssh/sshd_config with Banner entry ${NC}"
else
    echo -e "--->${GREEN}Banner is already configured in /etc/ssh/sshd_config ${NC}"

fi

echo -e ${GREEN} $benchmark "is configured properly" ${NC}