# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.4.1.2 Ensure minimum days between password changes is 7 or more" 
echo -e ${YELLOW} $benchmark ${NC}

sed -i 's/PASS_MIN_DAYS [0-9]/PASS_MIN_DAYS 7/g' /etc/login.defs


echo -e ${GREEN} $benchmark "is configured properly" ${NC}