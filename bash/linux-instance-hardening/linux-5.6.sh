# # #!/bin/bash
# # This script addresses issues found in security scans.
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# NC='\033[0m'

# benchmark="5.6 Ensure access to the su command is restricted"
# # Checking to see if the wheel group exists, if not create it
# echo -e ${YELLOW} $benchmark ${NC}
# if [ $(getent group wheel) ]
# then
#     echo -e "---> ${GREEN} The wheel group exists. ${NC}"
# else
#     echo -e "--> ${GREEN} The wheel has been added. ${NC}"
#     groupadd wheel -g 10
# fi

# # checking Pam is locking the 'su' user
# # if ['cat /etc/pam.d/su  | grep "#auth | grep "pam_wheel.so use_uid"']
# pamdcomment=`cat /etc/pam.d/su | grep "#auth" | grep "pam_wheel.so use_uid" | wc -l`
# if [[ "$pamdcomment" == "0" ]]
# then
#     echo -e "${GREEN} pam is configured to use the wheel group ${NC}"
# else
#     # delete current /etc/pam.d/su and copy new one
#     mv /etc/pam.d/su /etc/pam.d/su-bak && cp template/su /etc/pam.d/su
#      echo -e "${GREEN} pam has been configured to use the wheel group ${NC}"
# fi
# # echo -e ${GREEN} $benchmark "is configured properly" ${NC}
# echo -e ${GREEN} $benchmark "is configured properly" ${NC}