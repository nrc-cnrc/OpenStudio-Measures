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

class NrcAddHvacAvailabilityManager_Test < Minitest::Test

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
            "name" => "heatcool",
            "type" => "Choice",
            "display_name" => "Apply to",
            "default_value" => "cooling",
            "choices" => ["cooling", "heating"],
            "is_required" => true
        },
        {
            "name" => "setPoint",
            "type" => "Double",
            "display_name" => "Turn off setpoint",
            "default_value" => 15,
            "max_double_value" => 50.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]

    @good_input_arguments = {
        "heatcool" => "cooling",
        "setPoint" => 12.0,
    }

  end
  
  def test_availabilityManager()
    puts "Testing  cooling availability manager".blue
	
    ####### Test Model Creation######
	# Set output folder. This should be unique to avoid other tests writing to the same location.
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/test_cooling")
	
    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                      building_type: "LargeOffice",
                                                      epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
													  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    input_arguments = nil

    # Set up your argument list to test.
    input_arguments = @good_input_arguments

    # Create an instance of the measure
    runner = run_measure(input_arguments, model)
    puts show_output(runner.result)

    assert(runner.result.value.valueName == 'Success')
  end
end
