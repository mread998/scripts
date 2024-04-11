# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.2.6 Ensure SSH X11 forwarding is disabled" 
echo -e ${YELLOW} $benchmark ${NC}
sshx11check=`grep "X11Forwarding yes" /etc/ssh/sshd_config |wc -l`

if [ "$sshx11check" == "0" ]
then 
    echo -e "---> ${GREEN}There is nothing to do X11forwarding is already disabled${NC}"
else
    sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
fi
echo -e ${GREEN} $benchmark "is configured properly" ${NC}