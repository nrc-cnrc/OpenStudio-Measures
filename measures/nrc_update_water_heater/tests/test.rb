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

    # Load the test model.
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

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

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

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end

end
