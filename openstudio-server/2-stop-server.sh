#!/bin/bash

# Colorful text
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'


echo -e "${GREEN}Stopping all openstudio server containers${NC}..."
docker-compose stop
echo "Press enter in the log window to close it"
echo -e "...${GREEN}DONE${NC}."
