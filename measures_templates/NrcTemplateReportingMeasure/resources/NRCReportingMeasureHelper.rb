# Extensions to BTAPMeasureHelper for NRC measures. Essentially inherits all methods and
# only adds functionality where required.

require_relative 'BTAPMeasureHelper'
require 'fileutils'

module NRCReportingMeasureHelper
  include BTAPMeasureHelper
end

module NRCReportingMeasureTestHelper
  include BTAPMeasureTestHelper

  # Define the output path. Set defaults and remove any existing outputs.
  @output_root_path = File.expand_path("#{File.expand_path(__dir__)}/../tests/output")
  Dir.mkdir @output_root_path unless Dir.exists?(@output_root_path) 
  @output_path = @output_root_path
  existing_folders = Dir.entries(@output_root_path) - ['.','..'] # Remove current folder above from list before deleting!
  existing_folders.each do |entry|
	folder_to_remove = File.expand_path("#{@output_root_path}/#{entry}")
	puts "Removing existing output folder: #{folder_to_remove}".yellow
	FileUtils.rm_rf(folder_to_remove)
  end
  
  # Define methods to manage output folders.
  def self.resetOutputFolder
    @output_path = @output_root_path
  end
  def self.appendOutputFolder(folder)
    # Append name and validate if specified by the user
    path = @output_root_path + "/" + folder
	validateOutputFolder(path)
  end
  def self.validateOutputFolder(path)
    # This should not be the root_folder.
	# Also check if it exists.
	# By default use the test method name.
	path = File.expand_path(path)
	if path == @output_root_path 
	  # Append the calling method name and re-validate (need to jump back two methods)
	  path = @output_root_path + "/" + caller_locations(1,2)[1].label.split.last
	  validateOutputFolder(path)
	elsif File.exist?(path)
	  # Create a numbered subfolder. First check if there is a numbered folder.
	  path = path.split(/--/).first
	  count = Dir.glob("#{path}*").count
	  path = path + "--#{count}"
	  validateOutputFolder(path)
	else
	  @output_path = path
	end
    @output_path.to_s
  end
  def self.outputFolder
    @output_path.to_s
  end
  
  # Custom way to run a reporting measure in the test. Overwrites run_measure definition in BTAPMeasureTestHelper.
  def run_measure(input_arguments, model)
  
    # Provide feedback as to what is being done to teh terminal.
    puts "Running measure".green
	puts "  with input arguments".green + " #{input_arguments}".light_blue
	puts "  on model with".green + " #{model.modelObjects.count}".light_blue + " objects".green
	puts "  from method".green + " #{caller_locations(1,1)[0].label.split.last}".light_blue

    # Set the output folder. This should be unique (check done in validateOutputFolder). Create if does not exist.
	output_folder = NRCReportingMeasureTestHelper.outputFolder
	output_folder = NRCReportingMeasureTestHelper.validateOutputFolder(output_folder)
    Dir.mkdir(output_folder) unless Dir.exists?(output_folder)
	
    # This will create a instance of the measure you wish to test. It does this based on the test class name.
    measure = get_measure_object()
    measure.use_json_package = @use_json_package
    measure.use_string_double = @use_string_double
	
    # Return false if can't
    return false if false == measure
	
	# Now get the arguments and create a runner
    arguments = measure.arguments()
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
	
    # Set the arguements in the argument map use json or real arguments.
    if @use_json_package
      argument = arguments[0].clone
      assert(argument.setValue(input_arguments['json_input']), "Could not set value for 'json_input' to #{input_arguments['json_input']}")
      argument_map['json_input'] = argument
    else
      input_arguments.each_with_index do |(key, value), index|
        argument = arguments[index].clone
        if argument_type(argument) == "Double"
          #forces it to a double if it is a double.
          assert(argument.setValue(value.to_f), "Could not set value for #{key} to #{value}")
        else
          assert(argument.setValue(value.to_s), "Could not set value for #{key} to #{value}")
        end
        argument_map[key] = argument
      end
    end
	
	# Get the e+ output requests, this will be done automatically by OS App and PAT
    idf_output_requests = measure.energyPlusOutputRequests(runner, argument_map)

    # Mimic the process of running this measure in OS App or PAT.
	# Create a new folder to work in (if it does not exist)
    if !File.exist?(output_folder)
      FileUtils.mkdir_p(output_folder)
    end
    assert(File.exist?(output_folder))

    # Remove existing report.
	report_path = "#{output_folder}/report.html"
    if File.exist?(report_path)
      FileUtils.rm(report_path)
    end

    # If the updated model exists remove it.
	model_out_path = "#{output_folder}/model.osm"
    if File.exist?(model_out_path)
      FileUtils.rm(model_out_path)
    end

    # Convert output requests to OSM for testing, OS App and PAT will add these to the E+ Idf
    workspace = OpenStudio::Workspace.new('Draft'.to_StrictnessLevel, 'EnergyPlus'.to_IddFileType)
    workspace.addObjects(idf_output_requests)
    rt = OpenStudio::EnergyPlus::ReverseTranslator.new
    request_model = rt.translateWorkspace(workspace)

    # Add requested outputs to model.
    model.addObjects(request_model.objects)
    model.save(model_out_path, true)
    
	sql_path = "#{output_folder}/run/eplusout.sql"
    if ENV['OPENSTUDIO_TEST_NO_CACHE_SQLFILE']
      if File.exist?(sql_path)
        FileUtils.rm_f(sql_path)
      end
    end
    
    osw_path = File.join(output_folder, 'in.osw')
    osw_path = File.absolute_path(osw_path.to_s)

    workflow = OpenStudio::WorkflowJSON.new
    workflow.setSeedFile(File.absolute_path(model_out_path))
    epw_path = (model.getWeatherFile.url).to_s
    workflow.setWeatherFile(File.absolute_path(epw_path))
    workflow.saveAs(osw_path)

    cli_path = OpenStudio.getOpenStudioCLI
    cmd = "\"#{cli_path}\" run -w \"#{osw_path}\""
    puts "Running openstudio with command: ".green + "\n#{cmd}".light_blue
    OpenstudioStandards.run_command(cmd)
	
    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(model_out_path)
    runner.setLastEpwFilePath(epw_path)
    runner.setLastEnergyPlusSqlFilePath(sql_path)
	
    # Temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(output_folder)
      measure.run(runner, argument_map)
    ensure
      Dir.chdir(start_dir)
    end
	
	# Reset the output path to the root folder.
	NRCReportingMeasureTestHelper.resetOutputFolder

    return runner
  end

  #Fancy way of getting the measure object automatically. Added check for NRC in measure name.
  def get_measure_object()
    measure_class_name = self.class.name.to_s.match((/(NRC.*)(\_Test)/i) || ((/(BTAP.*)(\_Test)/i))).captures[0]
    btap_measure = nil
    nrc_measure = nil
    eval "btap_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "BTAP"
    eval "nrc_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "Nrc"
    if btap_measure.nil? and nrc_measure.nil?
      if btap_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'BTAPMeasureName_Test' (Note: BTAP is case sensitive.) ".red
      elsif nrc_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'NrcMeasureName_Test' (Note: Nrc is case sensitive.) ".red
      end
      return false
    end
    if btap_measure
      return btap_measure
    else
      return nrc_measure
    end
  end
end

# Add significant digits capability to float amd integer class.
class Float
  def signif(digits=3)
    return 0 if self.zero?
    return self if self < 0.0
    self.round(-(Math.log10(self).ceil - digits))
  end
end
class Integer
  def signif(digits=3)
    return 0 if self.zero?
    return self if self < 0
    self.round(-(Math.log10(self).ceil - digits)).to_i
  end
end
