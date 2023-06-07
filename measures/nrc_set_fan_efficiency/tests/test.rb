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

class NrcSetFanEfficiency_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'].nil?
    start_time=Time.now
  else
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @measure_interface_detailed = [
      {
        "name" => "fan_eff",
        "type" => "Double",
        "display_name" => 'Set fan efficiency (fraction between 0.0 and 1.0)',
        "default_value" => 0.55,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for std BTAP checking to work.
    @good_input_arguments = {
        "fan_eff" => 0.65
    }
  end

  def test_argument_values

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/warehouse_2017.osm")

    # Get arguments.
    input_arguments = @good_input_arguments
    fan_eff = input_arguments['fan_eff']

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Good Fan Efficiency Test", input_arguments)

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that the measure returned 'success'.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Check if fan efficiency was changed correctly
    model.getFanOnOffs.each do |fan|
      assert_in_delta(fan_eff, fan.fanEfficiency, 0.005, "Error in OnOff Fan efficiency.")
    end
    model.getFanConstantVolumes.each do |fan|
      assert_in_delta(fan_eff, fan.fanEfficiency, 0.005, "Error in Constant Volume Fan efficiency.")
    end
    model.getFanVariableVolumes.each do |fan|
      assert_in_delta(fan_eff, fan.fanEfficiency, 0.005, "Error in Variable Volume Fan efficiency.")
    end
    model.getFanZoneExhausts.each do |fan|
      assert_in_delta(fan_eff, fan.fanEfficiency, 0.005, "Error in Exhaust Fan efficiency.")
    end

  end
end
