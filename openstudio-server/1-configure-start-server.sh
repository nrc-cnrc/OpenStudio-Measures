#!/bin/bash
STEP="Initializing"
source ../env.sh

# Error message in case of failure
trap '[ "$?" -eq 0 ] || read -p "$? Looks like something went wrong in step ´$STEP´... Press enter to continue..."' EXIT

# Create the PAT results folder (as defined in env.sh)
STEP="${GREEN}Creating a folder to save PAT results in:${NC} ${PAT_shared_win_folder}"
mkdir -p ${PAT_shared_win_folder}

# Set number of workers as an env var here (this is then used for the containers)
# Run the docker compose file and display the log in a new window
STEP="Launching openstudio server"

echo
echo -e "${GREEN}OpenStudio Server is starting up${NC}..."
echo -e "Progress in new window 'OpenStudio Server Log'"
echo

mintty -s 188,32 -t "OpenStudio Server Log" -h always /bin/bash -c "win_user=$(whoami) docker-compose up --scale worker=${OS_SERVER_WORKERS}" &

# While the server is starting download/update the local copies of the gems
download_gems

# Define a container name for checking if the server is running and getting current server gemfile from.

container=${PWD##*/}"_web_1"

# Loop until container is up and running. Use 'tries' to avoid sticking here forever
echo -e "${GREEN}Checking server is up and running${NC}...$container"
tries="0"
server_running="1"
while [ -z `docker ps -aq -f status=running -f name=$container` ] 
do
  sleep 30
  echo -e "..." 
  tries=$[$tries+1]
  if [[ $tries -gt 20 ]] 
  then
    echo -e "${RED}ERROR: Containers have not yet started. Please re-run this script (or check docker for errors).${NC}"
    server_running="0"
    exit 2
  fi
done
echo -e "${GREEN}done${NC}."

# Download required gems into the osgems volume (created by the yml file).
# Copy required gems locally and then push onto the server.
if [ $server_running -eq "1" ]
then 
  # Install gems. Place the gems on the web_1 container as this is accessible from all teh workers.
  echo -e "${GREEN}Installing gems in container: ${BLUE}$container${NC}..."
  docker exec $container sh -c "mkdir -p $gemDir"
  for (( iGem=0; iGem<${nGems}; iGem++ ))
  do
    echo -e "  copying ${BLUE}${server_gems[($iGem*3)]}${NC} to ${BLUE}$gemDir${NC} in container ${BLUE}$container${NC}"
    docker cp ../.gems/${server_gems[($iGem*3)]} $container:$gemDir
  done
  echo -e "${GREEN}done${NC}."
  
  # Copy the default Gemfile. Edit this on the windows side and then copy to each worker.
  echo -e "${GREEN}Copying current openstudio-server gemfile from $container${NC}"
  docker cp $container:/usr/local/openstudio-${os_version}/Ruby/Gemfile .gemfile
  
# Update the gems on the worker nodes to use the specified version of standards (and it dependencies).
#  *** bundle config local.openstudio-standards /var/os-gems/openstudio-standards
  echo -e "${GREEN}Recovering worker IDs from docker${NC}..."
  STEP="${GREEN}Recovering worker IDs from docker${NC}"
  workerIDs=($(docker ps -q -f name=${PWD##*/}"_worker_"))
  echo -e "${BLUE}Worker IDs:${NC}\n$workerIDs"

  # Update each of the worker nodes. Need to edit the Gemfiles on each.
  echo -e "${GREEN}Updating worker node Gemfiles${NC}..."
  STEP="${GREEN}Updating worker node Gemfiles${NC}"
  nWorkers=${#workerIDs[@]}
  echo "Number of workers $nWorkers"
  echo "Number of gems $nGems"
  
  # Loop through the gemfiles specified in the env.sh file and modify the local .gemfile
  echo -e "${GREEN}... editing local .gemfile${NC}..."
  for (( iGem=0; iGem<${nGems}; iGem++ ))
  do
    OLD="gem '${server_gems[($iGem*3)+1]}'"
    NEW="gem '${server_gems[($iGem*3)+1]}', path: '/var/gems'" # This path is on the worker node
    #SPEC="spec.add_dependency '${server_gems[($iGem*3)+1]}'"
    if grep "gem '${server_gems[($iGem*3)+1]}'" .gemfile
    then
      echo -e "Found ${BLUE}${server_gems[($iGem*3)+1]}${NC} gem in local gemfile"
      sed -i -e "s|$OLD.*|$NEW|g" .gemfile
      #sed -i -e "s|$SPEC.*|$SPEC, '>= 0'|g" .gems/openstudio-gems.gemspec-updated
    else
      if [ ${server_gems[($iGem*3)+1]} = 'openstudio-gems' ]
      then
        echo -e "${YELLOW}Skipping ${server_gems[($iGem*3)+1]}${NC}"
      else
        echo -e "${YELLOW}Adding new gem ${BLUE}${server_gems[($iGem*3)+1]}${YELLOW} to local gemfile${NC}"
        echo "$NEW" >> .gemfile
      fi
    fi
    #  echo -e "${BLUE}Gem #$iGem${NC} - ${server_gems[($iGem*3)+1]}"
    #  docker exec ${workerIDs[$iWorker]} sh -c "cd /var/oscli; bundle config local.${server_gems[($iGem*3)+1]} /var/os-gems/${server_gems[($iGem*3)]}"
  done
  
  # Parse the project Gemfile and add measure specific gems from there into the local .gemfile
  echo -e "${GREEN}... adding measure specific gems to .gemfile${NC}..."
  addgems="FALSE"
  while read -r line
  do
    #echo -e "${YELLOW}$line${NC}"
	if [ "$addgems" = "TRUE" ]
	then
	  echo -e "${GREEN}   adding ${BLUE}${line}${GREEN} to .gemfile${NC}"
	  echo $line >> .gemfile
	fi
    if [[ "$line" =~ "Additional" ]]
	then
      echo -e "${GREEN}$line${NC}"
	  addgems="TRUE"
	fi
  done < ../Gemfile
  
  # Keep track of PIDs of spawned processes with popup windows.
  child_pids=()
  # Now copy the local gemfile to the workers.
  echo -e "${GREEN}Copying updated Gemfile to workers${NC}..."
  for (( iWorker=0; iWorker<${nWorkers}; iWorker++ ))
  do
    echo -e "${GREEN}${iWorker}: Worker ref ${BLUE}${workerIDs[$iWorker]}${NC}"
    docker cp .gemfile ${workerIDs[$iWorker]}:/var/oscli/Gemfile
    sleep 5
    echo -e "${GREEN}Running bundle on installed gems in container: ${BLUE}${workerIDs[$iWorker]}${NC}..."
    echo -e "  ${GREEN}output in popup window(s)${NC}"
    mintty -s 72,32 -t "Worker ${iWorker} Bundle Log (${workerIDs[$iWorker]}) <press enter to close>" -h always /bin/bash -c \
	    "docker exec ${workerIDs[$iWorker]} sh -c \"cd /var/oscli; rm -f Gemfile.lock; bundle install; bundle list --paths; echo DONE. Press enter to close.\"" &
    #docker exec ${workerIDs[$iWorker]} sh -c "cd /var/oscli; rm -f Gemfile.lock; bundle install"
	child_pids+=("$!" )
    echo -e "${GREEN}done${NC}"
  done

# Copy scripts to the server that are optionally used at end of simulation (with an analysis finalization script).
#  (ensure that the scripts folder exists and files are in unix format)
  echo -e "${GREEN}Copying optional finalization scripts to server${NC}..."
  cd ServerScripts
  for file in $(ls -1)
  do
    echo -e "  ${GREEN}working on ${BLUE}$file${NC}"
    dos2unix $file
    docker exec openstudio-server_web_1 sh -c 'mkdir -p /mnt/openstudio/scripts'
    docker cp $file openstudio-server_web_1:/mnt/openstudio/scripts/$file
  done
  echo -e "${GREEN}done${NC}."
  cd ..

  echo
  echo -e "...${GREEN}DONE${NC}."
  echo -e "Feedback from the server is displayed in the ${BLUE}OpenStudio Server Log${NC} window."
  echo -e "Configure PAT to point to the server ${BLUE}http://${HOSTNAME}:8080${NC}"
  echo
  
  echo $child_pids
fi

