#!/bin/bash
STEP="Initializing"
source ./../env.sh

# Error message in case of failure
trap '[ "$?" -eq 0 ] || read -p "$? Looks like something went wrong in step ´$STEP´... Press enter to continue..."' EXIT

# Loop through the workers and remove the datapoint folders. These are left behind when an analysis is deleted.

echo -e "${GREEN}Recovering worker IDs from docker${NC}..."
STEP="${GREEN}Recovering worker IDs from docker${NC}"
workerIDs=$(docker ps -q -f name=${PWD##*/}"-worker-")
echo -e "${BLUE}Worker IDs:${NC}\n$workerIDs"

# Recover current list of analyses from the server (this is a massive json string).
echo -e "${GREEN}Recovering analyses.json from localhost${NC}..."
STEP="${GREEN}Recovering analyses.json${NC}"
analyses=$(curl http://localhost:8080/analyses.json)
#echo $analyses

# Gather list of analyses on the workers.
echo -e "${GREEN}Recovering analyses from worker containers${NC}..."
STEP="${GREEN}Recovering analyses from worker containers${NC}"
for worker in $workerIDs
do
  workerAnalyses+=$(docker exec ${worker} sh -c 'ls -1 /mnt/openstudio' | grep analysis )
  workerAnalyses+=" "
done
sorted_unique_workerAnalyses=$(echo "${workerAnalyses[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

for analysis in $sorted_unique_workerAnalyses
do
   uuid=$(echo $analysis | cut -d'_' -f 2) 
   if echo $analyses | grep -q "$uuid"; then
     echo -e "${BLUE}Keeping analysis:${NC} $analysis"
   else
     toDelete+=$uuid
     toDelete+=" "
   fi
done

echo -e "${GREEN}Analysis UUIDs to delete:${NC} $toDelete"

echo -e "${GREEN}Deleting selected analyses${NC}..."
STEP="${GREEN}Deleting selected analyses${NC}"
echo -e "${BLUE}Existing disk space:${NC}"
docker exec ${PWD##*/}"_worker_1" sh -c 'df -h .'
for worker in $workerIDs
do
  for id in $toDelete
  do
    echo "Removing analysis_${id} from worker ${worker}"
    docker exec ${worker} sh -c 'rm -rf /mnt/openstudio/analysis_'${id}
  done
done
echo -e "${BLUE}Final disk space:${NC}"
docker exec ${PWD##*/}"-worker-1" sh -c 'df -h .'

echo -e "${GREEN}DONE.${NC}"
