#!/bin/bash -e
# Copy scripts to the server that are optionally used at end of simulation (with an analysis finalization script).
echo -e "${GREEN}Copying optional finalization scripts to server${NC}..."
      
# NRC server setup has the ruby files in this location.
cd /mnt/openstudio/scripts
bundle install

#Add all names of finalization scripts to an array 
for file in $(ls -1)
 do
  arr_scripts+=($file)
 done
 
 num_scripts=${#arr_scripts[@]}
 echo -e "${GREEN}There are $num_scripts scripts added to arr_script ${arr_scripts[@]} ${NC}."
   
i=0
while [ $i -lt $num_scripts ]
 do
  echo "Starting script number $i : ${arr_scripts[$i]}"
  
  # An OR statement is added to catch any errors that causes the script to terminate and doesn't run the following script in the Server folder
  bundle exec ruby ${arr_scripts[$i]} -a $ANALYSIS_ID || echo "An error occured in $i script : ${arr_scripts[$i]}, will skip to the following script"
  i=$(( $i + 1 ))
 done
