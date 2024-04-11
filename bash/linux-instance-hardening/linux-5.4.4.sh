# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.4.4 Ensure default user umask is 027 or more restrictive" 
echo -e ${YELLOW} $benchmark ${NC}
umask="umask 0027"

# echo -e "---> ${GREEN}adding umask 0027 to any .bashrc file not in the /root directory${NC}"
# for i in `find / -type f -name .bashrc ! -path "/root/*"`; do echo $umask >> $i; done

# echo -e "---> ${GREEN}adding umask 0027 to any .bash_profile file not in the /root directory${NC}"
# for i in `find / -type f -name .bash_profile ! -path "/root/*"`; do echo $umask >> $i; done
# echo -e ${GREEN} $benchmark " is configured properly" ${NC}
echo -e "---> ${GREEN}adding umask 0027 to any /etc/bashrc, /etc/profile, and /etc/profile.d files ${NC}"
sed -i 's/umask 022/umask 027/g' /etc/bashrc
sed -i 's/umask 022/umask 027/g' /etc/profile
echo -e ${GREEN} $benchmark "is configured properly" ${NC}

