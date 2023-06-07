# Default source for gems
source 'http://rubygems.org'
ruby "~> 2.7.0"

# Openstudio gems required to run the tests. Versions specified in the install scripts (for tests) and 
# the specific versions downloaded into the .gems folder in this repo. They are then copied into the 
# /var/gems folder on the container for use by bundle (see install_gems in env.sh).
gem 'openstudio-standards', :path => './.gems'
#gem 'openstudio-extension', :path => '/var/gems'

# Required for the test script.
gem 'ruby-progressbar'
gem 'parallel'
gem 'minitest'

# Cannot have any gems here that have pre-compiled components. e.g. nokogiri
# Additional gems required for measures.
gem 'aws-sdk-s3'
gem 'git-revision'
gem 'diffy'
gem 'roo', '~> 2.8'
