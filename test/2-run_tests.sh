#!/bin/bash
source ../env.sh

# Check if running a fast test (no updates and container will be kept alive)
fast=""
if [ -n $1 ] && [[ $1 = "--fast" ]]
then
  echo -e "${YELLOW}Fast run option specified. Container will not be stopped after test. You will have to do this manually!${NC}."
  fast="true"
  container=$2
else
  container=$1
fi

# Check if a container name was provided on the command line, if not use the default from env.sh.
if [ -z $container ] 
then
    echo -e "${YELLOW}Using default container name ${BLUE}${default_container}${NC}."
	container=$default_container
else
    echo -e "${YELLOW}Using specified container name ${BLUE}${container}${NC}."
fi

# Start container
echo -e "${GREEN}Starting the test environment container${NC}..."
docker container start $container
# Run the tests
echo -e "${GREEN}Starting the tests${NC}..."
if [ -z $fast ] 
then
  echo -e "${GREEN}Updating gems${NC} (info in popup window)..."
  mintty -s 72,32 -t "Gem update info" -h always /bin/bash -c \
    "docker exec $container sh -c \"cd /os_test; bundle update; echo DONE. Press enter to close.\""
  echo -e "${GREEN}Updating measures${NC} (info in popup window)..."
  mintty -s 144,32 -t "Measure update info" -h always /bin/bash -c \
    "docker exec $container sh -c \"openstudio measure -t /os_test/measures; echo DONE. Press enter to close.\""
fi
echo -e "${GREEN}Running tests${NC}..."
docker exec $container sh -c "cd /os_test/test; bundle exec ruby test_measures.rb"

# Stop the container
if [ -z $fast ]
then
  echo -e "${GREEN}Stopping the test environment container${NC}..."
  docker container stop $container
  echo -e "...${GREEN}done${NC}." 
fi
