This folder contains the scripts used to run automated tests locally. Before submitting a merge request the test should be completed 
and all errors resolved!

### Requirements

As mentioned in the main README the testing environment uses Docker containers. By default the testing uses 2/3 of the available cores 
on the host computer. 

### Usage

a) Variables are set in the env.sh file. These will be used by the subsequent scripts and you should not need to adjust them. 
b) The test environmnet is split into two parts: 
  1) Configure the Docker container (this puls the docker image for openstudio and sets up the docker container including downloads additional ruby gems).
  2) Run the tests (this checks for updates to the gems and then runs the tests).
c) When first configuring the environment run all three scripts in order. Once configured only script 2 needs to be used to re-run the tests.

Note the output from the tests. If a test fails read the output messages to determine why and update the measures.

### Git note

When running all the tests the _measure.xml_ and teh _README.md_ (in the measure folder) files will all be updated. To easily add these files 
to the repo the git command is:

>git add -- \*measure.xml

these changes should then be committed with the message:

>git commit -m 'automatic updates from running tests'
