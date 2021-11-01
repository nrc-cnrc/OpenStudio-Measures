#!/usr/bin/env ruby

require 'rest-client'
require 'fileutils'
require 'zip'
require 'optparse'
require 'json'
require 'colored'


# Gather the required files from each zip file on the server for an analysis
#
# @param aid [:string] analysis uuid to retrieve files for
def gather_output_results(aid)

  puts "Gathering output results".cyan
  
  # Ensure required directories exist and create if appropriate
  basepath = '/mnt/openstudio/server/assets/data_points'
  unless Dir.exists? basepath
    fail "ERROR: Unable to find base data point path #{basepath}".red
  end
  resultspath = "/mnt/openstudio/server/assets/results/#{aid}/osw_files/" ## DO NOT MODIFY THIS PATH OR FILENAME
  outputpath = "/mnt/openstudio/server/assets/results/#{aid}/"            ## DO NOT MODIFY THIS PATH OR FILENAME

  simulations_json_folder = outputpath

  FileUtils.mkdir_p(outputpath)
  osw_folder = "#{outputpath}/osw_files"
  FileUtils.mkdir_p(osw_folder)
  output_folder = "#{outputpath}/output"
  FileUtils.mkdir_p(output_folder)
  File.open("#{outputpath}/missing_files.log", 'wb') { |f| f.write("") }
  File.open("#{outputpath}/missing_files.log", 'w') {|f| f.write("") }
  File.open("#{simulations_json_folder}/simulations.json", 'w'){}

  puts "creating results folder #{resultspath}"
  unless Dir.exists? resultspath
    FileUtils.mkdir_p resultspath
  end

  # Determine all data points to download from the REST API
  astat = JSON.parse RestClient.get("http://web:80/analyses/#{aid}/status.json", headers={})
  dps = astat['analysis']['data_points'].map { |dp| dp['id'] }
  #puts "#{astat}".yellow
  #puts "#{dps}".green
  
  variables = JSON.parse(RestClient.get("http://web:80/analyses/#{aid}/variables.json", headers={}))
  puts "#{variables}".yellow
  variables.each do |var|
    puts "#{var['perturbable']}"
	if var['perturbable'] then
	  puts "#{var['display_name']}".green
	end
  end
  
  datapoints = JSON.parse(RestClient.get("http://web:80/analyses/#{aid}/data_points.json", headers={}))
  
  # Ensure there are datapoints to work with
  if datapoints.nil? || datapoints.empty?
    fail "ERROR: No datapoints found. Analysis #{aid} completed with no datapoints".red
  end
  
  # Figure out a unique name for each case based on the variable values.
  datapoints.each do |dp|
	id = dp['_id']
	variables = dp['set_variable_values']
	name = ""
	variables.each_value {|value| name << value}
	puts "#{name}".yellow
	puts "#{dp['name']}".green
	
	# Update the case name in the DB.
	puts "#{dp}".cyan
	dp.merge!({'name' => name})
	#puts "http://web:80/data_points/#{id}.json".green
	# This works (saving the new datapoint name to the db.
	#puts "#{dp.to_json}".green
	RestClient.put "http://web:80/data_points/#{id}.json", dp.to_json, {content_type: :json, accept: :json}
	
	# Try and find a pricing template csv. This should add it to the datapoint results.
	puts "#{id}".red
	# The files we want are in the datapoint.zip file. Grab this.
	
	dpZipRaw = RestClient.get("http://web:80/data_points/#{id}/download_result_file", {params: {filename: 'data_point.zip'}})
	#puts "#{dpZipRaw.class}".yellow
	#puts "#{dpZipRaw.body.class}".red
	dpZip = Zip::File.open_buffer(dpZipRaw.body)
	#puts "#{dpZip.class}".cyan
	pricing_template_file = ""
	pricing_warnings_file = ""
	dpZip.each do |entry|
	  puts "#{entry.name}".green
	  if entry.name.include? "pricing_template.csv"
	    pricing_template_file = entry.name
	    puts "#{entry.name}".yellow
	  elsif entry.name.include? "pricing_warnings.txt"
	    pricing_warnings_file = entry.name
	    puts "#{entry.name}".yellow
	  end
	end
	
	# Pricing templates.
	if !pricing_template_file.empty?
	  pricing_template = dpZip.find_entry(pricing_template_file)
	  puts "#{pricing_template.class}".cyan
	  puts "#{pricing_template.name}".yellow
	
      f_path = File.join(outputpath, "pricing_template-#{name}.csv")
      FileUtils.mkdir_p(File.dirname(f_path))
      dpZip.extract(pricing_template.name, f_path) unless File.exist?(f_path) # No overwrite
	end
	
	# Missing components files.
	if !pricing_warnings_file.empty?
	  pricing_template = dpZip.find_entry(pricing_warnings_file)
	  puts "#{pricing_template.class}".cyan
	  puts "#{pricing_template.name}".yellow
	
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
