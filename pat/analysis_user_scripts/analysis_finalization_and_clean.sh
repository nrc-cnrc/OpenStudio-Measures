#!/bin/bash -e
# Copy scripts to the server that are optionally used at end of simulation (with an analysis finalization script).
# This script runs on the web node.
# Additional code to remove orphaned files left behind by openstudio server.
echo -e "${GREEN}Copying optional finalization scripts to server${NC}..."
      
# NRC server setup has the ruby files in this location.
cd /mnt/openstudio/scripts
echo "*** Current environment ***"
env | sort
echo "---------------"
# Store current RUBY environment and clear settings (will reset at end of script).
CURRENT_RUBYLIB=RUBYLIB
CURRENT_RUBYOPT=RUBYOPT
CURRENT_BUNDLE_GEMFILE=BUNDLE_GEMFILE
CURRENT_BUNDLE_WITHOUT=BUNDLE_WITHOUT
export RUBYLIB=""
export RUBYOPT=""
export BUNDLE_GEMFILE=""
export BUNDLE_WITHOUT=""
echo "*** Temporary environment ***"
env | sort
echo "---------------"
bundle install --standalone

# Always run the re-name script first.
arr_scripts=('re-name_simulations.rb')

# Add all names of finalization scripts to an array 
for file in $(ls -1)
do
  if [ $file != 're-name_simulations.rb' ] && [ $file != 'Gemfile' ] && [ $file != 'Gemfile.lock' ] && [ $file != 'bundle' ]
  then
    arr_scripts+=($file)
  fi
done
 
num_scripts=${#arr_scripts[@]}
echo -e "${GREEN}There are $num_scripts scripts added to arr_script ${arr_scripts[@]} ${NC}."

i=0
while [ $i -lt $num_scripts ]
 do
  echo "----------------------------------------------"
  echo "Starting script number $i : ${arr_scripts[$i]}"
  
  # An OR statement is added to catch any errors that causes the script to terminate and doesn't run the following script in the Server folder
  bundle exec ruby ${arr_scripts[$i]} -a $ANALYSIS_ID || echo "An error occured in $i script : ${arr_scripts[$i]}, will skip to the following script."
  i=$(( $i + 1 ))
 done
 
 # Reset environment
export RUBYLIB=$CURRENT_RUBYLIB
export RUBYOPT=$CURRENT_RUBYOPT
export BUNDLE_GEMFILE=$CURRENT_BUNDLE_GEMFILE
export BUNDLE_WITHOUT=$CURRENT_BUNDLE_WITHOUT

echo "*** Re-set environment ***"
env | sort
echo "---------------"

# Now check for old results, datapoints and analyses and remove them.
# These do not consume a lot of disk space but there can be a lot of files. The last check (data points)
#  can be quite time consuming.
# Recover current list of analyses from the server (this is a massive json string).
echo -e "${GREEN}Recovering analyses.json from localhost${NC}..."
STEP="${GREEN}Recovering analyses.json${NC}"
analysesDB=$(curl http://web:80/analyses.json)
#echo $analysesDB

# Gather list of analyses on this node (that have potentially been left in the assets folder).
echo -e "${GREEN}Recovering analyses from server${NC}..."
foundAnalyses+=$(ls -1 /mnt/openstudio/server/assets/analyses)

# Check these against the analyses in the json recovered from the server; if there is a match then keep.
for analysisUUID in $foundAnalyses
do
   if [[ $analysesDB == *$analysisUUID* ]]; then
     echo -e "${BLUE}Keeping analysis:${NC} $analysisUUID"
   else
     toDelete+="analysis/"$analysisUUID" "
   fi
done

# Now check the results folder. These are named by analysis UUID.
foundResults+=$(ls -1 /mnt/openstudio/server/assets/results)

# Check these against the analyses in the json recovered from the server; if there is a match then keep.
for resultsUUID in $foundResults
do
   if [[ $analysesDB == *$resultsUUID* ]]; then
     echo -e "${BLUE}Keeping analysis:${NC} $resultsUUID"
   else
     toDelete+="results/"$resultsUUID" "
   fi
done

# Gather list of result zip files on this node (that have potentially been left in the assets folder).
echo -e "${GREEN}Recovering results zip files from server${NC}..."
foundResultZips+=$(ls -1 /mnt/openstudio/server/assets/results.*.zip)

# Check these against the analyses in the json recovered from the server; if there is a match then keep.
for resultZip in $foundResultZips
do
   uuid=$(echo $resultZip | cut -d'.' -f 2)
   if [[ $analysesDB == *$uuid* ]]; then
     echo -e "${BLUE}Keeping results zip:${NC} $uuid"
   else
     toDelete+="results."$uuid".zip "
   fi
done

# Now check the data_points folder. These are named by data_points ID.
datapointsDB=$(curl http://web:80/data_points.json)
foundDatapoints+=$(ls -1 /mnt/openstudio/server/assets/data_points)

# Check these against the values in the json recovered from the server; if there is a match then keep.
for datapointsID in $foundDatapoints
do
   if [[ $datapointsDB == *$datapointsID* ]]; then
     echo -e "${BLUE}Keeping datapoint:${NC} $datapointsID"
   else
     toDelete+="data_points/"$datapointsID" "
   fi
done

echo -e "${GREEN}Files to delete:${NC} $toDelete"

echo -e "${GREEN}Deleting selected files${NC}..."
STEP="${GREEN}Deleting selected files${NC}"
echo -e "${BLUE}Existing disk space:${NC}"
df -h .
for id in $toDelete
do
  echo "Removing ${id} from assets folder"
  rm -rf /mnt/openstudio/server/assets/${id}
done
echo -e "${BLUE}Final disk space:${NC}"
df -h .

echo -e "${GREEN}DONE.${NC}"
