#!/bin/bash
STEP="Initializing"
source ../env.sh

# Tell user what we're doing. If the image is already present and up to date then this will be quick.
echo -e "${GREEN}Pulling base openstudio image from docker hub${NC}..."
docker pull $image
echo -e "...${GREEN}done${NC}."

# Check if a container name was provided on the command line, if not use the default from env.sh.
testContainer=$1
if [ -z $testContainer ]; then
  echo -e "${YELLOW}Using default container name ${BLUE}${default_container}${NC}."
  testContainer=$default_container
else
  echo -e "${YELLOW}Using specified container name ${BLUE}${testContainer}${NC}."
fi

# Function to create new test container.
create_newContainer() {
  echo -e "${GREEN}Creating new docker test container${NC}..."
  echo -e "${YELLOW}If you get an error here check the folder mounted in the -v option must be a sharable resource - see the docker interface to enable${NC}"

  echo "Creating testing container with command:"
  echo -e "${GREEN}docker create -ti -P -v $shared_win_folder:/os_test --name $testContainer $image${NC}"
  MSYS_NO_PATHCONV=1 docker create -ti -P -v $shared_win_folder:/os_test --name $testContainer $image
}

# The docker ps will return the container ID if it exists, nothing if not.
 if [ ! $(docker ps -aq -f name=$testContainer) ]; then
  echo -e "${GREEN}Container ${BLUE}$testContainer ${GREEN}doesn't exist.${NC}"
	create_newContainer
 else
  echo -e "${GREEN}Found existing container ${BLUE}$testContainer. ${GREEN}Do you want to...?${NC}"
  # Select one of 3 options: 1) Recreate from scratch if it exists, 2) Just update the gems, or 3) Exit. 
  select yn in "Recreate everything from scratch" "Reinstall gems" "Cancel"; do
  case $yn in
  "Recreate everything from scratch")
    if [ ! $(docker ps -aq -f status=exited -f name=$testContainer) ] || [ $(docker ps -aq -f name=$testContainer) ]; then
      docker container stop $testContainer
    fi
    echo -e "${YELLOW}Removing container $testContainer.${NC}"
    docker container rm $testContainer
    create_newContainer
    break
    ;;
  "Reinstall gems")
    break
    ;;
  "Cancel")
    exit
    ;;
  esac
done
fi
 
# Run bundle install to update the new container (this will install gems in bundle/vendor).
echo -e "${GREEN}Starting the test environment container${NC}..."
docker container start $testContainer

# Download, install gems and run bundle.
download_gems

# Install gems.
echo -e "${GREEN}Installing gems in container: ${BLUE}$testContainer${NC}..."
docker exec $testContainer sh -c "mkdir -p $gemDir"
for ((iGem = 0; iGem < ${nGems}; iGem++)); do
  echo -e "  copying ${BLUE}${server_gems[($iGem * 3)]}${NC} to ${BLUE}$gemDir${NC} in container ${BLUE}$testContainer${NC}"
  docker cp ../.gems/${server_gems[($iGem * 3)]} $testContainer:$gemDir
done
echo -e "${GREEN}done${NC}."

echo -e "${GREEN}Running bundle on installed gems in container: ${BLUE}$testContainer${NC}..."
echo -e "  ${GREEN}output in popup window${NC}"
mintty -s 144,32 -t "Container ${testContainer} bundle log" -h always /bin/bash -c \
"docker exec $testContainer sh -c \"cd /os_test; rm -f Gemfile.lock; bundle install; bundle list --paths; echo DONE. Press enter to close.\""
echo -e "${GREEN}done${NC}."

echo -e "${GREEN}Stopping the test environment container${NC}..."
#docker container stop $testContainer
echo -e "...${GREEN}DONE${NC}."

