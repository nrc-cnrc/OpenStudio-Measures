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

class NrcAddHvacAvailabilityManager_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()

    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "heatcool",
        "type" => "Choice",
        "display_name" => "Apply to",
        "default_value" => "cooling",
        "choices" => ["cooling", "heating"],
        "is_required" => true
      },
      {
        "name" => "setPoint",
        "type" => "Double",
        "display_name" => "Turn off setpoint",
        "default_value" => 15,
        "max_double_value" => 50.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]
    @good_input_arguments= {
      "heatcool" => "cooling",
      "setPoint" => 12.0,
    }
  end

  def test_availabilityManager()
    puts "Testing  cooling availability manager".green

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "LargeOffice",
                                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Set up your argument list to test.
   input_arguments = @good_input_arguments

    # Create an instance of the measure
    runner = run_measure(input_arguments, model)
    puts show_output(runner.result)

    availabilityManagers = model.getAvailabilityManagers
    availabilityManagers.each do |availabilityManager|
      name = availabilityManager.name
      if (name.to_s.include? "Low Temperature Turn Off") || (name.to_s.include? "High Temperature Turn Off")
        # Test if the measure sets the availability Manager to 'AvailabilityManagerLowTemperatureTurnOff', if "cooling" is selected as input_argument.
        # Also test the temperature is set to the value of the setPoint input argument.
        if input_arguments["heatcool"] == "cooling"
          availabilityM_low = availabilityManager.to_AvailabilityManagerLowTemperatureTurnOff.get
          temperature = availabilityM_low.temperature
          puts "Availability Manager name :".green + " #{name}".light_blue
          puts "Availability Manager set point temperature :".green + " #{temperature}".light_blue
          assert (name.to_s.include? "Low Temperature Turn Off")
          assert (temperature == input_arguments["setPoint"])

          # Test if the measure sets the availability Manager to 'AvailabilityManagerHighTemperatureTurnOff', if "heating" is selected as input_argument.
          # Also test the temperature is set to the value of the setPoint input argument.
        elsif input_arguments["heatcool"] == "heating"
          availabilityM_high = availabilityManager.to_AvailabilityManagerHighTemperatureTurnOff.get
          temperature = availabilityM_high.temperature
          puts "Availability Manager name :".green + " #{name}".light_blue
          puts "Availability Manager set point temperature :".green + " #{temperature}".light_blue
          assert (name.to_s.include? "High Temperature Turn Off")
          assert (temperature == input_arguments["setPoint"])
        end
      end
    end
    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
    puts "Runner output #{show_output(runner.result)}".green
    assert(runner.result.value.valueName == 'Success')
  end
end
