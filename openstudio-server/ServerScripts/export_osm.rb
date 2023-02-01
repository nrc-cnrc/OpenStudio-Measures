#!/usr/bin/env ruby

require 'rest-client'
require 'fileutils'
require 'tempfile'
require 'zip'
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

# Gather the required files from the server for an analysis
#
# @param required_analysis_id [:string] analysis uuid to retrieve files for.
def gather_osm_files(required_analysis_id)
  puts "Gathering output results".cyan
  
  # Ensure required directories exist and create if appropriate.
  basepath = '/mnt/openstudio/server/assets/data_points'
  unless Dir.exists? basepath
    fail "ERROR: Unable to find base data point path #{basepath}".red
  end
  
  # Define and create folders where files will be placed.
  outputpath = "/mnt/openstudio/server/assets/results/#{required_analysis_id}/osm_files/" 
  puts "Creating output folder for osm files: #{outputpath}".green
  unless Dir.exists? outputpath
    FileUtils.mkdir_p outputpath
  end
  weatherpath = "/mnt/openstudio/server/assets/results/#{required_analysis_id}/osm_files/weather" 
  puts "Creating output folder for weather files: #{weatherpath}".green
  unless Dir.exists? weatherpath
    FileUtils.mkdir_p weatherpath
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
	puts "Extracting osm file from data point ID #{id}".green
	
	# The file we want is in the datapoint.zip file. Grab this.
	dpZipRaw = RestClient.get("http://web:80/data_points/#{id}/download_result_file", {params: {filename: 'data_point.zip'}})
	dpZip = Zip::File.open_buffer(dpZipRaw.body)
	osm = ""
	
	# This is more generic than required but checks that the osm file is in the zip file.
	dpZip.each do |entry|
	  #puts "#{entry.name}".green
	  if entry.name == "in.osm"
	    osm = entry.name
	    #puts "#{entry.name}".yellow
	  end
	end
	
	# If we found the in.osm then write to the output folder and fix the weather file.
	if !osm.empty?
	  osm_file = dpZip.find_entry(osm)
	  	
	  # Get the datapoint name (to use as the osm file name).
	  name = dp['name']
      f_path = File.join(outputpath, "#{name}.osm")
      dpZip.extract(osm_file.name, f_path){true} # Overwrite if existing file.
	  
	  # Now scan the extracted osm file for the weather file. Need to use a temporary file.
      temp_file = Tempfile.new('foo')
	  begin 
	    File.open(f_path).each do |line|
	      # Fine the weather file line and edit. (Note the osm file will still complain when read into the app)
          if line.match?(/.epw, !- Url$/)
		    weather_file_path = line.split(',').first.strip
	        puts "Found the weather file **#{weather_file_path}**".yellow
		    weather_file = weather_file_path.split('/').last
	        puts "Weather file #{weather_file}".red
		    FileUtils.cp(weather_file_path, weatherpath)
			line = "  ./weather/#{weather_file}, !- Url"
		  end
		  temp_file.puts line
	    end
		temp_file.close
        FileUtils.mv(temp_file.path, f_path)
	  ensure
        temp_file.close
        temp_file.unlink
	  end
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
  opts.banner = 'Usage:    export_osm [-a] <analysis_id> -h]'

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
puts "Gathering osm models and weather files from analysis #{uuid}".cyan

# Gather the required files.
Zip.warn_invalid_date = false
gather_osm_files(uuid)

# Finish up
puts "SUCCESS".green
