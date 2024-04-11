# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.1.3 Ensure permissions on /etc/cron.monthly are configured " 
owner=`stat -c %U /etc/cron.monthly | grep "root" | wc -l`
perms=`stat -c %A /etc/cron.monthly | grep "drwx------" | wc -l`
echo -e ${YELLOW} $benchmark ${NC}
if [ "owner" ==  "1" ]
then
    echo -e "---> ${GREEN}ownership on /etc/cron.monthly is configured${NC}"
else
    chown root:root /etc/cron.monthly
    echo -e "---> ${GREEN}Ownership has been updated to /etc/cron.monthly.${NC}"
fi

if [ "$perms" == "1" ]
then 
    echo -e "---> ${GREEN}Permissions on /etc/cron.monthly are configured${NC}"
else
    chmod og-rwx /etc/cron.monthly && echo -e "---> ${GREEN}permissions have been updated on /etc/cron.monthly${NC}"
fi

echo -e ${GREEN} $benchmark "is configured properly" ${NC}