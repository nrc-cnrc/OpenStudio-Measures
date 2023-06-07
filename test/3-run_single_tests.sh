#!/bin/bash
source ../env.sh

# Set defaults here that may be adjusted by command line args.
fast=""
test=0
container=""

# Parse the command line.
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--fast)
      echo -e "${GREEN}Fast run option specified. Container will not be stopped after test. You will have to do this manually!${NC}."
      fast="true"
      shift # past argument
      ;;
    -t|--test)
      echo -e "${GREEN}Specified a single test to run!${NC}."
      test=($2)-1
      shift # past argument
      shift # past value
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

# Generate a list of the measures.
measures=(`ls -1 ${os_measures_root}/measures`)

# First argument is the measure to test.
if (( $test > 0 ))
then
  measure=${measures[$test]}
  echo -e "${BLUE}${measure}${NC} selected."
else
echo "Select measure to test:"
select measure in "${measures[@]}";
do
  if (( $REPLY > 0 && $REPLY <= ${#measures[@]} ))
  then
    echo -e "${BLUE}${measure}${NC} selected."
    break
  else
    echo -e "${YELLOW}Invalid option. Try another one.${NC}"
  fi
done
fi

# Generate a list of tests for this measure.
tests=(`cd ${os_measures_root}/measures/${measure}/tests && ls -1 test*.rb`)
if (( ${#tests[@]} == 0 ))
then
  echo -e "${RED}No available tests for ${measure}!${NC}"
  exit
elif (( ${#tests[@]} == 1 ))
then
  echo -e "Selecting test: ${BLUE}${tests}${NC}"
  test=${tests}
else
  echo "Select test to run:"
  select test in "${tests[@]}";
  do
    echo $REPLY, ${#tests[@]}
    if (( $REPLY > 0 && $REPLY <= ${#tests[@]} ))
    then
      echo -e "${BLUE}${test}${NC} selected."
      break
    else
      echo -e "${YELLOW}Invalid option. Try another one.${NC}"
    fi
  done
fi

# Check if a container name was provided on the command line, if not use the default from env.sh.
if [ -z ${container} ] 
then
    echo -e "${YELLOW}Using default container name ${BLUE}${default_container}${NC}."
	container=${default_container}
else
    echo -e "${YELLOW}Using specified container name ${BLUE}${container}${NC}."
fi

# Start container
echo -e "${GREEN}Starting the test environment container${NC}..."
docker container start ${container}

# Run the tests (update gems and measure first). 
echo -e "${GREEN}Starting ${test} for measure ${measure}${NC}..."
if [ -z ${fast} ] 
then
  echo -e "${GREEN}Updating gems${NC} (info in popup window)..."
  mintty -s 72,32 -t "Gem update info" -h always /bin/bash -c \
    "docker exec $container sh -c \"cd /var/oscli; bundle update; echo DONE. Press enter to close.\""
  echo -e "${GREEN}Updating measures${NC} (info in popup window)..."
  mintty -s 144,32 -t "Measure update info" -h always /bin/bash -c \
    "docker exec $container sh -c \"openstudio --bundle /var/oscli/Gemfile --bundle_path /var/oscli --bundle_without native_ext measure -u /os_test/measures/${measure}; echo DONE. Press enter to close.\""
fi

# Define env variables used in the test scripts. Note the path is defined for the docker container (not windows), also note the missing / at the beginning so that docker does 
#  not mess the path up on import.
export OS_MEASURES_TEST_TIME="`date -u +%s`"
export OS_MEASURES_TEST_DIR="os_test/test"

echo -e "${GREEN}Running tests${NC}..."
docker exec -e OS_MEASURES_TEST_TIME -e OS_MEASURES_TEST_DIR ${container} sh -c "cd /var/oscli; bundle exec ruby /os_test/measures/${measure}/tests/${test}"

# Stop the container.
if [ -z ${fast} ]
then
  echo -e "${GREEN}Stopping the test environment container${NC}..."
  docker container stop ${container}
  echo -e "...${GREEN}done${NC}." 
fi
