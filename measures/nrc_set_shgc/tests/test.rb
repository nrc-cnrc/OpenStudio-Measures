# Standard openstudio requires for running test.
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper.
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test.
require 'fileutils'

class NrcSetSHGC_Test < Minitest::Test

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
            "name" => "new_shgc",
            "type" => "Double",
            "display_name" => "SHGC",
            "default_value" => 0.3,
			"min_double_value" => 0.0,
			"max_double_value" => 1.0,
            "is_required" => true
        }]
    @good_input_arguments = {
        "new_shgc" => 0.35
    }
  end

  def test_argument_values

    # Get arguments.
    input_arguments = @good_input_arguments

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Set SHGC test", input_arguments)
	
    # Load the test model.
	model = load_test_osm(File.dirname(__FILE__) + "/warehouse_2017.osm")

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that the measure returned 'success'.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Get the SHGC value.
    new_shgc = input_arguments['new_shgc']

	# Check if a shgc was changed.
    model.getSimpleGlazings.each do |sim_glaz|
      assert_in_delta(new_shgc, sim_glaz.solarHeatGainCoefficient.to_f, 0.001, "Error in updated SHGC.")
    end

	puts "Done.".light_blue
  end
end
