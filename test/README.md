# Testing Environment
This folder contains the scripts used to run automated tests locally. Before submitting a merge request, test should be completed 
and all errors resolved!

## Requirements

As mentioned in the main README the testing environment uses Docker containers. By default the testing environment uses 1/2 of the available cores on the host computer. 

## Running tests

1) Variables are set in the env.sh file. These will be used by the subsequent scripts and you should not need to adjust them. 
2) The test environmnet is split into two parts: 
  
  - Configure the Docker container (this pulls the docker image for OpenStudio, sets up the docker container and downloads additional ruby gems) 

    - Script _1-initialise_test_environment.sh_ will use the dockerhub image by default. Use the -i flag to specify the local image file if you want to use that instead.
    - This script is only run once to configure the environment. Once configured only script 2 or 3 needs to be used to re-run the tests.


- Run the tests (this checks for updates to the gems and then runs the tests).
    - Script _2-run_tests.sh_ will run all the tests.
    - Script _3-run_single_tests.sh_ will prompt for which test to run (or use command line options to specify test).


  Note the output from the tests. If a test fails read the output messages to determine why and update the measures.

  While developing a measure you may want to use script 3 which allows a single test script to be exercised.

## Modifying existing tests
If you've made changes to the measure, make sure the existing tests will cover the changes. You may need to update them or add new ones.

## Creating and adding new tests
A template for the test can be found in the same folder as the [measures_template](measures_templates/NrcTemplateMeasure/tests). Have a look at OpenStudio's [measure writing guide](https://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/#measure-testing) for guidelines on writing tests. You might also want to look at existing tests to understand how they work e.g. [nrc_change_cav_to_vav](/measures/nrc_change_cav_to_vav/tests).

After creating the test, add it to [/measures_to_test.txt](test/measures_to_test.txt) file so that it can be automatically run later.

## Additional scripts

Two additional scripts exist:

1) _write_all_test_names.sh_ scans the measures folder to generate a complete list of measure tests. The output is placed in the 
file _measures_to_test-all.txt_ and can be used to update _measures_to_test.txt_.
2) _run_openstudio_standards_tests.sh_ is a convenience wrapper to run the NECB related tests for the openstudio-standards gem. 
The only two choices offered are for the NECB related code in openstudio-standards.


