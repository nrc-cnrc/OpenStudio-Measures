#!/bin/bash

# Script to create the docker images.
source ../env.sh

# Create the script file that sed will use to update the template.
# Using + in place of / so that paths etc will work.
echo s+{os_image}+${os_image}+ > .script.sed
echo s+{gemDir}+${gemDir}+ >> .script.sed

# Update the template Dockerfile with the current settings from env.sh
sed -f .script.sed .docker/Dockerfile-template > .docker/Dockerfile

# Create the image
docker build -t nrcconstructioncnrc/${os_image} .docker

# Save the image locally (for quick and easy use with docker load). Need to remove the : from the file name.
docker save nrcconstructioncnrc/${os_image} | gzip > ${os_image//[:]/-}.tar.gz

# Note about pushing to web.
echo "To push to the repo use: docker push nrcconstructioncnrc/${os_image}"
