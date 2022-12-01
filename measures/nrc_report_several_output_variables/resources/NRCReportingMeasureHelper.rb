# Extensions to BTAPMeasureHelper for NRC measures. Essentially inherits all methods and
# only adds functionality where required.

require_relative 'BTAPMeasureHelper'
require 'fileutils'

module NRCReportingMeasureHelper
  include BTAPMeasureHelper

  # Find the version of NECB used to define the model. Default to 2017.
  def find_standard(model)
    if model.getBuilding.standardsTemplate.is_initialized
      standardsTemplate = (model.getBuilding.standardsTemplate).to_s
      standard = Standard.build(standardsTemplate)
    else
      puts "The measure wasn't able to determine the standards template from the model, a default value of 'NECB2017' will be used.".red
      standard = Standard.build('NECB2017')
    end
    return standard
  end
end

module NRCReportingMeasureTestHelper
  include BTAPMeasureTestHelper

  # Define the output path. Set defaults and remove any existing outputs.
  @output_root_path = File.expand_path("#{File.expand_path(__dir__)}/../tests/output")
  Dir.mkdir @output_root_path unless Dir.exists?(@output_root_path)
  @output_path = @output_root_path

  # Remove the existing test results. Need to control when this is done as multiple test scripts could be
  #  accessing the same path.
  # Must call this in the test script.
  def self.removeOldOutputs(before: Time.now)
    existing_folders = Dir.entries(@output_path) - ['.', '..'] # Remove current folder above from list before deleting!
    existing_folders.each do |entry|
      folder_to_remove = File.expand_path("#{@output_path}/#{entry}")
      if (Dir.exist?(folder_to_remove)) # Double check it exists (incase another process has removed it as is the case with multiple test files).
        puts "Checking existing output folder: #{before}; #{File.mtime(folder_to_remove)}; #{folder_to_remove}".green
        if File.mtime(folder_to_remove) < before
          puts "Removing folder: #{folder_to_remove}".yellow
          FileUtils.rm_rf(folder_to_remove)
        else
          puts "Skipping existing output folder: #{folder_to_remove}".light_blue
        end
      end
    end
  end

  #
  # Define methods to manage output folders.
  def self.resetOutputFolder
    @output_path = @output_root_path
  end

  def self.appendOutputFolder(folder)
    # Append name and validate if specified by the user
    path = @output_path + "/" + folder
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
      puts "Appending path to test output folder: #{path}"
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

  #
  # Define the folder containing the test file for the test case summary output file.
  @measure_path = File.expand_path("#{File.expand_path(__dir__)}/../tests")
  @test_summary_mdfile = @measure_path + "/" + "README.md"
  FileUtils.rm_rf(@test_summary_mdfile)

  # Create initial file with title.
  @testSummaryTitleRequired = true
  def self.testSummaryTitleRequired
    return @testSummaryTitleRequired
  end

  def self.setTestSummaryTitle(required)
    @testSummaryTitleRequired = required
  end

  def self.testSummaryMDfile
    @test_summary_mdfile.to_s
  end

  # Test count
  @testSummaryCount = 1
  def self.incrementTestSummaryCount
    @testSummaryCount += 1
  end

  def self.testSummaryCount
    return @testSummaryCount
  end

  #
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
    FileUtils.mkdir_p(output_folder) unless Dir.exists?(output_folder)

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

    # Set up runner
    runner.setLastOpenStudioModel(model)

    # Get the e+ output requests, this will be done automatically by OS App and PAT
    idf_output_requests = measure.energyPlusOutputRequests(runner, argument_map)

    # Convert output requests to OSM for testing, OS App and PAT will add these to the E+ Idf.
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

    # Set up runner, this will happen automatically when measure is run in PAT or OpenStudio.
    runner.setLastOpenStudioModelPath(model_out_path)
    runner.setLastEpwFilePath(epw_path)
    runner.setLastEnergyPlusSqlFilePath(sql_path)

    # Temporarily change directory to the run directory and run the measure.
    start_dir = Dir.pwd
    begin
      Dir.chdir(output_folder)
      measure.run(runner, argument_map)
    ensure
      Dir.chdir(start_dir)
    end
    result = runner.result.value.valueName

    # Reset the output path to the root folder.
    NRCReportingMeasureTestHelper.resetOutputFolder

    # Add summary of test to README file.
    measure_name = measure.name.gsub("_", " ").upcase
    reportCase(measure_name, output_folder.split('/').last, input_arguments, result)

    return runner
  end

  # Method to report case being tested
  def reportCase(measure_name, test_name, input_arguments, result)

    # File name defined above. Open for appending.
    out_file = File.new("#{NRCReportingMeasureTestHelper.testSummaryMDfile}", "a")

    # Only add the page title once.
    if NRCReportingMeasureTestHelper.testSummaryTitleRequired
      title = "# Summary Of Test Cases for '#{measure_name}' Measure"
      out_file.puts("#{title}")
      out_file.puts(" ")
      out_file.puts("The following describe the parameter tests that are conducted on the measure. Note some of the ")
      out_file.puts("tests are designed to return a fail and some a success. The report below contains all the tests that ")
      out_file.puts("have the correct response. For example the argument range limit tests are expected to fail. ")
      out_file.puts(" ")
    end

    # Current test name.
    test_name = test_name.gsub("_", " ")
    out_file.puts("## #{NRCReportingMeasureTestHelper.testSummaryCount} - #{test_name}")
    out_file.puts(" ")
    if (result == 'Success')
      out_file.puts("This test was expected to pass and it did.")
    else
      out_file.puts("This test was expected to generate an error and it did.")
    end
    out_file.puts(" ")

    # Create a table describing the case tested. Table header first.
    out_file.puts("| Test Argument | Test Value |")
    out_file.puts("| ------------- | ---------- |")

    # Table contents.
    input_arguments.each do |key, value|
      out_file.puts("| #{key} |#{value} |")
    end
    out_file.puts(" ")
    out_file.close

    # Update logical and counters.
    NRCReportingMeasureTestHelper.setTestSummaryTitle(false)
    NRCReportingMeasureTestHelper.incrementTestSummaryCount
  end

  # Fancy way of getting the measure object automatically. Added check for NRC in measure name.
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

  # Load a test model (code that is common in a lot of test scripts). Returns the model object.
  def load_test_osm(full_osm_model_path)

    # Load the supplied osm.
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(full_osm_model_path)
    model = translator.loadModel(path)
    assert((not model.empty?), "Reading model file: #{path}")
    model = model.get
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
