#!/bin/bash

# Overall environment set up for local version of openstudio test environment and server. 

# Colourful text
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# Tell user what we're doing.
echo -e "${GREEN}Setting OpenStudio environment${NC}..."

# Get the folder containing this script. Used as the base folder for many path operations.
# (this is the folder on the windows box that contains measures and measures_templates. It will be linked to the windows-host in the 
# docker container). 
# The hard drive that this folder is on has to be shared via the docker dashboard if not running WSL2.
os_measures_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Shared folder (this is the folder on the windows box that will be linked to the windows-host in the 
# docker container). The hard drive that this folder is on has to be shared via the docker dashboard.
docker_win_root="D:\Docker\OS"

# The os_version number should be the only thing that needs updated.
# It has to be consistent with the nrcan_nrc branch of openstudio-standards being used
# elsewhere (e.g. in the version of openstudio-server that is used for PAT).
# These variables are referenced in all the other sctipts.
os_version="3.2.1"
os_image=openstudio:${os_version}

# Add identifier to image name so we can keep track of our updates. This image is used for testing.
nrc_os_image="openstudio:latest"

# OpenStudio server and supporting gems (these need to be kept in sync when updating os_version).
server_image=openstudio-server:${os_version}
rserve_image=openstudio-rserve:${os_version}

# Format is (repo name, gem name, version). If a tag is provided instead of a branch name in the version string 
#  it will download the tag in 'detached' state and still work.
server_gems=() 
# Dependancies for 3.0.1
#  - none
# Dependancies for 3.2.1
#  - none 
# Dependencies for NRC measures and testing
#server_gems=("openstudio-standards" "openstudio-standards" "nrcan")
server_gems+=("openstudio-standards" "openstudio-standards" "nrcan_nrc")

# Set the number of gems to install
nGems=$((${#server_gems[@]}/3))

# Other gems (ones required by our measures)
other_gems=()
other_gems+=("'aws-sdk-s3'" "'git-revision'" "'diffy'" "'roo', '~> 2.8'" "'enumerable-statistics'")

# Location of gems in containers.
gemDirLocal="${os_measures_root}/.gems"
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
if [ $workers -lt 1 ]
  then
  workers=2
fi


# Set environment variables to be used by OpenStudio Server
export OS_SERVER_WORKERS=${workers}
export OS_SERVER_WIN_ROOT=${docker_win_root}
export OS_SERVER_IMAGE=${server_image}
export OS_RSERVE_IMAGE=${rserve_image}
export REDIS_PASSWORD=openstudio
export REDIS_URL=redis://:openstudio@queue:6379
export MONGO_USER=openstudio
export MONGO_PASSWORD=openstudio
export SECRET_KEY_BASE=c4ab6d293e4bf52ee92e8dda6e16dc9b5448d0c5f7908ee40c66736d515f3c29142d905b283d73e5e9cef6b13cd8e38be6fd3b5e25d00f35b259923a86c7c473

# Create a .env file so that docker-compose up will work:
echo "OS_SERVER_WORKERS=$workers" > .env
echo "OS_SERVER_PAT_SHARED_FOLDER=${docker_win_root}" >> .env
echo "OS_SERVER_IMAGE=${server_image}" >> .env
echo "REDIS_PASSWORD=openstudio" >> .env
echo "REDIS_URL=redis://:openstudio@queue:6379" >> .env
echo "MONGO_USER=openstudio" >> .env
echo "MONGO_PASSWORD=openstudio" >> .env
echo "SECRET_KEY_BASE=c4ab6d293e4bf52ee92e8dda6e16dc9b5448d0c5f7908ee40c66736d515f3c29142d905b283d73e5e9cef6b13cd8e38be6fd3b5e25d00f35b259923a86c7c473" >> .env


# Testing container specifics
# Set test container default name
default_container=ostest-${os_version}

# Measures root folder (this is the folder on the windows box that contains measures and measures_templates. It will be linked to the windows-host in the 
# docker container). The hard drive that this folder is on has to be shared via the docker dashboard if not running WSL2.
measures_win_folder="$PWD/.."

# Complete configuration and report settings to screen.
echo -e "${CYAN}Configuration settings${NC}"
echo -e "${CYAN}Paths:${NC}"
echo -e "  Root folder of measures: ${BLUE}$os_measures_root${NC}"
echo -e "  Shared windows folder: ${BLUE}$docker_win_root${NC}"
echo -e "  Local gems folder: ${BLUE}$gemDirLocal${NC}"
echo -e "  Gem folder: ${BLUE}$gemDir${NC}"
echo -e "${CYAN}Image/Container info:${NC}"
echo -e "  Base OpenStudio image name: ${BLUE}$os_image${NC}"
echo -e "    server image name: ${BLUE}$server_image${NC}"
echo -e "    Rserve image name: ${BLUE}$rserve_image${NC}"
echo -e "  OpenStudio-Server #workers: ${BLUE}$workers${NC}"
echo -e "  NRC image name: ${BLUE}$nrc_os_image${NC}"
echo -e "  Default test environment container name: ${BLUE}$default_container${NC}"
echo "----------------------------------------"

#
# Functions - these are used in some of the test/server scripts and the local gems are used implicitly in the CI testing.
#

# Download required gems locally. These are then installed into the correct containers.
# Save the current working folder, do the worrk then return to that folder.
download_gems () {
  echo -e "${GREEN}Downloading/Updating local copies of required gems${NC}..."
  local thisDir=${PWD}
  mkdir -p ${gemDirLocal}
  cd ${gemDirLocal}
  echo -e "${GREEN} Working dir now: $PWD${NC}..."
  ls -l
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
  echo -e "${GREEN} Working dir now: $PWD${NC}..."
  echo -e "${GREEN}done${NC}."
}

install_gems () {

  # Install gems. Place the gems on the specified container.
  container=$1
  echo -e "${GREEN}Installing gems in container: ${BLUE}$container${NC}..."
  docker exec ${container} sh -c "mkdir -p $gemDir"
  for (( iGem=0; iGem<${nGems}; iGem++ ))
  do
    echo -e "copying ${BLUE}${server_gems[($iGem*3)]}${NC} to ${BLUE}$gemDir${NC} in container ${BLUE}$container${NC}"
    docker cp ${gemDirLocal}/${server_gems[($iGem*3)]} ${container}:${gemDir}
  done

  echo -e "${GREEN}done${NC}."
  
  # Copy the default Gemfile. Edit this on the windows side and then copy it back.
  echo -e "${GREEN}Copying current openstudio-server gemfile from ${BLUE}$container${NC}"
  docker cp ${container}:/usr/local/openstudio-${os_version}/Ruby/Gemfile .gemfile
  
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
  
  # Add in the 'other_gems' required for NRC measures
  for (( iGem=0; iGem<${#other_gems[@]}; iGem++ ))
  do
    echo gem ${other_gems[$iGem]} >> .gemfile
  done 
  
  # Now copy the .gemfile back to the container, but put it in the /var/oscli folder.
  docker cp .gemfile ${container}:/var/oscli/Gemfile

  # Finally bundle the new gems.
  echo -e "${GREEN}Running bundle on installed gems in container: ${BLUE}$container${NC}..."
  echo -e "  ${GREEN}output in popup window${NC}"
  mintty -s 144,32 -t "Container ${container} bundle log" -h always /bin/bash -c \
  "docker exec $container sh -c \"cd /var/oscli; rm -f Gemfile.lock; bundle install; bundle list --paths; echo DONE. Press enter to close.\""
  echo -e "${GREEN}done${NC}."
}

bundle_gems () {
  container=$1
  echo -e "${GREEN}Running bundle on installed gems in container: ${BLUE}$container${NC}..."
  echo -e "  ${GREEN}output in popup window${NC}"
  mintty -s 144,32 -t "Container ${container} bundle log" -h always /bin/bash -c \
  "docker exec $container sh -c \"cd /var/oscli; rm -f Gemfile.lock; bundle install; bundle list --paths; echo DONE. Press enter to close.\""
  echo -e "${GREEN}done${NC}."
}

# Customize standards.
customize_standards () {

  # Add our weather files.
  echo -e "${GREEN}Copying weather files to local copy of openstudio-standards${NC}"
  echo -e "${GREEN} Working dir now: $PWD${NC}..."
  echo -e "${GREEN} Gemdir: $gemDirLocal${NC}..."
  cp -fr ${os_measures_root}/openstudio-server/ServerData/weather/ ${gemDirLocal}/openstudio-standards/data/

  # Fixes to default standards code.
  echo -e "${YELLOW}Implementing touch hack (so PAT works)${NC}."
  sed -i 's/#FileUtils.touch/FileUtils.touch/' ${gemDirLocal}/openstudio-standards/lib/openstudio-standards/utilities/simulation.rb
  echo -e "${YELLOW}Disabling KIVA foundations (as some models crash with it)${NC}."
  ls -l ${gemDirLocal}/openstudio-standards/lib/openstudio-standards/standards/necb/NECB2011/necb_2011.rb
  sed -i 's/apply_kiva_foundation/#apply_kiva_foundation/' ${gemDirLocal}/openstudio-standards/lib/openstudio-standards/standards/necb/NECB2011/necb_2011.rb
  sed -i 's/def #apply_kiva_foundation/def apply_kiva_foundation/' ${gemDirLocal}/openstudio-standards/lib/openstudio-standards/standards/necb/NECB2011/necb_2011.rb
  grep kiva_foundation ${gemDirLocal}/openstudio-standards/lib/openstudio-standards/standards/necb/NECB2011/necb_2011.rb
  ls -l ${gemDirLocal}/openstudio-standards/lib/openstudio-standards/standards/necb/NECB2011/necb_2011.rb
}
