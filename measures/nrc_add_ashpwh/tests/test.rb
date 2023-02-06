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

class NrcAddASHPWH_Test < Minitest::Test

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
            "name" => "frac_oa",
            "type" => "Double",
            "display_name" => 'Set frac_oa',
            "default_value" => 1.0,
            "is_required" => true
        }]
    @good_input_arguments = {
        "frac_oa" => 1.0
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcAddASHPWH.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # Set arguments.
    input_arguments = {
        "frac_oa" => 1.0
    }

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder", input_arguments)

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # check if a HPWH was added
    ashpwhs = model.getWaterHeaterHeatPumps
    assert(ashpwhs.size.to_i > 0)

    #check if ashpwh is connected to a zone correctly
    ashpwhs.each do |ashpwh|
      assert(ashpwh.tank.to_WaterHeaterMixed.get.ambientTemperatureThermalZone.get, "Water heater tank is not located in a zone")
      model.getZoneHVACEquipmentLists.each do |list|
        if list.thermalZone == ashpwh.tank.to_WaterHeaterMixed.get.ambientTemperatureThermalZone.get
          assert_equal(1, list.coolingPriority(ashpwh), "ASHPWH is not the first cooling")
          assert_equal(1, list.heatingPriority(ashpwh), "ASHPWH is not the first cooling")
        end
      end
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)

  end
end

