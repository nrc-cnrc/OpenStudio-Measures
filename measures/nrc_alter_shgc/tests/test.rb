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

# Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
#  If so then use it to determine what old results are (if not use now)
start_time=Time.now
if ARGV.length == 1

  # We have a time. It will be in seconds since the epoch. Update our start_time.
  start_time=Time.at(ARGV[0].to_i)
end
NRCMeasureTestHelper::removeOldOutputs(before: start_time)

class NrcAlterSHGC_Test < Minitest::Test
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

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

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Modified_SHGC_test")
	
    # load the test model
	model = load_test_osm(File.dirname(__FILE__) + "/warehouse_2017.osm")

    # Run the measure and check output.
    puts "  Runnning measure".light_blue
	runner = run_measure(@good_input_arguments, model)
    result = runner.result
    puts "  Checking results".light_blue
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct number and value of input argument.
    assert_equal(1, @good_input_arguments.size, "Number of arguments")
    assert_equal(0.35, @good_input_arguments['new_shgc'], "SHGC value")
    
	# Check if a shgc was changed.
    model.getSimpleGlazings.each do |sim_glaz|
      assert_equal(0.35, sim_glaz.solarHeatGainCoefficient.to_f, "SHGC is incorrect")
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
	puts "Done.".light_blue
  end
end
