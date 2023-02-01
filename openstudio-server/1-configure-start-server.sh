#!/bin/bash
STEP="Initializing"
source ../env.sh

# Error message in case of failure
trap '[ "$?" -eq 0 ] || read -p "$? Looks like something went wrong in step ´$STEP´... Press enter to continue..."' EXIT

# Create the PAT results, gems and data folders (root defined in env.sh)
STEP="${GREEN}Creating a folder to save PAT results in:${NC} ${docker_win_root}/PAT"
mkdir -p ${docker_win_root}/PAT
mkdir -p ${docker_win_root}/osdata
mkdir -p ${docker_win_root}/osgems
mkdir -p ${docker_win_root}/workers

# Create docker volumes for the large file storage needs of server.
docker volume create -d local --name openstudio-server-osgems \
  --opt device="${docker_win_root}\osgems" \
  --opt type="none" \
  --opt o="bind"
docker volume create -d local --name openstudio-server-osdata \
  --opt device="${docker_win_root}\osdata" \
  --opt type="none" \
  --opt o="bind"

# Set number of workers as an env var here (this is then used for the containers)
# Run the docker compose file and display the log in a new window
STEP="Launching openstudio server"

echo
echo -e "${GREEN}OpenStudio Server is starting up${NC}..."
echo -e "Progress in new window 'OpenStudio Server Log'"
echo

#mintty -s 188,32 -t "OpenStudio Server Log" -h always /bin/bash -c "win_user=$(whoami) docker-compose up --scale worker=${OS_SERVER_WORKERS}" &
mintty -s 188,32 -t "OpenStudio Server Log" -h always /bin/bash -c "win_user=$(whoami) docker compose up --scale worker=${OS_SERVER_WORKERS}" &

# While the server is starting download/update the local copies of the gems
download_gems

# Copy our weather files to the local copy of the standards gem.
echo -e "${GREEN}Copying weather files to local copy of openstudio-standards${NC}"
cp -fr ServerData/weather/ ../.gems/openstudio-standards/data/

# Define a container name for checking if the server is running and getting current server gemfile from.
#  Also define the worker container root name (i.e. without the number) here for ease of fixing when
#  docker changes their naming scheme.
container=${PWD##*/}"-web-1"
worker_root=${PWD##*/}"-worker-"

# Loop until container is up and running. Use 'tries' to avoid sticking here forever.
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
    container=${PWD##*/}"_web_1"
    worker_root=${PWD##*/}"_worker_"    
  else
    if [[ $tries -gt 29 ]]
    then
      echo -e "${RED}ERROR: Containers have not yet started. Please re-run this script (or check docker for errors).${NC}"
      server_running="0"
      exit 2
    fi
  fi
done
echo -e "${GREEN}done${NC}."

# Install the gems specified in ../env.sh to the web container (the gems folder is shared with the workers).
# First apply NRC specific fix to simulation.rb
if [ $server_running -eq "1" ]
then 
  # Fix simulation.rb so it works on PAT.
  sed -i 's/#FileUtils.touch/FileUtils.touch/' ../.gems/openstudio-standards/lib/openstudio-standards/utilities/simulation.rb

  # Now install the gems
  install_gems $container

# Now update all the worker nodes.
  echo -e "${GREEN}Recovering worker IDs from docker${NC}..."
  STEP="${GREEN}Recovering worker IDs from docker${NC}"
  workerIDs=($(docker ps -q -f name=${worker_root}))
  echo -e "${BLUE}Worker IDs:${NC}\n$workerIDs"

  # Update each of the worker nodes. Need to edit the Gemfiles on each.
  echo -e "${GREEN}Updating worker node Gemfiles${NC}..."
  STEP="${GREEN}Updating worker node Gemfiles${NC}"
  nWorkers=${#workerIDs[@]}
  echo "Number of workers $nWorkers"
   
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
	# Measures cannot use pre-compiled versions of gems. This rules out anything using nokogiri for example.
    mintty -s 72,32 -t "Worker ${iWorker} Bundle Log (${workerIDs[$iWorker]}) <press enter to close>" -h always /bin/bash -c \
	    "docker exec ${workerIDs[$iWorker]} sh -c \"cd /var/oscli; rm -f Gemfile.lock; bundle install; bundle list --paths; echo DONE. Press enter to close.\"" &
    #docker exec ${workerIDs[$iWorker]} sh -c "cd /var/oscli; rm -f Gemfile.lock; bundle install"
	child_pids+=("$!" )
    echo -e "${GREEN}done${NC}"
  done

# Copy scripts to the server that are optionally used at end of simulation (with an analysis finalization script).
#  (ensure that the scripts folder exists and files are in unix format)
#  Also contains a seperate Gemfile to decouple from openstudio_cli restrictions
  echo -e "${GREEN}Copying optional finalization scripts to server${NC}..."
  cd ServerScripts
  for file in $(ls -1)
  do
    echo -e "  ${GREEN}working on ${BLUE}$file${NC}"
    dos2unix $file
    docker exec $container sh -c 'mkdir -p /mnt/openstudio/scripts'
    docker cp $file $container:/mnt/openstudio/scripts/$file
  done
  echo -e "${GREEN}done${NC}."
  cd ..

  # Offer to kill all the worker log windows at once. For some strange reason the PIDs recorded above no longer exist (they are all 2 greater). Do not 
  #  want to just add 2 to the PID though as that could have serious side effects!
  echo "Remove all worker log pop-up windows?"
  select yn in "Yes" "No"; do
    case $yn in
    1 | "Yes" )
	  for pid in "${child_pids[@]}"
	  do
        #echo -e "Removing ${BLUE}$pid${NC}"
		kill $pid
	  done
	  break
      ;;
	*)
	  break;;
    esac
  done
  
  # Final "we're done", over to you message.
  echo
  echo -e "...${GREEN}DONE${NC}."
  echo -e "Feedback from the server is displayed in the ${BLUE}OpenStudio Server Log${NC} window."
  echo -e "Configure PAT to point to the server ${BLUE}http://${HOSTNAME}:8080${NC}"
  echo
  
fi

