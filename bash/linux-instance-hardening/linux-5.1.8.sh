# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.1.8 Ensure at/cron is restricted to authorized users" 
echo -e ${YELLOW} $benchmark ${NC}
crondeny=`ls /etc/cron.deny | wc -l`
atdeny=`ls /etc/at.deny | wc -l`
if [ "$crondeny" == "1" ]
then
    rm -f /etc/cron.deny
    touch /etc/cron.allow
    chown root.root /etc/cron.allow
    chmod og-rwx /etc/cron.allow
    echo -e "---> ${GREEN}/etc/cron.deny has been removed. /etc/cron.allow has been created and permissions updated.${NC}"
    echo -e ${GREEN} $benchmark "Part 1 of 2 is configured properly" ${NC}
else
    echo -e "---> ${GREEN}/etc/cron.deny does not exist${NC}"
    echo -e ${GREEN} $benchmark "Part 1 of 2 is configured properly" ${NC}
fi

if [ "$atdeny" == "1" ]
then
    rm -f /etc/at.deny 
    touch /etc/at.allow
    chown root.root /etc/at.allow
    chmod og-rwx /etc/at.allow
    echo -e "---> ${GREEN}/etc/at.deny has been removed. /etc/at.allow has been created and permissions updated.${NC}"
    echo -e ${GREEN} $benchmark "Part 2 of 2 is configured properly" ${NC}
else
    #rm /etc/cron.deny
    echo -e "---> ${GREEN}/etc/at.deny does not exist${NC}"
    echo -e ${GREEN} $benchmark "Part 2 of 2 is configured properly" ${NC}
fi

# Suggested commands
# remove cron allow and deny
# rm /etc/cron.deny
# rm /etc/at.deny
# touch /etc/cron.allow
# touch /etc/at.allow
# chmod og-rwx /etc/cron.allow
# chmod og-rwx /etc/at.allow
# chown root:root /etc/cron.allow
# chown root:root /etc/at.allow

# echo -e ${GREEN} $benchmark "is configured properly" ${NC}