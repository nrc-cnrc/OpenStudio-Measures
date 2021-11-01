#!/bin/bash
source ../env.sh

# Colorful text
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Remove volumes not referenced by containers (across the board); shut down the server containers; remove the
# two openstudio volumes (but keep the gems one so that we can start up quickly next time).

echo -e "${GREEN}Removing unreferenced docker volumes${NC}..."
echo -e "${YELLOW}This will apply to all docker containers - not just the openstudio-server ones!${NC}..."
docker volume prune #-f
echo -e "...${GREEN}done${NC}."
echo -e "${GREEN}Stopping and removing all openstudio server containers${NC}..."
docker-compose down --remove-orphans
echo -e "...${GREEN}done${NC}."
echo -e "${GREEN}Removing openstudio volumes${NC}..."
docker volume rm ${PWD##*/}"_dbdata"
docker volume rm ${PWD##*/}"_osdata"
echo -e "...${GREEN}DONE${NC}."
