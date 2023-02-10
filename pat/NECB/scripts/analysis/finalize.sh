#!/bin/bash -e
# Copy scripts to the server that are optionally used at end of simulation (with an analysis finalization script).
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

#Add all names of finalization scripts to an array 
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
