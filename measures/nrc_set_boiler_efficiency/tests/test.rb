# Standard openstudio requires for runnin test.
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper.
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test.
require 'fileutils'

class NrcSetBoilerEfficiency_Test < Minitest::Test

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
        "name" => "boiler_eff",
        "type" => "Double",
        "display_name" => 'Set boiler efficiency (fraction between 0.0 and 1.0)',
        "default_value" => 0.85,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for std BTAP checking to work.
    @good_input_arguments = {
        "boiler_eff" => 0.93
    }
  end

  def test_argument_values

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/warehouse_2017.osm")

    # Get arguments.
    input_arguments = @good_input_arguments
    boiler_eff = input_arguments['boiler_eff']

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Good Thermal Efficiency Test", input_arguments)

    # Run the measure and check output.
    runner = run_measure(input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)

    # Check values correctly updated.
    model.getBoilerHotWaters.each do |boiler_water|
      assert_in_delta(boiler_eff, boiler_water.nominalThermalEfficiency, 0.005, "boiler thermal efficiency")
    end

  end
end
