#!/bin/bash
source ../env.sh

:> measures_to_test-all.txt  # Empty contents of file

# Generate a list of the measures.
measures=(`ls -1 ../measures`)
measures+=(`ls -1 ../measures_templates`)

echo "measures >>>>> ${measures[@]}"

for measure in "${measures[@]}";
do
# Generate a list of tests for this measure.
tests=(`cd ../measures/${measure}/tests && ls -1 *rb`)  # Some measures have more than one test

if [ -d "../measures/${measure}/tests" ] 
then
	tests=(`cd ../measures/${measure}/tests && ls -1 *rb`)
else
	tests=(`cd ../measures_templates/${measure}/tests && ls -1 *rb`)
fi

done

for measure in "${measures[@]}";
do
# Generate a list of tests for this measure.
path="../measures/${measure}/tests"
if [ -d "$path" ] 
then
	tests=(`cd ../measures/${measure}/tests && ls -1 *rb`)
else
    path="../measures_templates/${measure}/tests"
	tests=(`cd ../measures_templates/${measure}/tests && ls -1 *rb`)
fi
for file in `ls $path/*.rb`
 do
  file2="$( cut -d '/' -f 2- <<< "$file" )"; # it creates a file that starts with ../measures/, so cut would only copy the string after '/'
  #So for example : measures/nrc_doas_vrf/tests/test.rb instead of ../measures/nrc_doas_vrf/tests/test.rb
  printf '%s\n' "$file2" >> measures_to_test-all.txt 
 done
done



 


 


