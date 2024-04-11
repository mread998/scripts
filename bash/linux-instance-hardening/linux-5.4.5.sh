# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.4.5 Ensure default user shell timeout is 900 seconds or less" 
echo -e ${YELLOW} $benchmark ${NC}
tmout="TMOUT=600"
userlst=`ls -1 /home/`

echo -e "---> ${GREEN} updating user bash scripts with timeout ${NC}"
for i in $userlst; do echo "$tmout" >> /home/$i/.bashrc && echo "$umask" >> /home/$i/.bashrc; done
for i in $userlst; do echo "$tmout" >> /home/$i/.bash_profile && echo "$umask" >> /home/$i/.bash_profile; done

# update default skel files with umask
echo "$tmout" >> /etc/skel/.bashrc
echo "$tmout" >> /etc/skel/.bash_profile

echo -e ${GREEN} $benchmark "is configured properly" ${NC}