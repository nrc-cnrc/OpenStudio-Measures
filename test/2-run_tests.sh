#!/bin/bash
source ../env.sh

# Set defaults here that may be adjusted by command line args.
fast=""
container=""

# Parse the command line.
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--fast)
      echo -e "${GREEN}Fast run option specified. Container will not be stopped after test. You will have to do this manually!${NC}."
      fast="true"
      shift # past argument
      ;;
    -c|--container)
      echo -e "${GREEN}Specified a specific container!${NC}."
      container="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo -e "${YELLOW}Unknown option $1${NC}"
      exit 1
      ;;
  esac
done


# Check if a container name was provided on the command line, if not use the default from env.sh.
if [ -z ${container} ] 
then
    echo -e "${YELLOW}Using default container name ${BLUE}${default_container}${NC}."
	container=$default_container
else
    echo -e "${YELLOW}Using specified container name ${BLUE}${container}${NC}."
fi

# Start container
echo -e "${GREEN}Starting the test environment container${NC}..."
docker container start ${container}

# Run the tests
echo -e "${GREEN}Starting the tests${NC}..."
if [ -z ${fast} ] 
then
  echo -e "${GREEN}Updating gems${NC} (info in popup window)..."
  mintty -s 72,32 -t "Gem update info" -h always /bin/bash -c \
    "docker exec $container sh -c \"cd /var/oscli; bundle update; echo DONE. Press enter to close.\""
  echo -e "${GREEN}Updating measures${NC} (info in popup window)..."
  mintty -s 144,32 -t "Measure update info" -h always /bin/bash -c \
    "docker exec $container sh -c \"openstudio --bundle /var/oscli/Gemfile --bundle_path /var/oscli --bundle_without native_ext measure -t /os_test/measures; echo DONE. Press enter to close.\""
fi

# Define env variables used in the test scripts. Note the path is defined for the docker container (not windows), a;lso note the missing / at the beginning so that docker does 
#  not mess the path up on import.
export OS_MEASURES_TEST_TIME="`date -u +%s`"
export OS_MEASURES_TEST_DIR="os_test/test"

echo -e "${GREEN}Running tests${NC}..."
docker exec -e OS_MEASURES_TEST_TIME -e OS_MEASURES_TEST_DIR ${container} sh -c "cd /var/oscli; bundle exec ruby /os_test/test/test_measures.rb"

# Stop the container.
if [ -z ${fast} ]
then
  echo -e "${GREEN}Stopping the test environment container${NC}..."
  docker container stop ${container}
  echo -e "...${GREEN}done${NC}." 
fi
