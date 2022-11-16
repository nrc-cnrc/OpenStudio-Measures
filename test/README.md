This folder contains the scripts used to run automated tests locally. Before submitting a merge request the test should be completed 
and all errors resolved!

### Requirements

As mentioned in the main README the testing environment uses Docker containers. By default the testing uses 2/3 of the available cores 
on the host computer. 

### Usage

a) Variables are set in the env.sh file. These will be used by the subsequent scripts and you should not need to adjust them. 
b) The test environmnet is split into two parts: 
  1) Configure the Docker container (this puls the docker image for openstudio and sets up the docker container including 
  downloads additional ruby gems).
    - Script _0-create_docker_image.sh_ is used to ceate a base docker image from the NREL/openstudio image. This is used to
      create the image on dockerhub. The script also creates a local image that can be used directly with the next script.
    - Script _1-initialise_test_environment.sh_ will use the dockerhub image by default. Use the -i flag to specify the local 
      image file if you want to use that instead.
  2) Run the tests (this checks for updates to the gems and then runs the tests).
    - Script _2-run_tests.sh_ will run all the tests.
    - Script _3-run_single_tests.sh_ will prompt for which test to run (or use command line options to specify test).
c) When first configuring the environment run the first two scripts in order. Once configured only script 2 needs to be used 
to re-run the tests.

Note the output from the tests. If a test fails read the output messages to determine why and update the measures.

While developing a measure you may want to use script 3 which allows a single test script to be exercised.

### Additional scripts

Two additional scripts exist:

1) _write_all_test_names.sh_ scans the measures folder to generate a complete list of measure tests. The output is placed in the 
file _measures_to_test-all.txt_ and can be used to update _measures_to_test.txt_.
2) _run_openstudio_standards_tests.sh_ is a convenience wrapper to run the NECB related tests for the openstudio-standards gem. 
The only two choices offered are for the NECB related code in openstudio-standards.

### Git note

When running all the tests the _measure.xml_ and the _README.md_ (in the measure folder) files will all be updated. To easily add 
these files to the repo the git command is:

>git add -- \\*measure.xml \\*README.md

these changes should then be committed with the message:

>git commit -m 'automatic updates from running tests'

