#!/bin/bash -e
# For this worker remove the datapoint folders from orphaned analyses. 
# These are left behind when an analysis is deleted.

# Recover current list of analyses from the server (this is a massive json string).
echo -e "${GREEN}Recovering analyses.json from localhost${NC}..."
STEP="${GREEN}Recovering analyses.json${NC}"
analyses=$(curl http://web:80/analyses.json)
#echo $analyses

# Gather list of analyses on the workers.
echo -e "${GREEN}Recovering analyses from worker${NC}..."
workerAnalyses+=$(ls -1 /mnt/openstudio | grep analysis )

# Check these against the analyses in the json recovered from the server; if there is a match then keep.
for analysis in $workerAnalyses
do
   uuid=$(echo $analysis | cut -d'_' -f 2) 
   if [[ $analyses == *$uuid* ]]; then
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
df -h .
for id in $toDelete
do
  echo "Removing analysis_${id} from worker ${worker}"
  rm -rf /mnt/openstudio/analysis_${id}
done
echo -e "${BLUE}Final disk space:${NC}"
df -h .

echo -e "${GREEN}DONE.${NC}"
