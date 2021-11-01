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
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)
  def setup()
    @measure_interface_detailed = [
        {
            "name" => "eff_for_this_cz",
            "type" => "Double",
            "display_name" => 'Set pump efficiency between 0.0 and 1.0',
            "default_value" => 0.91,
            "is_required" => true
        }]
    @good_input_arguments = {
        "eff_for_this_cz" => 0.91
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcSetPumpEfficiency.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)

    input_arguments = {
        "eff_for_this_cz" => 0.91
    }

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(1, arguments.size)
    assert_equal(0.91, arguments[0].defaultValueAsDouble)

    # Define the output folder.
    test_dir = "#{File.dirname(__FILE__)}/output"
    if !Dir.exists?(test_dir)
      Dir.mkdir(test_dir)
    end
    NRCMeasureTestHelper.setOutputFolder("#{test_dir}")

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')
    #check if pump efficiency was changed correctly
    model.getPumpConstantSpeeds.each do |pump|
      assert_equal(0.91, pump.motorEfficiency)
    end
    model.getPumpVariableSpeeds.each do |pump|
      assert_equal(0.91, pump.motorEfficiency)
    end

    # save the model to test output directory
    output_file_path = "#{File.dirname(__FILE__)}//#{test_dir}/test_output.osm"
    model.save(output_file_path, true)
  end
end
