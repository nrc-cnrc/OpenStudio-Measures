#!/bin/bash
STEP="Initializing"
source ../env.sh

# Set defaults here that may be adjusted by command line args.
local_image=""

# Parse the command line.
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--image)
      echo -e "${GREEN}Using the specified local image!${NC}."
      local_image="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo -e "${YELLOW}Unknown option $1${NC}"
      exit 1
      ;;
  esac
done

# Tell user what we're doing. If the image is already present and up to date then this will be quick.
if [ -z ${local_image} ] 
then
  echo -e "${GREEN}Pulling base openstudio-server image from docker hub${NC}..."
  docker pull nrel/${server_image}
  test_image=nrel/${server_image}
  echo -e "...${GREEN}done${NC}."
else
  echo -e "${YELLOW}Using specified local image name ${BLUE}${local_image}${NC}."
  docker load -i ${local_image}
  test_image=${local_image}
  echo -e "...${GREEN}done${NC}."
fi

# Check if a container name was provided on the command line, if not use the default from env.sh.
testContainer=$1
if [ -z ${testContainer} ]; then
  echo -e "${YELLOW}Using default container name ${BLUE}${default_container}${NC}."
  testContainer=${default_container}
else
  echo -e "${YELLOW}Using specified container name ${BLUE}${testContainer}${NC}."
fi

# Function to create new test container.
create_newContainer() {
  echo -e "${GREEN}Creating new docker test container${NC}..."
  echo -e "${YELLOW}If you get an error here check the folder mounted in the -v option must be a sharable resource - see the docker interface to enable${NC}"

  echo "Creating testing container with command:"
  echo -e   "${GREEN}docker create -ti -P -v $os_measures_root:/os_test --name ${testContainer} ${test_image}${NC}"
  MSYS_NO_PATHCONV=1 docker create -ti -P -v ${os_measures_root}/test:/os_test/test -v ${os_measures_root}/measures:/os_test/measures -v ${os_measures_root}/measures_templates:/os_test/measures_templates --name ${testContainer} ${test_image}

  echo -e "${GREEN}Starting the test environment container${NC}..."
  docker container start ${testContainer}
}

# The docker ps will return the container ID if it exists, nothing if not.
 if [ ! $(docker ps -aq -f name=${testContainer}) ]; then
  echo -e "${GREEN}Container ${BLUE}${testContainer} ${GREEN}doesn't exist.${NC}"
	create_newContainer
 else
  echo -e "${GREEN}Found existing container ${BLUE}${testContainer}. ${GREEN}Do you want to...?${NC}"
  # Select one of 3 options: 1) Recreate from scratch if it exists, 2) Just update the gems, or 3) Exit. 
  select yn in "Recreate everything from scratch" "Reinstall gems" "Cancel"; do
  case $yn in
  "Recreate everything from scratch")
    if [ ! $(docker ps -aq -f status=exited -f name=${testContainer}) ] || [ $(docker ps -aq -f name=${testContainer}) ]; then
      docker container stop ${testContainer}
    fi
    echo -e "${YELLOW}Removing container ${testContainer}.${NC}"
    docker container rm ${testContainer}
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
docker container start ${testContainer}

# Download gems.
download_gems

# Customize standards. (Adds our weather and hacks to standards code)
customize_standards

# Install gems and run bundle.
install_gems ${testContainer}

echo -e "${GREEN}Stopping the test environment container${NC}..."
#docker container stop ${testContainer}
echo -e "...${GREEN}DONE${NC}."

