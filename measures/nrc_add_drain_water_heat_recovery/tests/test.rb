# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcDrainWaterHeatRecovery_Test < Minitest::Test

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
    @use_string_double = true
    @measure_interface_detailed = [
        {
            "name" => "plant_loop",
            "type" => "String",
            "display_name" => "Plant loop to apply change to (currently all is only option)",
            "default_value" => "All",
            "is_required" => true
        },
        {
            "name" => "ua",
            "type" => "Double",
            "display_name" => "UA value of heat exchanger (W/mK)",
            "default_value" => 3000,
            "is_required" => true
        }
    ]

    @good_input_arguments = {
        "plant_loop" => "All",
        "ua" => 3000
    }
  end
  
  def test_drainwater()
  
	# Set output folder. This should be unique to avoid other tests writing to the same location.
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}")
	
    # Load the test workspace
    idf_file = File.dirname(__FILE__) + '/in.idf'
    assert(File.exists?(idf_file))
    workspace = OpenStudio::Workspace::load(OpenStudio::Path.new(idf_file))
    assert((not workspace.empty?))
    workspace = workspace.get

    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, workspace)
	
	# Get resuls of measure
	output_run_summary(runner.result)
	
	# Check output
    connections = workspace.getObjectsByType('WaterUse:Connections'.to_IddObjectType)
	connections.each do |connection|
      msg = "Water Use Connection #{connection.name.to_s} drain water UA value"
	  assert_in_delta(@good_input_arguments['ua'], connection.idfObject.getDouble(9).get, 0.5, msg)
	end
	
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
