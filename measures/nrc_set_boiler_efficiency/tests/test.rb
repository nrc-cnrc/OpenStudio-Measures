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

class NrcSetBoilerEfficiency_Test < Minitest::Test
  include(NRCMeasureTestHelper)
  def setup()
    @measure_interface_detailed = [
        {
            "name" => "boiler_eff",
            "type" => "Double",
            "display_name" => 'Set Boiler efficiency between 0.0 and 1.0',
            "default_value" => 0.85,
            "is_required" => true
        }]
    @good_input_arguments = {
        "boiler_eff" => 0.85
    }
  end

  def test_argument_values
    measure = NrcSetBoilerEfficiency.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "boiler_eff" => 0.85
    }

    boiler_eff = input_arguments['boiler_eff']

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(1, arguments.size)
    assert_equal(0.85, arguments[0].defaultValueAsDouble)

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

    model.getBoilerHotWaters.each do |boiler_water|
      assert_equal(boiler_eff, boiler_water.nominalThermalEfficiency, "boiler efficiency is incorrect")
    end

    # save the model to test output directory
    output_file_path = "#{File.dirname(__FILE__)}//#{test_dir}/test_output.osm"
    model.save(output_file_path, true)
  end
end
