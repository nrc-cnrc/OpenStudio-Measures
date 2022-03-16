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

class NrcAddDOASSys_Test < Minitest::Test
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  start_time=Time.now
  if ARGV.length == 1

    # We have a time. It will be in seconds since the epoch. Update our start_time.
    start_time=Time.at(ARGV[0].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)

  def setup()
    @measure_interface_detailed = [
        {
            "name" => "zonesselected",
            "type" => "String",
            "display_name" => 'Choose which zones to add DOAS to',
            "default_value" => "All Zones",
            "is_required" => true
        }]
    @good_input_arguments = {
        "zonesselected" => "All Zones"
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcAddDOASSys.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)

    input_arguments = {
        "zonesselected" => "All Zones"
    }

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(1, arguments.size)

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    assert(result.warnings.empty?)

    # check for number of zonehvac:ERV
    num_of_ervs = model.getZoneHVACEnergyRecoveryVentilators.size
    num_of_zones = 0
    model.getAirLoopHVACs.each do |airloop|
      num_of_zones = num_of_zones + airloop.thermalZones.size.to_i
    end
    assert_equal(num_of_zones, num_of_ervs, "number of ervs do not match zones")

    #check for air loop outdoor air flowrate
    model.getAirLoopHVACs.each do |airloop|
      outdoor_flow = 1.0
      if airloop.airLoopHVACOutdoorAirSystem.is_initialized
        if airloop.airLoopHVACOutdoorAirSystem.get.getControllerOutdoorAir.maximumOutdoorAirFlowRate.is_initialized
          outdoor_flow = airloop.airLoopHVACOutdoorAirSystem.get.getControllerOutdoorAir.maximumOutdoorAirFlowRate.get.to_f
        end
      end
      assert (0.001 > outdoor_flow)
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)

  end
end
