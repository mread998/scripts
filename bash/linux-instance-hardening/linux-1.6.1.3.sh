# # #!/bin/bash
# # This script addresses issues found in security scans.
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# NC='\033[0m'

# benchmark="1.6.1.3 Ensure SELinux policy is configured" 
# selinuxtypecheck=`grep "SELINUXTYPE=targeted" /etc/selinux/config | wc -l`
# #selinux=[ permissive | disabled ]
# echo -e ${YELLOW} $benchmark ${NC}
# if [ "$selinuxtypecheck" ==  "0" ]
# then
#     sed -i 's/SELINUXTYPE=minimum/SELINUXTYPE=targeted/g' /etc/selinux/config
#     sed -i 's/SELINUXTYPE=mls/SELINUXTYPE=targeted/g' /etc/selinux/config
#     echo -e "---> ${GREEN}SELINUXTYPE has been updated to targeted mode.  Reboot is required.${NC}" 
#     echo -e ${GREEN} $benchmark "is configured properly" ${NC}
# else

#     echo -e "---> ${GREEN}SELINUXTYPE is in targeted mode${NC}"
#     echo -e ${GREEN} $benchmark "is configured properly" ${NC}
# fi
