#!/bin/bash

# Overall environment set up for local version of openstudio test environment and server. 

# Colourful text
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m'

# Tell user what we're doing.
echo -e "${GREEN}Setting OpenStudio environment${NC}..."

# The os_version number should be the only thing that needs updated.
# It has to be consistent with the nrcan_nrc branch of openstudio-standards being used
# elsewhere (e.g. in the version of openstudio-server that is used for PAT).
os_version="3.0.1"
image=nrel/openstudio:$os_version

# OpenStudio server and supporting gems (these need to be kept in sync when updating os_version).
server_image=nrel/openstudio-server:$os_version
rserve_image=nrel/openstudio-rserve:$os_version
# Format is (repo name, gem name, version). If a tag is provided instead of a branch name in the version string 
#  it will download the tag in 'detached' state and still work.
server_gems=() 
# Dependancies for 3.0.1
#  - none
# Dependancies for 3.2.0
#server_gems+=("openstudio-workflow-gem" "openstudio-workflow" "v2.1.0") 
# Dependencies for NRC measures and testing
#server_gems=("openstudio-standards" "openstudio-standards" "nrcan_nrc")
server_gems+=("openstudio-standards" "openstudio-standards" "nrcan_nrc")

# Set the number of gems to install
nGems=$((${#server_gems[@]}/3))

# Location of gems in containers.
gemDir="/var/gems"

# Set number of workers available to the server. By default this is the smaller of NCPU-5 and NCPU/2
workers=1
ncpu=`grep -c ^processor /proc/cpuinfo`
ncpuA=$(( $ncpu - 5 ))
ncpuB=$(( $ncpu / 2 ))
if (( $ncpuA > $ncpuB ))
then 
  workers=$ncpuB
else
  workers=$ncpuA
fi

# Shared folder (this is the folder on the windows box that will be linked to the windows-host in the 
# docker container). The hard drive that this folder is on has to be shared via the docker dashboard.
PAT_shared_win_folder="D:\Docker\OpenStudioServer\PAT_Results"

# Set environment variables to be used by OpenStudio Server
export OS_SERVER_WORKERS=$workers
export OS_SERVER_PAT_SHARED_FOLDER=${PAT_shared_win_folder}
export OS_SERVER_IMAGE=${server_image}
export OS_RSERVE_IMAGE=${rserve_image}
export REDIS_PASSWORD=openstudio
export REDIS_URL=redis://:openstudio@queue:6379
export MONGO_USER=openstudio
export MONGO_PASSWORD=openstudio
export SECRET_KEY_BASE=c4ab6d293e4bf52ee92e8dda6e16dc9b5448d0c5f7908ee40c66736d515f3c29142d905b283d73e5e9cef6b13cd8e38be6fd3b5e25d00f35b259923a86c7c473

# Create a .env file so that docker-compose up will work:
echo "OS_SERVER_WORKERS=$workers" > .env
echo "OS_SERVER_PAT_SHARED_FOLDER=${PAT_shared_win_folder}" >> .env
echo "OS_SERVER_IMAGE=${server_image}" >> .env
echo "REDIS_PASSWORD=openstudio" >> .env
echo "REDIS_URL=redis://:openstudio@queue:6379" >> .env
echo "MONGO_USER=openstudio" >> .env
echo "MONGO_PASSWORD=openstudio" >> .env
echo "SECRET_KEY_BASE=c4ab6d293e4bf52ee92e8dda6e16dc9b5448d0c5f7908ee40c66736d515f3c29142d905b283d73e5e9cef6b13cd8e38be6fd3b5e25d00f35b259923a86c7c473" >> .env


# Testing container specifics
# Set test container default name
default_container=ostest-$os_version

# Shared folder (this is the folder on the windows box that will be linked to the windows-host in the 
# docker container). The hard drive that this folder is on has to be shared via the docker dashboard.
shared_win_folder="$PWD/.."

# Complete configuration and report settings to screen.
echo -e "OpenStudio image name: ${BLUE}$image${NC}"
echo -e "Default test environment container name: ${BLUE}$default_container${NC}"
echo -e "OpenStudio-Server image name: ${BLUE}$server_image${NC}"
echo -e "OpenStudio-Server #workers: ${BLUE}$workers${NC}"

echo -e "...${GREEN}done${NC}." 
echo "----------------------------------------"

#
# Functions - these are used in some of the test/server scripts and the local gems are used implicitly in the CI testing.
#

# Download required gems locally as a tar.gzip file. These are then installed into the correct containers.
download_gems () {
  echo -e "${GREEN}Downloading/Updating local copies of required gems${NC}..."
  local thisDir=$PWD
  mkdir -p ../.gems
  cd ../.gems
  for (( iGem=0; iGem<${nGems}; iGem++ ))
  do
    if [ -d "${server_gems[($iGem*3)]}" ]; then
    # This will fail if its a different branch.
      echo -e "   updating gem: ${BLUE}${server_gems[($iGem*3)+1]}${NC}"
      cd ${server_gems[($iGem*3)]}
      git checkout ${server_gems[($iGem*3)+2]}
      git pull
      cd ..
    else
      echo -e "   downloading new gem: ${BLUE}${server_gems[($iGem*3)+1]}${NC}"
      git clone https://github.com/NREL/${server_gems[($iGem*3)]}.git 
      cd ${server_gems[($iGem*3)]}
	  git checkout ${server_gems[($iGem*3)+2]}
    fi
  done
  cd ${thisDir}
  echo -e "${GREEN}done${NC}."
}
