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

class NrcSetPumpEfficiency_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'] != ""
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  else
    start_time=Time.now
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @measure_interface_detailed = [
      {
        "name" => "pump_eff",
        "type" => "Double",
        "display_name" => 'Set pump efficiency (fraction between 0.0 and 1.0)',
        "default_value" => 0.91,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for std BTAP checking to work.
    @good_input_arguments = {
        "pump_eff" => 0.94
    }
  end

  def test_argument_values

    # Get arguments.
    input_arguments = @good_input_arguments
    pump_eff = input_arguments['pump_eff']

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Good Pump Motor Efficiency Test", input_arguments)

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/warehouse_2017.osm")

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    #check if pump efficiency was changed correctly
    model.getPumpConstantSpeeds.each do |pump|
      assert_in_delta(pump_eff, pump.motorEfficiency, 0.005, "Error in constant speed pump motor efficiency.")
    end
    model.getPumpVariableSpeeds.each do |pump|
      assert_in_delta(pump_eff, pump.motorEfficiency, 0.005, "Error in variable speed pump motor efficiency.")
    end

  end
end
