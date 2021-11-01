# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'

# Specific requires for this test
require 'fileutils'

class NrcReportCarbonEmissions_Test < Minitest::Test
  def model_in_path
    return "#{File.dirname(__FILE__)}/MidriseApartment.osm"
  end

  def epw_path
    # make sure we have a weather data location
    epw = File.expand_path("#{File.dirname(__FILE__)}/CAN_AB_Edmonton.711230_CWEC.epw")
    assert(File.exist?(epw.to_s))
    return epw.to_s
  end

  def workspace_path(test_name)
    "#{run_dir(test_name)}/run/in.idf"
  end

  # create test files if they do not exist when the test first runs
  def setup_test(test_name, idf_output_requests, building, epw_filename, template)
    output_folder = "#{File.dirname(__FILE__)}/output/#{test_name}"
    output_folder = "#{File.dirname(__FILE__)}/output/test_name"

    unless File.exist?(run_dir(test_name))
      FileUtils.mkdir_p(run_dir(test_name))
    end
    assert(File.exist?(run_dir(test_name)))
    if File.exist?(model_out_path(test_name))
      FileUtils.rm(model_out_path(test_name))
    end

    prototype_creator = Standard.build(template)

    model = prototype_creator.model_create_prototype_model(
      template: template,
      epw_file: epw_filename,
      sizing_run_dir: output_folder,
      debug: @debug,
      building_type: building)

    epw_file = OpenStudio::EpwFile.new(OpenStudio::Path.new(epw_path))
    prototype_creator.model_run_simulation_and_log_errors(model, run_dir(test_name))
    model.save(model_out_path(test_name), true)

    # convert output requests to OSM for testing, OS App and PAT will add these to the E+ Idf
    workspace = OpenStudio::Workspace.new("Draft".to_StrictnessLevel, "EnergyPlus".to_IddFileType)
    #workspace.addObjects(idf_output_requests)
    rt = OpenStudio::EnergyPlus::ReverseTranslator.new
    request_model = rt.translateWorkspace(workspace)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    model.addObjects(request_model.objects)
  end

  def run_dir(test_name)
    # always generate test output in specially named 'output' directory so result files are not made part of the measure
    return "#{File.dirname(__FILE__)}/output/#{test_name}"
  end

  def model_out_path(test_name)
    return "#{run_dir(test_name)}/example_model.osm"
  end

  def sql_path(test_name)
    return "#{run_dir(test_name)}/run/eplusout.sql"
  end

  def report_path(test_name)
    return "#{run_dir(test_name)}/report.html"
  end

  def test_sample()
    puts "Testing  model reporting"

    # create an instance of the measure
    measure = NrcReportCarbonEmissions.new

    # create an instance of a runner
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    # get arguments
    arguments = measure.arguments()
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values
    args_hash = {}

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    idf_output_requests = measure.energyPlusOutputRequests(runner, argument_map)
    building_type = 'Warehouse'
    template = 'NECB2017'
    epw_file = 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw'
    test_name = "#{template}_#{building_type}-#{epw_file}"
    # mimic the process of running this measure in OS App or PAT
    FileUtils.mkdir_p(run_dir(test_name))
    setup_test(test_name, idf_output_requests, building_type, epw_file, template)
    if !File.exist?(sql_path(test_name))
      osw_path = File.join(run_dir(test_name), 'in.osw')
      osw_path = File.absolute_path(osw_path)

      workflow = OpenStudio::WorkflowJSON.new
      workflow.setSeedFile(File.absolute_path(model_out_path(test_name)))
      workflow.setWeatherFile(File.absolute_path(epw_path))
      workflow.saveAs(osw_path)

      cli_path = OpenStudio.getOpenStudioCLI
      cmd = "\"#{cli_path}\" run -w \"#{osw_path}\""
      puts cmd
      system(cmd)
    end

    assert(File.exist?(model_out_path(test_name)), "Could not find osm at this path:#{model_out_path(test_name)}")
    assert(File.exist?(sql_path(test_name)), "Could not find sql at this path:#{sql_path(test_name)}")

    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(OpenStudio::Path.new(model_out_path(test_name)))
    runner.setLastEnergyPlusWorkspacePath(OpenStudio::Path.new(workspace_path(test_name)))
    runner.setLastEnergyPlusSqlFilePath(OpenStudio::Path.new(sql_path(test_name)))

    # delete the output if it exists
    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end
    assert(!File.exist?(report_path(test_name)))

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(run_dir(test_name))

      # run the measure
      measure.run(runner, argument_map)
      result = runner.result
      assert(result.value.valueName == 'Success')
    ensure
      Dir.chdir(start_dir)
    end
  end
end

