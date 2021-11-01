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

class NrcUpdateWaterHeater_Test < Minitest::Test
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()
    @measure_interface_detailed = [
        {
            "name" => "update_waterheater_pcf2020",
            "type" => "Bool",
            "display_name" => 'Update water heater to PCF value?',
            "default_value" => true,
            "is_required" => true
        }]
    @good_input_arguments = {
        "update_waterheater_pcf2020" => true
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcUpdateWaterHeater.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/in.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)

    input_arguments = {
        "update_waterheater_pcf2020" => true
    }

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(1, arguments.size)
    assert_equal(true, arguments[0].defaultValueAsBool)

    #get water heater performance before applying measure
    offCycleLossCoefficienttoAmbientTemperature = 1
    onCycleLossCoefficienttoAmbientTemperature = 1
    heaterThermalEfficiency = 1
    model.getWaterHeaterMixeds.each do |water_heater_mixed|
      offCycleLossCoefficienttoAmbientTemperature = water_heater_mixed.offCycleLossCoefficienttoAmbientTemperature.get
      onCycleLossCoefficienttoAmbientTemperature = water_heater_mixed.onCycleLossCoefficienttoAmbientTemperature.get
      heaterThermalEfficiency = water_heater_mixed.heaterThermalEfficiency.get
    end

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

    #check if water heater efficiency was changed correctly
    model.getWaterHeaterMixeds.each do |water_heater_mixed|
      new_offCycleLossCoefficienttoAmbientTemperature = water_heater_mixed.offCycleLossCoefficienttoAmbientTemperature.get
      new_OnCycleLossCoefficienttoAmbientTemperature = water_heater_mixed.onCycleLossCoefficienttoAmbientTemperature.get
      new_heaterThermalEfficiency = water_heater_mixed.heaterThermalEfficiency.get

      assert heaterThermalEfficiency != new_heaterThermalEfficiency, "water heater heaterThermalEfficiency did not changee"
      assert offCycleLossCoefficienttoAmbientTemperature != new_offCycleLossCoefficienttoAmbientTemperature, "water heater offCycleLossCoefficienttoAmbientTemperature did not change"
      assert onCycleLossCoefficienttoAmbientTemperature != new_OnCycleLossCoefficienttoAmbientTemperature, "water heater onCycleLossCoefficienttoAmbientTemperature did not change"
    end

    # save the model to test output directory
    output_file_path = "#{File.dirname(__FILE__)}//#{test_dir}/test_output.osm"
    model.save(output_file_path, true)
  end

end
