#!/bin/bash -e
# For this worker remove the datapoint run folder from orphaned analyses. 
# These are left behind when an analysis is deleted.

# SCRIPT_DATA_POINT_ID - environment variable that holds the data_point ID
# SCRIPT_ANALYSIS_ID - environment variable that holds the analysis ID

echo -e "Existing disk space:"
df -h .

echo "Removing the data_point files from worker run directory with SCRIPT_ANALYSIS_ID ${SCRIPT_ANALYSIS_ID} : and  SCRIPT_DATA_POINT_ID : ${SCRIPT_DATA_POINT_ID}"
rm -rf /mnt/openstudio/analysis_${SCRIPT_ANALYSIS_ID}/data_point_${SCRIPT_DATA_POINT_ID}/run/*

echo -e "Final disk space:"
df -h .

echo -e "DONE."
