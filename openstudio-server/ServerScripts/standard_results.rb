#!/usr/bin/env ruby

require 'rest-client'
require 'fileutils'
require 'zip'
require 'optparse'
require 'json'
require 'colored'
require 'caracal'

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
  outputpath = "/mnt/openstudio/server/assets/results/#{required_analysis_id}/results_outputs/"
  puts "Creating output folder for osm files: #{outputpath}".green
  unless Dir.exists? outputpath
    FileUtils.mkdir_p outputpath
  end

  # This returns all the datapoints on the server.
  datapoints = JSON.parse(RestClient.get("http://web:80/data_points.json", headers = {}))

  # Ensure there are datapoints to work with
  if datapoints.nil? || datapoints.empty?
    fail "ERROR: No datapoints found.".red
  end

  # Loop through the data points and find the ones associated with the specified analysis.
  datapoints.each do |dp|
    id = dp['_id']

    analysis_id = dp['analysis_id']
    # puts "Data point ID #{id}".red
    # puts "Analysis ID #{analysis_id}".yellow
    # puts "            #{required_analysis_id}".green
    next if analysis_id != required_analysis_id # Skip if data point is not one from the required analysis.

    # Try and find a pricing template csv. This should add it to the datapoint results.
    puts "Datapoint ID #{id}".green

    # Get the datapoint name (to use as the output file name).
    dp_name = dp['name']

    # The files we want are in the datapoint.zip file. Grab this.
    dpZipRaw = RestClient.get("http://web:80/data_points/#{id}/download_result_file", { params: { filename: 'data_point.zip' } })
    # puts "#{dpZipRaw.class}".yellow
    # puts "#{dpZipRaw.body.class}".red
    dpZip = Zip::File.open_buffer(dpZipRaw.body)
    # puts "#{dpZip.class}".cyan
    docx_file = ""
    html_file = ""
    qaqc_file = ""
    btap_file = ""
    json_file = ""
    puts "Scanning zip file for standard results outputs...".green
    dpZip.each do |entry|
      # puts "#{entry.name}".green
      if entry.name.include? "nrc_report_standard/report.html"
        html_file = entry.name
        puts "Found #{entry.name}".green
      elsif entry.name.include? "nrc_report_standard/report.docx"
        docx_file = entry.name
        puts "Found #{entry.name}".green
      elsif entry.name.include? "nrc_report_standard/report.json"
        json_file = entry.name
        puts "Found #{entry.name}".green
      elsif entry.name.include? "nrc_report_standard/qaqc_data.json"
        qaqc_file = entry.name
        puts "Found #{entry.name}".green
      elsif entry.name.include? "nrc_report_standard/btap_data.json"
        btap_file = entry.name
        puts "Found #{entry.name}".green
      end
    end

    # Create a lambda to save the files.
    write_file = lambda do |f_name|
      file = dpZip.find_entry(f_name) # Grab file from zip
	  f_name = "#{f_name.split('/')[1]}" # Extract the file name (strip off the 'nrc_report_standard' part)
      f_path = File.join(outputpath, "#{f_name.split('.')[0]}-#{dp_name.gsub(/\:/, '_')}.#{f_name.split('.')[1]}") # New name: path/file_type-model_name.extension
      FileUtils.mkdir_p(File.dirname(f_path))
      dpZip.extract(file.name, f_path) unless File.exist?(f_path) # No overwrite
    end

    # Write files to shared folder.
    if !html_file.empty?
      write_file.call(html_file)
    end
    if !docx_file.empty?
      write_file.call(docx_file)
    end
    if !json_file.empty?
      write_file.call(json_file)
    end
    if !qaqc_file.empty?
      write_file.call(qaqc_file)
    end
    if !btap_file.empty?
      write_file.call(btap_file)
    end
  end

  # Now collate the report-*.json files into a single word file.
  data = Array.new
  Dir.glob("#{outputpath}report-*.json") do |file|
    puts "#{file}"
    filedata = JSON.parse(File.read(file))
    model_name = File.basename(file, ".json")
    filedata.transform_keys!(&:to_sym)
    filedata[:model] = model_name
    data << filedata
  end
  # Save files
  File.open("#{outputpath}all_json.json", 'w') { |f| f.write(JSON.pretty_generate(data, allow_nan: true)) }
  do_writing(outputpath, data)
end

def write_section(docx, section)
  main_section_class = section[:class]
  section.transform_keys!(&:to_sym) # Ensure we have symbols
  content = section[:content]
  content.transform_keys!(&:to_sym) # Ensure we have symbols
  docx.h2("#{content[:title]}")
  docx.p("#{content[:introduction]}")
  if content[:tables_and_charts] != nil
    # puts "#{content[:tables_and_charts]}".yellow
    content[:tables_and_charts].each do |table_or_chart|
      table_or_chart.transform_keys!(&:to_sym) # Ensure we have symbols
      # puts "#{table_or_chart}".green
      case table_or_chart[:class]
      when /ReportTable$/
        # Its a table.
        table_content = table_or_chart[:content]
        table_content.transform_keys!(&:to_sym) # Ensure we have symbols
        docx.p("Table: #{table_content[:caption]}")

        # Need to scan table data and replace html tags with the appropriate caracel objects.
        table_data = table_content[:data]
        # puts "#{table_data}".blue
        table_data.each do |row|
          row.replace(row.map! { |cell|
            case cell
            when String
              if cell.include?("<sup>")
                # cell.sub!("<sup>","")
                # cell.sub!("</sup>","")
                new_cell = Caracal::Core::Models::TableCellModel.new do
                  p do
                    text cell.split("<sup>")[0].to_s
                    text cell.split("<sup>")[1].split("</sup>")[0].to_s do
                      vertical_align 'superscript'
                    end
                    text cell.split("</sup>")[1].to_s
                  end
                end
                cell = new_cell
                # puts "#{cell}".green
              end
            end
            # puts "#{cell}".red
            cell
          })
        end
        # puts "#{table_data}".yellow

        # Now create the Word table.
        # docx.table(table_data)
        docx.table table_data, border_size: 4 do
          cell_style rows[0], color: 'ffffff', background: '3366cc', bold: true
        end
        docx.p("#{table_content[:description]}")
      when /ReportChart$/
        puts "*** ReportChart writing *** Not yet implemented".yellow
      else
        puts "*** unknown content type ***".yellow
      end
    end
  end
end

# Write word format report. This is essenentially the same code as in the standard report measure.
# Only difference is that there is an outer loop here for the various models in the analysis (the
# measure is only for a single model).
def do_writing(outputpath, data)
  # Open document and loop through each model in the json.
  docx = Caracal::Document.new("#{outputpath}report.docx")

  docx.h1("NRC Report ") do
    bgcolor '3366cc'
    color 'ffffff'
    align 'center'
    bold true
  end

  docx.h2("Summary of Report Sections") do
    size 32
    bold true
  end
  n = 1
  data.each do |model|
    docx.p do

      num = "#" + n.to_s # had to add '#' as links have to start with '#' for example link  'Click here to go to the second page.', '#page2'
      model_header = "#{model[:model]}"
      link model_header, num
    end

    model[:content].each do |section|
      section.transform_keys!(&:to_sym) # Ensure we have symbols
      content = section[:content]
      content.transform_keys!(&:to_sym) # Ensure we have symbols
      next if content[:title].include? "Summary of Server Configuration"
      # docx.ul do
        # li content[:title], color: '004467'
      # end
    end
    n = n + 1
    docx.p # creates empty line
  end

  data.each do |model|
    add_summary = TRUE
    model[:content].each do |section|
      if add_summary == TRUE
        section.transform_keys!(&:to_sym) # Ensure we have symbols
        content = section[:content]
        content.transform_keys!(&:to_sym)
        if content[:title].include? "Summary of Server Configuration"
          write_section(docx, section)
        end
      end
      break
    end
    add_summary = FALSE
    break
  end
  docx.p # creates empty line
  
  n = 1
  data.each do |model|
    docx.bookmark_start id: 'page2', name: "#{n}"
    # link  'click', '#page2'
    docx.h1("#{model[:model]}")
    docx.bookmark_end id: 'page2'
    model[:content].each do |section|
      section.transform_keys!(&:to_sym) # Ensure we have symbols
      content = section[:content]
      content.transform_keys!(&:to_sym)
      if !content[:title].include? "Summary of Server Configuration"
        write_section(docx, section)
      end
    end
    n = n + 1
    docx.page # open new page
  end
  docx.save
end

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
puts "Gathering standard report files from analysis #{uuid}".cyan

# Gather the required files.
Zip.warn_invalid_date = false
gather_output_results(uuid)

# Finish up
puts "SUCCESS".green
