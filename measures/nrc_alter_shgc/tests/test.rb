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

class NrcAlterSHGC_Test < Minitest::Test
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()
    @measure_interface_detailed = [
        {
            "name" => "new_shgc",
            "type" => "Double",
            "display_name" => 'Set SHGC',
            "default_value" => 0.3,
            "is_required" => true
        }]
    @good_input_arguments = {
        "new_shgc" => 0.3
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcAlterSHGC.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "new_shgc" => 0.3
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
    assert_equal(0.3, arguments[0].defaultValueAsDouble)
    # check if a shgc was changed
    model.getSimpleGlazings.each do |sim_glaz|
      assert_equal(0.3, sim_glaz.solarHeatGainCoefficient.to_f, "SHGC is incorrect")
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
