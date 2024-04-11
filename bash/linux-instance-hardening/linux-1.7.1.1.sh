#!/bin/bash
# This script addresses MOTD issues found in security scans.
# 1.7.1.1 Ensure message of the day is configured properly 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="1.6.1.2 Ensure the SELinux state is enforcing" 


# Deletes any entires in /etc/updat-motd.d if update-motd is bing used and leaves only a single.
rm -f /etc/update-motd.d/*
#purges if uing update-motd
echo "All activities performed on this system will be monitored." > /etc/update-motd.d/99-motd
# updates the default Amazon Linux 2 MOTD which is a symlink
echo "All activities performed on this system will be monitored." > /var/lib/update-motd/motd
echo -e "---> ${GREEN}Finished 1.7.1.1 Ensure message of the day is configured properly${NC}"