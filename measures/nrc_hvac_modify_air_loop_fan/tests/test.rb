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

class NrcHvacModifyAirLoopFan_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "air_loop",
        "type" => "String",
        "display_name" => "Air loop to apply change to (currently all is only option)",
        "default_value" => "All",
        "is_required" => true
      },
      {
        "name" => "pressure_rise",
        "type" => "Double",
        "display_name" => "Pressure rise (Pa)",
        "default_value" => 640.0,
        "max_double_value" => 2000.0,
        "min_double_value" => -1.0,
        "is_required" => true
      },
      {
        "name" => "fan_efficiency",
        "type" => "Double",
        "display_name" => "Fan efficiency (%)",
        "default_value" => 80.0,
        "max_double_value" => 100.0,
        "min_double_value" => -1.0,
        "is_required" => true
      },
      {
        "name" => "motor_efficiency",
        "type" => "Double",
        "display_name" => "Motor efficiency (%)",
        "default_value" => 80.0,
        "max_double_value" => 100.0,
        "min_double_value" => -1.0,
        "is_required" => true
      }
    ]
    @good_input_arguments = {
      "air_loop" => "All",
      "pressure_rise" => 750.0,
      "fan_efficiency" => 85.0,
      "motor_efficiency" => 81.0,
    }
  end

  # Test
  def test_modify_fan()
    puts "Testing modification of fan".green

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_modify_fan")

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "RetailStripmall",
                                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, model)
    puts show_output(runner.result)
    assert(runner.result.value.valueName == 'Success')

    # Set local vars for arguments.
    new_pressure_rise = @good_input_arguments['pressure_rise']
    new_fan_efficiency = @good_input_arguments['fan_efficiency']
    new_motor_efficiency = @good_input_arguments['motor_efficiency']

    # Now check that the burner efficiency has been properly changed.
    model.getLoops.each do |loop|
      puts "Air loop name:".green + " #{loop.name}".light_blue
      loop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Fan:ConstantVolume"
          fan = comp.to_FanConstantVolume.get
          value = fan.pressureRise
          msg = "Pressure rise (Pa) was supposed to be equal #{new_pressure_rise} but got #{value} instead".red
          assert_in_delta(new_pressure_rise, value, delta = 1, msg)
          value = fan.fanTotalEfficiency * 100.0
          msg = "Fan total efficiency (%) was supposed to be equal #{new_fan_efficiency} but got #{value} instead".red
          assert_in_delta(new_fan_efficiency, value, delta = 0.01, msg)
          value = fan.motorEfficiency * 100.0
          msg = "Fan motor efficiency (%) was supposed to be equal #{new_motor_efficiency} but got #{value} instead".red
          assert_in_delta(new_motor_efficiency, value, delta = 0.01, msg)
        elsif comp.iddObject.name.include? "OS:Fan:VariableVolume"
          fan = comp.to_FanVariableVolume.get
          value = fan.pressureRise
          msg = "Pressure rise (Pa) was supposed to be equal #{new_pressure_rise} but got #{value} instead".red
          assert_in_delta(new_pressure_rise, value, delta = 1, msg)
          value = fan.fanTotalEfficiency * 100.0
          msg = "Fan total efficiency (%) was supposed to be equal #{new_fan_efficiency} but got #{value} instead".red
          assert_in_delta(new_fan_efficiency, value, delta = 0.01, msg)
          value = fan.motorEfficiency * 100.0
          msg = "Fan motor efficiency (%) was supposed to be equal #{new_motor_efficiency} but got #{value} instead".red
          assert_in_delta(new_motor_efficiency, value, delta = 0.01, msg)
        end
      end
    end
    # save the model to test output directory
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
    puts "Runner output #{show_output(runner.result)}".green
    assert(runner.result.value.valueName == 'Success')
  end
end
