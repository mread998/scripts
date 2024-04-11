# #!/bin/bash
# This script addresses issues found in security scans.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

benchmark="4.1.4 - 4.1.19 Ensure events information are collected" 
echo -e ${YELLOW} $benchmark ${NC}
cp /etc/audit/audit.rules /etc/audit/audit.rules.bak
cp -f template/audit-rules /etc/audit/audit.rules
echo -e ${GREEN} $benchmark " is configured properly" ${NC}