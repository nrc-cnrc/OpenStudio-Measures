#!/usr/bin/env ruby

require 'rest-client'
require 'optparse'
require 'json'
require 'colored'

# General notes for server scripts.
#    To test the script run a PAT simulation then log onto the web container
#      cd to /mnt/openstudio/scripts
#      Grab the analysis UUID (either from the web interface or from the shared folders)
#      Run the script with the -a option specifying the UUID
#    For functions available to recover info from the server see:
#      https://github.com/NREL/OpenStudio-server/blob/develop/server/config/routes.rb
#      specifically any method with a 'get:' infront of it (should hyperlink to the method)

# This renames the simulation cases in the analysis db based on the cases simulated
#
# @param required_analysis_id [:string] analysis uuid to retrieve files for
def rename_datapoint(required_analysis_id)

  puts "Renaming simulations in db".cyan
  
  # This returns all the datapoints on the server.
  datapoints = JSON.parse(RestClient.get("http://web:80/data_points.json", headers={}))
  
  # Ensure there are datapoints to work with
  if datapoints.nil? || datapoints.empty?
    fail "ERROR: No datapoints found.".red
  end
  
  # Loop through the data points and find the ones associated with the specified analysis.
  datapoints.each do |dp|
	id = dp['_id']
	analysis_id = dp['analysis_id']
	#puts "Data point ID #{id}".red
	#puts "Analysis ID #{analysis_id}".yellow
	#puts "            #{required_analysis_id}".green
	next if analysis_id != required_analysis_id # Skip if data point is not one from the required analysis.
	
	puts "Renaming datapoint ID #{id}".green
	variables = dp['set_variable_values']
	name = ""
	variables.each_value {|value| name << "#{value}:"}
	puts "Name: #{name}".yellow
	puts "Datapoint[name]: #{dp['name']}".green
	
	# Update the case name in the DB.
	dp.merge!({'name' => name})
	puts "Datapoint name (updated): #{dp['name']}".cyan
	# Save the new datapoint name to the db.
	#puts "#{dp.to_json}".green
	RestClient.put "http://web:80/data_points/#{id}.json", dp.to_json, {content_type: :json, accept: :json}
  end
end


#
# Main body of the script.
#

options = {}

# Define allowed ARGV input.
# -a --analysis_id [string]
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage:    gather_results [-a] <analysis_id> -h]'

  options[:analysis_id] = nil
  opts.on('-a', '--analysis_id <uuid>', 'specified analysis UUID') do |uuid|
    options[:analysis_id] = uuid
  end

  opts.on_tail('-h', '--help', 'display help') do
    puts opts
    exit
  end
end

# Execute ARGV parsing into options hash holding symbolized key values.
optparse.parse!

# Sanity check inputs.
uuid = options[:analysis_id]
fail 'ERROR: Analysis UUID not specified' if uuid.nil?
puts "Gathering pricing templates from analysis #{uuid}".cyan

# Gather the required files.
rename_datapoint(uuid)

# Finish up
puts "SUCCESS".green
