The measures and server scripts in this repository rely on other open source projects. These other repositories 
are under active development, notably OpenStudio and OpenStudio standards. From time to time it will be necessary 
to update the version of the repositories referenced here.

### OpenStudio-Standards
This is the key repository referenced here. This repository uses the nrcan_nrc branch which is derived from the nrcan 
branch. Our colleagues at NRCan maintain their branch to a specific version of OpenStudio.

Two update processes can occur:
1) The nrcan branch on openstudio-server is updated with new features from NRCan and we want/need to merge these changes 
into the nrcan_nrc branch. This is likely the more frequent and easier update to manage.
2) The nrcan branch is updated to include features from NREL. This is likely to involve updating the version of openstudio-server 
and will be a more complex process. 

## Update process

# NRCan feature inclusion/no openstudio-server update
Essentially the update proces is a merge of the nrcan branch of openstudio-standards into the nrc branch. 

1) Edit the env.sh file to use the nrcan branch of openstudio-standards
2) Create the test environment and run all the tests
    a) Resolve all errors
	    - You may need to add gems to the Gemfile
		- You may need to update the version of OpenStudio referenced
		- You may need to edit measures if the functions in openstudio-standards have changed
3) Create an instance of the server and run a full NECB analysis
    a) Check for differences in output from this run
	b) Document resons for changes (e.g. improved algorithm, different zoning assumptions)
	
Once the tests have passed git merge the nrcan branch into the nrcan_nrc branch and create a pull request 
(currently Iain can action this).

Revert the env.sh file back to using the nrcan_nrc branch and run the tests again (just to be sure that any 
differences we have in the nrcan_nrc branch do not cause issues).

# NREL feature inclusion/openstudio-server update
This is the more complex update and could include changes not described here. These steps are liekly a minimum 
to get the new version working.

1) Edit the env.sh file to:
    a) use the nrcan branch of openstudio-standards
	b) reference the new version of openstudio-server
2) Launch the openstudio-server containers. If/when these fail look at the openstudio-server code for the tag being used (e.g. v3.2.1):
    a) Check the docker-compose.yml file for updates and edit the local openstudio-server/docker-compose.yml file to match
	b) Check the .env file for updates and edit the environmental variables section of env.sh (around line 60)