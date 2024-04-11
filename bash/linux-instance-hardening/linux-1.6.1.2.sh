# # #!/bin/bash
# # This script addresses issues found in security scans.
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# NC='\033[0m'

# benchmark="1.6.1.2 Ensure the SELinux state is enforcing" 
# selinuxcheck=`grep "SELINUX=enforcing" /etc/selinux/config | wc -l`
# #selinux=[ permissive | disabled ]
# echo -e ${YELLOW} $benchmark ${NC}
# if [ "$selinuxcheck" ==  "0" ]
# then
#     sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config
#     sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
#     echo -e "---> ${GREEN}SELinux has been updated to enforcing mode.  Reboot is required.${NC}" 
#     echo -e ${GREEN} $benchmark "is configured properly" ${NC}
# else
#     echo "--->  ${GREEN}SELinux is in Enforcing mode${NC}"
#     echo -e ${GREEN} $benchmark "is configured properly" ${NC}
# fi
