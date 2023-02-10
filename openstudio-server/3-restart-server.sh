#!/bin/bash
source ../env.sh

# Colorful text
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Restarting all openstudio server containers${NC}..."
mintty -s 188,32 -t "OpenStudio Server Log" -h always /bin/bash -c "docker-compose restart" &
echo -e "...${GREEN}DONE${NC}."
