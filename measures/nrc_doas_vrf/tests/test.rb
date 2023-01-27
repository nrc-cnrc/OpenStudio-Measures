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

class NrcDOASVRF_Test < Minitest::Test

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
            "name" => "loops_to_change",
            "type" => "String",
            "display_name" => 'Loops to change',
            "default_value" => "All",
            "is_required" => true
        }]
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcDOASVRF.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "loops_to_change" => 'All'
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
    assert_equal("All", arguments[0].defaultValueAsString)

    #get number of air loops and zones connected to those loops prior
    num_airloops_initial = 0
    numb_zones_in_loop_initial = 0
    model.getAirLoopHVACs.each do |airloop|
      num_airloops_initial = num_airloops_initial +1
      numb_zones_in_loop_initial = numb_zones_in_loop_initial + airloop.thermalZones.size
    end

    #check number of zones and loops did not change
    num_airloops_final = 0
    numb_zones_in_loop_final = 0
    model.getAirLoopHVACs.each do |airloop|
      num_airloops_final = num_airloops_final +1
      numb_zones_in_loop_final = numb_zones_in_loop_final + airloop.thermalZones.size
    end
    assert_equal(num_airloops_initial, num_airloops_final, "number of air loops before and after don't match")
    assert_equal(numb_zones_in_loop_initial, numb_zones_in_loop_final, "number of zones connected to air loop doesn't match, before and after")

    #check if doas is first in heating cooling order
    zone_lists = model.getZoneHVACEquipmentLists
    model.getAirLoopHVACs.each do |airloop|
      airloop.thermalZones.each do |zone|
        terminal = zone.airLoopHVACTerminal.get.to_HVACComponent.get
        zone_lists.each do |zone_list|
          if zone_list.thermalZone == zone
            assert_equal(1, zone_list.coolingPriority(terminal).to_i, "DOAS is not first in cooling order")
            assert_equal(1, zone_list.heatingPriority(terminal).to_i, "DOAS is not first in heating order")
            assert(zone_list.equipmentInCoolingOrder[1].name.to_s.include?("Variable Refrigerant Flow"), "VRF terminal is not 2nd in cooling order")
            assert(zone_list.equipmentInHeatingOrder[1].name.to_s.include?("Variable Refrigerant Flow"), "VRF terminal is not 2nd in heating order")
          end
        end
      end
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
