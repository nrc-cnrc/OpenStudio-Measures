#!/usr/bin/env ruby

require 'rest-client'
require 'fileutils'
require 'zip'
require 'optparse'
require 'json'
require 'colored'


# Gather the required files from each zip file on the server for an analysis
#
# @param required_analysis_id [:string] analysis uuid to retrieve files for
def gather_output_results(required_analysis_id)

  puts "Gathering output results".cyan
  
  # Ensure required directories exist and create if appropriate.
  basepath = '/mnt/openstudio/server/assets/data_points'
  unless Dir.exists? basepath
    fail "ERROR: Unable to find base data point path #{basepath}".red
  end
  
  # Define and create folders where files will be placed.
  outputpath = "/mnt/openstudio/server/assets/results/#{required_analysis_id}/pricing_files/" 
  puts "Creating output folder for osm files: #{outputpath}".green
  unless Dir.exists? outputpath
    FileUtils.mkdir_p outputpath
  end
  
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
	
	# Try and find a pricing template csv. This should add it to the datapoint results.
	puts "Datapoint ID #{id}".green

	# Get the datapoint name (to use as the output file name).
	name = dp['name']
	
	# The files we want are in the datapoint.zip file. Grab this.
	dpZipRaw = RestClient.get("http://web:80/data_points/#{id}/download_result_file", {params: {filename: 'data_point.zip'}})
	#puts "#{dpZipRaw.class}".yellow
	#puts "#{dpZipRaw.body.class}".red
	dpZip = Zip::File.open_buffer(dpZipRaw.body)
	#puts "#{dpZip.class}".cyan
	pricing_template_file = ""
	pricing_warnings_file = ""
	puts "Scanning zip file for pricing outputs...".green
	dpZip.each do |entry|
	  #puts "#{entry.name}".green
	  if entry.name.include? "pricing_template.csv"
	    pricing_template_file = entry.name
	    puts "Found #{entry.name}".green
	  elsif entry.name.include? "pricing_warnings.txt"
	    pricing_warnings_file = entry.name
	    puts "Found #{entry.name}".green
	  end
	end
	  
	# Pricing templates.
	if !pricing_template_file.empty?
	  pricing_template = dpZip.find_entry(pricing_template_file)
	  #puts "#{pricing_template.class}".cyan
	  #puts "#{pricing_template.name}".yellow
	
      f_path = File.join(outputpath, "pricing_template-#{name}.csv")
      FileUtils.mkdir_p(File.dirname(f_path))
      dpZip.extract(pricing_template.name, f_path) unless File.exist?(f_path) # No overwrite
	end
	
	# Missing components files.
	if !pricing_warnings_file.empty?
	  pricing_template = dpZip.find_entry(pricing_warnings_file)
	  #puts "#{pricing_template.class}".cyan
	  #puts "#{pricing_template.name}".yellow
	
      f_path = File.join(outputpath, "pricing_warnings-#{name}.txt")
      FileUtils.mkdir_p(File.dirname(f_path))
      dpZip.extract(pricing_template.name, f_path) unless File.exist?(f_path) # No overwrite
	end
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
Zip.warn_invalid_date = false
gather_output_results(uuid)

# Finish up
puts "SUCCESS".green
