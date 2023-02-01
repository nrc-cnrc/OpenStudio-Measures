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

class NrcChangeCAVToVAV_Test < Minitest::Test

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
            "name" => "airLoopSelected",
            "type" => "String",
            "display_name" => "Which Air loop? To skip the measure, please enter 'skip' ",
            "default_value" => "All Air Loops",
            "is_required" => true
        }]
    @good_input_arguments = {
        "airLoopSelected" => true
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcChangeCAVToVAV.new
    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "airLoopSelected" => "All Air Loops"
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
    assert_equal("All Air Loops", arguments[0].defaultValueAsString)

    #check setpoint manager, fan, and terminal
    model.getAirLoopHVACs.each do |air_loop|
      air_loop.supplyComponents.each do |supply_component|
        if supply_component.to_FanVariableVolume.is_initialized
          vav_fan = supply_component.to_FanVariableVolume.get
          assert(vav_fan.name.to_s.include?("new VAV fan"))
          assert(air_loop.supplyOutletNode.to_Node.get.setpointManagers[0].name.to_s.include?("SAT stpmanager"))
        end
      end
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
