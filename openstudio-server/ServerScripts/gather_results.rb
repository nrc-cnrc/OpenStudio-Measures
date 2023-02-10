#!/usr/bin/env ruby
# CLI tool to allow for creating a version of the localResults directory on the server
# This should be employed as a server finalizations script for BuildStock PAT projects
# Written by Henry R Horsey III (henry.horsey@nrel.gov)
# Created October 5th, 2017
# Last updated on October 6th, 2017
# Copywrite the Alliance for Sustainable Energy LLC
# License: BSD3+1

require 'rest-client'
require 'fileutils'
require 'zip'
require 'parallel'
require 'optparse'
require 'json'
require 'base64'
require 'colored'
require 'csv'

# Unzip an archive to a destination directory using Rubyzip gem
#
# @param archive [:string] archive path for extraction
# @param dest [:string] path for archived file to be extracted to
def unzip_archive(archive, dest)
  # Adapted from examples at...
  # https://github.com/rubyzip/rubyzip
  # http://seenuvasan.wordpress.com/2010/09/21/unzip-files-using-ruby/
  Zip::File.open(archive) do |zf|
    zf.each do |f|
      f_path = File.join(dest, f.name)
      if (f.name == 'enduse_timeseries.csv') || (f.name == 'measure_attributes.json')
        FileUtils.mkdir_p(File.dirname(f_path))
        zf.extract(f, f_path) unless File.exist?(f_path) # No overwrite
      end
    end
  end
end

# Gather the required files from each zip file on the server for an analysis
#
# @param aid [:string] analysis uuid to retrieve files for
def gather_output_results(aid)
  # Ensure required directories exist and create if appropriate
  basepath = '/mnt/openstudio/server/assets/data_points'
  unless Dir.exists? basepath
    fail "ERROR: Unable to find base data point path #{basepath}"
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

  # Ensure there are datapoints to download
  if dps.nil? || dps.empty?
    fail "ERROR: No datapoints found. Analysis #{aid} completed with no datapoints"
  end

  # Find all data points asset ids
  assetids = {}
  dps.each do |dp|
    begin
      dp_res_files = JSON.parse(RestClient.get("http://web:80/data_points/#{dp}.json", headers={}))['data_point']['result_files']
      puts dp_res_files
      if dp_res_files.nil?
        puts "Unable to find related files for data point #{dp}"
      else
        osws = dp_res_files.select { |file| file['attachment_file_name'] == "out.osw" }
        if osws.empty?
          puts "No osw files found attached to data point #{dp}"
        elsif osws.length > 1
          puts "More than one osw file is attached to data point #{dp}, skipping"
        else
          assetids[dp] = osws[0]['_id']['$oid']
        end
      end
    rescue RestClient::ExceptionWithResponse
      puts "Unable to retrieve json from REST API for data point #{dp}"
    end
  end

  # Register and remove missing datapoint zip files
  available_dps = Dir.entries basepath
  missing_dps = []
  dps.each { |dp| missing_dps << dp unless available_dps.include? assetids[dp] }
  puts "Missing #{100.0 * missing_dps.length.to_f / dps.length}% of data point zip files"
  unless missing_dps.empty?
    logfile = File.join resultspath, 'missing_dps.log'
    puts "Writing missing datapoint UUIDs to #{logfile}"
    File.open(logfile, 'wb') do |f|
      f.write JSON.dump(missing_dps)
    end
  end

  # Only download datapoints which do not already exist
  exclusion_list = Dir.entries resultspath

  assetids.keys.each do |dp|
    unless (exclusion_list.include? dp) || (missing_dps.include? dp)
      uuid = dp
      #OSW file name
      osw_file = File.join(basepath, assetids[dp], 'files', 'original', 'out.osw')
      #The folder path with the UUID of the datapoint in the path.
      write_dir = File.join(resultspath, dp)
      #Makes the folder for the datapoint.
      FileUtils.mkdir_p write_dir unless Dir.exists? write_dir
      #Gets the basename from the full path of of the osw file (Should always be out.osw)
      osw_basename = File.basename(osw_file)
      #Create the new osw file name name.
      new_osw = "#{write_dir}/#{osw_basename}"
      puts new_osw
      #This is the copy command to copy the osw_file to the new results folder.
      FileUtils.cp(osw_file,"#{write_dir}/#{osw_basename}")

      results = JSON.parse(File.read(osw_file))

      # change the output folder directory based on building_type and climate_zone
      # get building_type and climate_zone from create_prototype_building measure if it exists
      results['steps'].each do |measure|
        next unless measure["name"] == "btap_create_necb_prototype_building"
        #template = measure["arguments"]["template"]
        building_type = measure["arguments"]["building_type"]
        #climate_zone = measure["arguments"]["climate_zone"]
        #remove the .epw suffix
        epw_file = measure["arguments"]["epw_file"].gsub(/\.epw/,"")
        output_folder = "#{outputpath}/output/#{building_type}/#{epw_file}"
        #puts output_folder
        FileUtils.mkdir_p(output_folder)
      end

      #parse the downloaded osw files and check if the datapoint failed or not
      #if failed download the eplusout.err and sldp_log files for error logging
      failed_log_folder = "#{output_folder}/failed_run_logs"
      check_and_log_error(results,outputpath,uuid,failed_log_folder, aid)
      extract_data_from_osw(results, output_folder, uuid, simulations_json_folder, aid)

    end
  end
  # close off simulations.json bracket
  File.open("#{simulations_json_folder}/simulations.json", 'a'){|f|
    f.flock(File::LOCK_EX)
    f.write("]")
    f.flock(File::LOCK_UN)
  }
end

# Extract data from the osw file and write it on the disk. This method also calls process_simulation_json method
# which appends the qaqc data to the simulations.json. it only happens if the measure `btap_results` exist with
# `btap_results_json_zip` variable stored as part of the measure

# @param osw_json [:hash] osw file in json hash format
# @param output_folder [:string] parent folder where the data from osw will be extracted to
# @param uuid [:string] UUID of the datapoint
# @param simulations_json_folder [:string] root folder of the simulations.json file
# # @param aid [:string] analysis ID
def extract_data_from_osw(osw_json, output_folder, uuid, simulations_json_folder, aid)
  results = osw_json
  #itterate through all the steps of the osw file
  results['steps'].each do |measure|
    #puts "measure.name: #{measure['name']}"
    meausre_results_folder_map = {
        'openstudio_results':[
            {
                'measure_result_var_name': "eplustbl_htm",
                'filename': "#{output_folder}/eplus_table/#{uuid}-eplustbl.htm"
            },
            {
                'measure_result_var_name': "report_html",
                'filename': "#{output_folder}/os_report/#{uuid}-os-report.html"
            }
        ],
        'btap_view_model':[
            {
                'measure_result_var_name': "view_model_html_zip",
                'filename': "#{output_folder}/3d_model/#{uuid}_3d.html"
            }
        ],
        'btap_results':[
            {
                'measure_result_var_name': "model_osm_zip",
                'filename': "#{output_folder}/osm_files/#{uuid}.osm"
            },
            {
                'measure_result_var_name': "btap_results_hourly_data_8760",
                'filename': "#{output_folder}/8760_files/#{uuid}-8760_hourly_data.csv"
            },
            {
                'measure_result_var_name': "btap_results_hourly_custom_8760",
                'filename': "#{output_folder}/8760_files/#{uuid}-8760_hour_custom.csv"
            },
            {
                'measure_result_var_name': "btap_results_monthly_7_day_24_hour_averages",
                'filename': "#{output_folder}/8760_files/#{uuid}-mnth_24_hr_avg.csv"
            },
            {
                'measure_result_var_name': "btap_results_monthly_24_hour_weekend_weekday_averages",
                'filename': "#{output_folder}/8760_files/#{uuid}-mnth_weekend_weekday.csv"
            },
            {
                'measure_result_var_name': "btap_results_enduse_total_24_hour_weekend_weekday_averages",
                'filename': "#{output_folder}/8760_files/#{uuid}-endusetotal.csv"
            }
        ]
    }

    meausre_results_folder_map.keys.each {|measure_name|
      next unless ( measure["name"].to_s == measure_name.to_s && measure.include?("result") )
      # puts "i'm in #{measure['name'].to_s}"
      measure["result"]["step_values"].each do |values|
        # puts "\t values: #{values}"
        meausre_results_folder_map[measure_name].each {|data_var|
         # puts "\t #{data_var}"
         # puts "\t\t#{values['name'].to_s}\t data_var['measure_result_var_name']: #{data_var['measure_result_var_name']}" 
         if values["name"].to_s == data_var[:measure_result_var_name].to_s
            # puts "\ti'm in #{data_var[:measure_result_var_name]}"
            var_zip_64_string = values['value']
            var_string =  Zlib::Inflate.inflate(Base64.strict_decode64( var_zip_64_string ))
            FileUtils.mkdir_p(File.dirname(data_var[:filename]))
            File.open(data_var[:filename], 'w') {|f| f.write(var_string) }
          end
        }
      end
    }

    # if the measure is btapresults, then extract the osw file and qaqc json
    # While processing the qaqc json file, add it to the simulations.json file
    if measure["name"] == "btap_results" && measure.include?("result")
      measure["result"]["step_values"].each do |values|
        # extract the qaqc json blob data from the osw file and save it
        # in the output folder
        next unless values["name"] == 'btap_results_json_zip'
        btap_results_json_zip_64 = values['value']
        json_string =  Zlib::Inflate.inflate(Base64.strict_decode64( btap_results_json_zip_64 ))
        json = JSON.parse(json_string)
        # indicate if the current model is a baseline run or not
        # json['is_baseline'] = "#{flags[:baseline]}"

        #add ECM data to the json file
        measure_data = []
        results['steps'].each_with_index do |measure, index|
          step = {}
          measure_data << step
          step['name'] = measure['name']
          step['arguments'] = measure['arguments']
          if measure.has_key?('result')
            step['display_name'] = measure['result']['measure_display_name']
            step['measure_class_name'] = measure['result']['measure_class_name']
          end
          step['index'] = index
          # measure is an ecm if it starts with ecm_ (case ignored)
          step['is_ecm'] = !(measure['name'] =~ /^ecm_/i).nil? # returns true if measure name starts with 'ecm_' (case ignored)
        end

        json['measures'] = measure_data

        # add analysis_id and analysis name to the json file
        analysis_json = JSON.parse(RestClient.get("http://web:80/analyses/#{aid}.json", headers={}))
        json['analysis_id']=analysis_json['analysis']['_id']
        json['analysis_name']=analysis_json['analysis']['display_name']

        FileUtils.mkdir_p("#{output_folder}/qaqc_files")
        File.open("#{output_folder}/qaqc_files/#{uuid}.json", 'wb') {|f| f.write(JSON.pretty_generate(json)) }

        # append qaqc data to simulations.json
        # results => osw file
        process_simulation_json(json,simulations_json_folder, uuid, aid, results)
        puts "#{uuid}.json ok"
      end
    end # if measure["name"] == "btapresults" && measure.include?("result")
  end # of grab step files
end


#parse the downloaded osw files and check if the datapoint failed or not
#if failed download the eplusout.err and sldp_log files for error logging
#
# @param results [:hash] contains content of the out.osw file
# @param output_folder [:string] root folder where the csv log needs to be created
# @param uuid [:string] uuid of the datapoint. used to download the sdp log file if the datapoint has failed
# @param failed_output_folder [:string] root folder of the sdp log files
def check_and_log_error(results,output_folder,uuid,failed_output_folder, aid)
  if results['completed_status'] == "Fail"
    FileUtils.mkdir_p(failed_output_folder) # create failed_output_folder
    log_k, log_f = get_log_file(aid, uuid, failed_output_folder)
    # log_k => Boolean which determines if the log file has been downloaded successfully
    # log_f => path of the downloaded log file

    #create the csv file if it does not exist
    # this csv file will contain the building information with the eplusout.err log and the sdp_error log
    File.open("#{output_folder}/failed_run_error_log.csv", 'w'){|f| f.write("") } unless File.exists?("#{output_folder}/failed_run_error_log.csv")

    # output the errors to the csv file
    CSV.open("#{output_folder}/failed_run_error_log.csv", 'a') do |f|
      results['steps'].each do |measure|
        next unless measure["name"] == "btap_create_necb_prototype_building"
        out = {}
        eplus = "" # stores the eplusout error file

        # check if the eplusout.err file was generated by the run
        if results.has_key?('eplusout_err')
          eplus = results['eplusout_err']
          # if eplusout.err file has a fatal error, only store the error,
          # if not entire file will be stored
          match = eplus.to_s.match(/\*\*  Fatal  \*\*.+/)
          eplus = match unless match.nil?
        else
          eplus = "EPlusout.err file not generated by osw"
        end

        log_content = ""
        # ckeck if the log file has been downloaded successfully.
        # if the log file has been downloaded successfully, then match the last ERROR
        if log_k
          log_file = File.read(log_f)
          log_match = log_file.scan(/((\[.{12,18}ERROR\]).+?)(?=\[.{12,23}\])/m)
          #puts "log_match #{log_match}\n\n".cyan
          log_content = log_match.last unless log_match.nil?
          #puts "log_match #{log_match}\n\n".cyan
        else
          log_content = "No Error log Found"
        end

        # write building_type, climate_zone, epw_file, template, uuid, eplusout.err
        # and error log content to the comma delimited file
        out = %W{#{measure['arguments']['building_type']} #{measure['arguments']['template']} #{measure['arguments']['epw_file']} #{uuid} #{eplus} #{log_content}}
        # make the write process thread safe by locking the file while the file is written
        f.flock(File::LOCK_EX)
        f.puts out
        f.flock(File::LOCK_UN)
      end
    end #File.open("#{output_folder}/FAIL.log", 'a')
  end #results['completed_status'] == "Fail"
end

# This method will append qaqc data to simulations.json
#
# @param json [:hash] contains original qaqc json file of a datapoint
# @param simulations_json_folder [:string] root folder of the simulations.json file
# @param osw_file [:hash] contains the datapoint's osw file
def process_simulation_json(json,simulations_json_folder,uuid, aid, osw_file)
  #modify the qaqc json file to remove eplusout.err information,
  # and add separate building information and uuid key
  #json contains original qaqc json file on start

  building_type = ""
  epw_file = ""
  template = ""

  # get building_type, epw_file, and template from btap_create_necb_prototype_building inputs
  # if possible
  osw_file['steps'].each do |measure|
    next unless measure["name"] == "btap_create_necb_prototype_building"
    building_type = measure['arguments']["building_type"]
    epw_file =      measure['arguments']["epw_file"]
    template =      measure['arguments']["template"]
  end

  if json.has_key?('eplusout_err')
    json_eplus_warn = json['eplusout_err']['warnings'] unless json['eplusout_err']['warnings'].nil?
    json_eplus_fatal = json['eplusout_err']['fatal'].join("\n") unless json['eplusout_err']['fatal'].nil?
    json_eplus_severe = json['eplusout_err']['severe'].join("\n") unless json['eplusout_err']['severe'].nil?

    json['eplusout_err']['warnings'] = json['eplusout_err']['warnings'].size
    json['eplusout_err']['severe'] = json['eplusout_err']['severe'].size
    json['eplusout_err']['fatal'] = json['eplusout_err']['fatal'].size
  else
    File.open("#{simulations_json_folder}/missing_files.log", 'a') {|f| f.write("ERROR: Unable to find eplusout_err #{uuid}.json\n") }
  end
  json['run_uuid'] = uuid
  #puts "json['run_uuid'] #{json['run_uuid']}"
  bldg = json['building']['name'].split('-')
  json['building_type'] = (building_type == "" ? (bldg[1]) : (building_type)  )
  json['template'] = (template == "" ? (bldg[0]) : (template)  )

  #write the simulations.json file thread safe
  File.open("#{simulations_json_folder}/simulations.json", 'a'){|f|
    f.flock(File::LOCK_EX)
    # add a [ to the simulations.json file if it is being written for the first time
    # if not, then add a comma
    if File.zero?("#{simulations_json_folder}/simulations.json")
      f.write("[#{JSON.generate(json)}")
    else
      f.write(",#{JSON.generate(json)}")
    end
    f.flock(File::LOCK_UN)
  }

  output_folder = "/mnt/openstudio/server/assets/results/#{aid}/"
  File.open("#{output_folder}/failed_run_error_log.csv", 'w'){|f| f.write("") } unless File.exists?("#{output_folder}/failed_run_error_log.csv")

  # output the errors to the csv file
  CSV.open("#{output_folder}/failed_run_error_log.csv", 'a') do |f|
    begin
      # write building_type, template, epw_file, QAQC errors, and sanity check
      # fails to the comma delimited file
      bldg_type = json['building_type']
      city = (epw_file == "" ? (json['geography']['city']) : (epw_file)  )
      json_error = ''
      json_error = json['errors'].join("\n") unless json['errors'].nil?
      json_sanity = ''
      json_sanity = json['sanity_check']['fail'].join("\n") unless json['sanity_check'].nil?

      # Ignore some of the warnings that matches the regex. This feature is implemented
      # to reduce the clutter in the error log. Additionally, if the number of 
      # lines exceed a limit, excel puts the cell contents in the next row
      regex_patern_match = ['Blank Schedule Type Limits Name input -- will not be validated',
                            'You may need to shorten the names']
      matches = Regexp.new(Regexp.union(regex_patern_match),Regexp::IGNORECASE)
      json_eplus_warn = json_eplus_warn.delete_if {|line| 
        !!(line =~ matches)
      }
      json_eplus_warn = json_eplus_warn.join("\n") unless json_eplus_warn.nil?
      out = %W{#{bldg_type} #{template} #{city} #{json_error} #{json_sanity} #{json_eplus_warn} #{json_eplus_fatal} #{json_eplus_severe} }
      # make the write process thread safe by locking the file while the file is written
      f.flock(File::LOCK_EX)
      f.puts out
      f.flock(File::LOCK_UN)
    rescue => exception
      puts "[Ignore] There was an error writing to the BTAP Error Log"
      puts exception
    end
  end #File.open("#{output_folder}/failed_run_error_log", 'a')
end

# This method will download the status of the entire analysis which includes the datapoint
# status such as "completed normal" or "datapoint failure"
#
# @param datapoint_id [:string] Datapoint ID
# @param file_name [:string] Filename to be downloaded for the datapoint, with extension
# @param save_directory [:string] path of output location, without filename extension
# @return [downloaded, file_path_and_name] [:array]: [downloaded] boolean - true if download is successful; [file_path_and_name] String path and file name of the downloaded file with extension
def get_log_file (analysis_id, data_point_id, save_directory = '.')
  downloaded = false
  file_path_and_name = nil
  unless analysis_id.nil?
    data_points = nil
    resp =  RestClient.get("http://web:80/analyses/#{analysis_id}/status.json", headers={})
    #resp = @conn.get "analyses/#{analysis_id}/status.json"
    puts "status.json OK".green
    puts resp.class.name
    if resp.code == 200
      array = JSON.parse(resp.body)
      #puts JSON.pretty_generate(array)
      data_points = array['analysis']['data_points']
      data_points.each do |dp|
        next unless dp['_id'] == data_point_id
        puts "Checking #{dp['_id']}: Status: #{dp["status_message"]}".green
        log_resp = RestClient.get("http://web:80/data_points/#{dp['_id']}.json", headers={:accept => :json})
        #log_resp = @conn.get "data_points/#{dp['_id']}.json"
        if log_resp.code == 200
          sdp_log_file = JSON.parse(log_resp.body)['data_point']['sdp_log_file']
          file_path_and_name = "#{save_directory}/#{dp['_id']}-sdp.log"
          File.open(file_path_and_name, 'wb') { |f|
            sdp_log_file.each { |line| f.puts "#{line}"  }
          }
          downloaded = true
        else
          puts log_resp
        end
      end
    end
  end
  return [downloaded, file_path_and_name]
end #get_log_file

# Source: https://github.com/rubyzip/rubyzip
# This is a simple example which uses rubyzip to
# recursively generate a zip file from the contents of
# a specified directory. The directory itself is not
# included in the archive, rather just its contents.
#
# Usage:
#   directory_to_zip = "/tmp/input"
#   output_file = "/tmp/out.zip"
#   zf = ZipFileGenerator.new(directory_to_zip, output_file)
#   zf.write()
class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w(. ..)

    ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
      write_entries entries, '', zipfile
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)
      puts "Deflating #{disk_file_path}"

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w(. ..)
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.get_output_stream(zipfile_path) do |f|
      f.write(File.open(disk_file_path, 'rb').read)
    end
  end
end

# Source copied and modified from https://github.com/rubyzip/rubyzip
# creates a zip of the given file and places the zipped file at the
# same location as the file
def zip_single_file(file)
  return false unless File.exist?(file)
  folder = File.dirname(file)
  input_filename = File.basename(file)
  zipfile_name = "#{folder}/#{input_filename}.zip"
  puts "\n\tzipfile_name: #{zipfile_name}"
  ::Zip::File.open(zipfile_name, ::Zip::File::CREATE) do |zipfile|
    zipfile.get_output_stream(input_filename) do |out_file|
      out_file.write(File.open(file, 'rb').read)
    end
  end
end


def start_gather_result(uuid)
  # Initialize optionsParser ARGV hash
  options = {}
  options[:analysis_id] = uuid

  # Sanity check inputs
  fail 'analysis UUID not specified' if options[:analysis_id].nil?

  # Gather the required files
  Zip.warn_invalid_date = false
  gather_output_results(options[:analysis_id])

  # Zip Results
  directory_to_zip = "/mnt/openstudio/server/assets/results/#{options[:analysis_id]}"     ## DO NOT MODIFY THIS PATH OR FILENAME
  output_file      = "/mnt/openstudio/server/assets/results.#{options[:analysis_id]}.zip" ## DO NOT MODIFY THIS PATH OR FILENAME
  puts "Zipping Files...".cyan
  zf = ZipFileGenerator.new(directory_to_zip, output_file)
  zf.write()

  puts "Zipping single files...".cyan

  # list of files to create a local zipped copy
  files_to_zip = ["/mnt/openstudio/server/assets/results/#{uuid}/failed_run_error_log.csv",
                  "/mnt/openstudio/server/assets/results/#{uuid}/simulations.json"
                 ]
  files_to_zip.each {|file|
    puts "Zipping #{file}"
    zip_single_file(file)
  }
  # Finish up
  puts 'SUCCESS'
end

options = {}

# Define allowed ARGV input
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

# Execute ARGV parsing into options hash holding symbolized key values
optparse.parse!
start_gather_result(options[:analysis_id])