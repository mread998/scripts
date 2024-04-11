# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.1.3 Ensure permissions on /etc/cron.hourly are configured " 
owner=`stat -c %U /etc/cron.hourly | grep "root" | wc -l`
perms=`stat -c %A /etc/cron.hourly | grep "drwx------" | wc -l`
echo -e ${YELLOW} $benchmark ${NC}
if [ "owner" ==  "1" ]
then
    echo -e "---> ${GREEN}ownership on /etc/cron.hourly is configured${NC}"
else
    chown root:root /etc/cron.hourly
    echo -e "---> ${GREEN}Ownership has been updated to /etc/cron.hourly${NC}"
    echo -e ${GREEN} $benchmark "is configured properly" ${NC}
fi

if [ "$perms" == "1" ]
then 
    echo -e "---> ${GREEN}Permissions on /etc/cron.hourly are configured${NC}"
else
    chmod og-rwx /etc/cron.hourly 
    echo -e "---> ${GREEN}permissions have been updated on /etc/cron.hourly${NC}"
    echo -e ${GREEN} $benchmark "is configured properly" ${NC}
fi

