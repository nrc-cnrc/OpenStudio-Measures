#!/bin/bash
source ../env.sh

# Generate a list of the openstudio-standards tests (that are relevent to us).
test_cases=(building_regression system_tests)

# First argument is the test_case to test.
echo "Select case to test:"
select test_case in "${test_cases[@]}";
do
  if (( $REPLY > 0 && $REPLY <= ${#test_cases[@]} ))
  then
    echo -e "${BLUE}${test_case}${NC} selected."
	test=$test_case
    break
  else
    echo -e "${YELLOW}Invalid option. Try another one.${NC}"
  fi
done

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

# Run the tests (update gems and measure first)
echo -e "${GREEN}Starting ${test} for openstudio-standards${NC}..."
if [ -z $fast ] 
then
  echo -e "${GREEN}Updating gems${NC}..."
  for ((iGem = 0; iGem < ${nGems}; iGem++)); do
    echo -e "  copying ${BLUE}${server_gems[($iGem * 3)]}${NC} to ${BLUE}$gemDir${NC} in container ${BLUE}$container${NC}"
    docker cp ../.gems/${server_gems[($iGem * 3)]} $container:$gemDir
  done
fi
echo -e "${GREEN}Running tests${NC}..."
docker exec $container sh -c "cd $gemDir/openstudio-standards; bundle install; bundle exec rake test:parallel_run_necb_${test}_tests_locally"

# Stop the container
if [ -z $fast ]
then
  echo -e "${GREEN}Stopping the test environment container${NC}..."
  docker container stop $container
  echo -e "...${GREEN}done${NC}." 
fi
