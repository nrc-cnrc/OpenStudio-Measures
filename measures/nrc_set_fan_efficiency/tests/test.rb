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
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()
    @measure_interface_detailed = [
        {
            "name" => "eff_for_this_cz",
            "type" => "Double",
            "display_name" => 'Set Fan efficiency between 0.0 and 1.0',
            "default_value" => 0.55,
            "is_required" => true
        }]
    @good_input_arguments = {
        "eff_for_this_cz" => 0.55
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcSetFanEfficiency.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "eff_for_this_cz" => 0.55
    }

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(1, arguments.size)
    assert_equal(0.55, arguments[0].defaultValueAsDouble)

    #check if fan efficiency was changed correctly
    model.getFanOnOffs.each do |fan|
      assert_equal(0.55, fan.fanEfficiency, "Fan efficiency did not change correctly")
    end
    model.getFanConstantVolumes.each do |fan|
      assert_equal(0.55, fan.fanEfficiency, "Fan efficiency did not change correctly")
    end
    model.getFanVariableVolumes.each do |fan|
      assert_equal(0.55, fan.fanEfficiency, "Fan efficiency did not change correctly")
    end
    model.getFanZoneExhausts.each do |fan|
      assert_equal(0.55, fan.fanEfficiency, "Fan efficiency did not change correctly")
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
