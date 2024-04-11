# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.1.3 Ensure permissions on /etc/cron.weekly are configured " 
owner=`stat -c %U /etc/cron.weekly | grep "root" | wc -l`
perms=`stat -c %A /etc/cron.weekly | grep "drwx------" | wc -l`
echo -e ${YELLOW} $benchmark ${NC}
if [ "owner" ==  "1" ]
then
    echo -e "---> ${GREEN}ownership on /etc/cron.weekly is configured${NC}"
else
    chown root:root /etc/cron.weekly
    echo -e "---> ${GREEN}Ownership has been updated to /etc/cron.weekly.${NC}"
    echo -e ${GREEN} $benchmark "part 1 of 2 is configured properly" ${NC}
fi

if [ "$perms" == "1" ]
then 
    echo -e "---> ${GREEN}Permissions on /etc/cron.weekly are configured${NC}"
else
    chmod og-rwx /etc/cron.weekly && echo -e "---> ${GREEN}permissions have been updated on /etc/cron.weekly${NC}"
    echo -e ${GREEN} $benchmark "part 2 of 2 is configured properly" ${NC}
fi

