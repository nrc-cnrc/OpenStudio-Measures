# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcDrainWaterHeatRecovery_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()

    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "plant_loop",
        "type" => "String",
        "display_name" => "Plant loop to apply change to (currently all is only option)",
        "default_value" => "All",
        "is_required" => true
      },
      {
        "name" => "ua",
        "type" => "Double",
        "display_name" => "UA value of heat exchanger (W/mK)",
        "default_value" => 3000,
        "is_required" => true
      }
    ]

    @good_input_arguments = {
      "plant_loop" => "All",
      "ua" => 3000
    }
  end

  # Custom way to run an energy plus measure in the test.
  def run_measure(input_arguments, workspace)

    # This will create a instance of the measure you wish to test. It does this based on the test class name.
    measure = get_measure_object()
    measure.use_json_package = @use_json_package
    measure.use_string_double = @use_string_double
    # Return false if can't
    return false if false == measure
    arguments = measure.arguments(workspace)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
    #Check if

    # Set the arguements in the argument map use json or real arguments.
    if @use_json_package
      argument = arguments[0].clone
      assert(argument.setValue(input_arguments['json_input']), "Could not set value for 'json_input' to #{input_arguments['json_input']}")
      argument_map['json_input'] = argument
    else
      input_arguments.each_with_index do |(key, value), index|
        argument = arguments[index].clone
        if argument_type(argument) == "Double"
          #forces it to a double if it is a double.
          assert(argument.setValue(value.to_f), "Could not set value for #{key} to #{value}")
        else
          assert(argument.setValue(value.to_s), "Could not set value for #{key} to #{value}")
        end
        argument_map[key] = argument
      end
    end
    #run the measure
    measure.run(workspace, runner, argument_map)
    runner.result
    return runner
  end

  def test_drainwater()

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

    # Load the test workspace
    idf_file = File.dirname(__FILE__) + '/in.idf'
    assert(File.exists?(idf_file))
    workspace = OpenStudio::Workspace::load(OpenStudio::Path.new(idf_file))
    assert((not workspace.empty?))
    workspace = workspace.get

    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, workspace)

    # Get results of measure
    output_run_summary(runner.result)

    # Check output
    connections = workspace.getObjectsByType('WaterUse:Connections'.to_IddObjectType)
    connections.each do |connection|
      msg = "Water Use Connection #{connection.name.to_s} drain water UA value"
      assert_in_delta(@good_input_arguments['ua'], connection.idfObject.getDouble(9).get, 0.5, msg)
    end
  end

  def output_run_summary(result)
    # Standard measure reporting for the test.
    assert(result.value.valueName == 'Success')

    # Echo messages from the measure to the screen, in colour!
    if result.initialCondition.is_initialized then
      puts "#{result.initialCondition.get.logMessage}".green
    end
    result.info.each { |msg| puts "INFO: #{msg.logMessage}" }
    result.warnings.each { |msg| puts "WARN: #{msg.logMessage}".yellow }
    result.errors.each { |msg| puts "ERROR: #{msg.logMessage}".red }
    if result.finalCondition.is_initialized then
      puts "#{result.finalCondition.get.logMessage}".green
    end
  end

end
