#!/bin/bash
source ../env.sh

echo -e "${GREEN}Stopping all openstudio server containers${NC}..."
docker-compose stop
echo "Press enter in the log window to close it"
echo -e "...${GREEN}DONE${NC}."
