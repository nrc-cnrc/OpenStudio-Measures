# Standard openstudio requires for runnin test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcChangeSWHtoASHPWH_Test < Minitest::Test
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

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
            "name" => "frac_oa",
            "type" => "Double",
            "display_name" => "Fraction of outside air in evaporator",
            "default_value" => 1.0,
            "max_double_value" => 1.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }]
		
    @good_input_arguments = {
        "frac_oa" => 0.75
    }
  end

  def test_office()
    puts "Testing  swapping mixed water heater for heat pump water heater in office model".blue
	
	# Set output folder. This should be unique to avoid other tests writing to the same location.
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/test_office")
	
    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                      building_type: "MediumOffice",
                                                      epw_file: "CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw",
													  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Save model to output folder (for comparison later).
    output_file_path = "#{NRCMeasureTestHelper.outputFolder}/mediumOfficeOriginal.osm"
    model.save(output_file_path, true)
	
    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, model)

	# Get resuls of measure
	output_run_summary(runner.result)

    # save the model to test output directory
    output_file_path = "#{NRCMeasureTestHelper.outputFolder}/mediumOfficeUpdated.osm"
    model.save(output_file_path, true)
	
	# Now check updated model is different in the ways we expect.

  end
  
  def test_school()
    puts "Testing swapping mixed water heater for heat pump water heater in secondary school model".blue
	
	# Set output folder. This should be unique to avoid other tests writing to the same location.
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/test_school")
	
    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                      building_type: "SecondarySchool",
                                                      epw_file: "CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw",
													  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Save model to output folder (for comparison later).
    output_file_path = "#{NRCMeasureTestHelper.outputFolder}/schoolOriginal.osm"
    model.save(output_file_path, true)
	
    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, model)

	# Get resuls of measure
	output_run_summary(runner.result)

    # save the model to test output directory
    output_file_path = "#{NRCMeasureTestHelper.outputFolder}/schoolUpdated.osm"
    model.save(output_file_path, true)
	
	# Now check updated model is different in the ways we expect.

  end
  
  def output_run_summary(result)
    # Standard measure reporting for the test.
    assert(result.value.valueName == 'Success')
	
	# Echo messages from the measure to the screen, in colour!
	if result.initialCondition.is_initialized then puts "#{result.initialCondition.get.logMessage}".green end
	result.info.each     { |msg| puts "INFO: #{msg.logMessage}" }
	result.warnings.each { |msg| puts "WARN: #{msg.logMessage}".yellow }
	result.errors.each   { |msg| puts "ERROR: #{msg.logMessage}".red }
	if result.finalCondition.is_initialized then puts "#{result.finalCondition.get.logMessage}".green end
	
  end
end

