# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="5.4.1.4 Ensure inactive password lock is 30 days or less" 
echo -e ${YELLOW} $benchmark ${NC}

useradd -D -f30

echo -e ${GREEN} $benchmark "is configured properly" ${NC}