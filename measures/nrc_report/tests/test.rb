# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCReportingMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcReport_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCReportingMeasureTestHelper)
  
  # Define the output folder.
  @@test_dir = "#{File.expand_path(__dir__)}/output"
  # Remove if existing found. This should only be done once.
  if Dir.exists?(@@test_dir)
    FileUtils.rm_rf(@@test_dir)
	sleep 10
  end
  Dir.mkdir(@@test_dir)
  
  def setup()
    @use_json_package = false
    @use_string_double = false
    @measure_interface_detailed = [
      {
        "name" => "report_depth",
        "type" => "Choice",
        "display_name" => "Report detail level",
        "default_value" => "Summary",
        "choices" => ["Summary", "Detailed"],
        "is_required" => true
      }
    ]
	
    # Possible sections to include
    # methods for sections in order that they will appear in report
    possible_sections = []
    possible_sections << 'model_summary_section'
    possible_sections << 'building_construction_detailed_section'
    possible_sections << 'construction_summary_section'
    possible_sections << 'heat_gains_summary_section'
    possible_sections << 'heat_loss_summary_section'
    possible_sections << 'heat_gains_section'
    possible_sections << 'heat_losses_section'
    possible_sections << 'steadySate_conductionheat_losses_section'
    possible_sections << 'thermal_zone_summary_section'
    possible_sections << 'hvac_summary_section'
    possible_sections << 'air_loops_detail_section'
    possible_sections << 'plant_loops_detail_section'
    possible_sections << 'zone_equipment_detail_section'
    possible_sections << 'hvac_airloops_detailed_section1'
    possible_sections << 'hvac_plantloops_detailed_section1'
    possible_sections << 'hvac_zoneEquip_detailed_section1'
	
    possible_sections.each do |section_name|
	  arg = {
        "name" => section_name,
        "type" => "Bool",
        "display_name" => "Include #{section_name}",
        "default_value" => true,
        "is_required" => true
      }
	  @measure_interface_detailed << arg
    end

    def test_sample(template: 'NECB2017')
      puts "Testing  model reporting"

      # create an instance of the measure
      measure = NrcReport.new

      # create an instance of a runner
      runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

      # get arguments
      arguments = measure.arguments()
      argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

      report_depth = arguments[0].clone
      argument_map['report_depth'] = report_depth

      #check number of arguments.
      assert(report_depth.setValue("Detailed"))

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
      assert_equal(9, idf_output_requests.size)

      building_type = 'Warehouse'
      #building_type = 'MediumOffice'
      epw_file = 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw'
      test_name = "#{template.to_s}_#{building_type}"
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
      #runner.setLastEpwFilePath(epw_path)
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
        #show_output(result)
        assert_equal('Success', result.value.valueName)
      ensure
        Dir.chdir(start_dir)
      end
    end

  def test_report()
    puts "Testing report on small Office model".blue
	
    # Define the output folder for this test. 
    NRCReportingMeasureTestHelper.setOutputFolder("#{@@test_dir}/MediumOffice")
    Dir.mkdir(NRCReportingMeasureTestHelper.outputFolder) unless Dir.exists?(NRCReportingMeasureTestHelper.outputFolder)
	
    # Read model from file and run measure.
    translator = OpenStudio::OSVersion::VersionTranslator.new
	model_file = "#{File.dirname(__FILE__)}/MediumOffice.osm"
    model = translator.loadModel(model_file)
	msg = "Loading model: #{model_file}"
    assert(!model.empty?, msg)
    model = model.get
	
	# Assign the local weather file (have to provide a full path to EpwFile).
	epw = OpenStudio::EpwFile.new("#{File.expand_path(__dir__)}/weather_files/CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw")
	OpenStudio::Model::WeatherFile::setWeatherFile(model, epw)
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = @good_input_arguments
    
    # Create an instance of the measure
	runner = run_measure(input_arguments, model)
	
	# Rename output file.
    #output_file = "report_no_diffs.html"
    #File.rename("#{NRCReportingMeasureTestHelper.outputFolder}/report.html", "#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}")

    # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
	#regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
	#IO.write("#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}.reg", regression_file)
	#diffs = FileUtils.compare_file("#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}","#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}.reg")
	#assert(diffs, "There were differences to the regression files:\n")
  end
end
