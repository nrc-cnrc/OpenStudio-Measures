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

class NrcHvacModifyPlantLoopPump_Test < Minitest::Test

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
            "name" => "motor_efficiency",
            "type" => "Double",
            "display_name" => "Motor efficiency (%)",
            "default_value" => 65.0,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]

    @good_input_arguments = {
        "plant_loop" => "All",
        "motor_efficiency" => 87.0,
    }

  end

# Test  
  def test_dx_cooling()
    puts "Testing modification of single stage DX cooling coil".blue
	
    ####### Create a test model ######
    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder", @good_input_arguments)

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                      building_type: "Warehouse",
                                                      epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
													  sizing_run_dir: output_file_path)

    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, model)
    puts show_output(runner.result)
    assert(runner.result.value.valueName == 'Success')
	
	# Set local vars for arguments.
	new_motor_efficiency = @good_input_arguments['motor_efficiency']
	
	# Now check that the burner efficiency has been properly changed.
    model.getLoops.each do |loop|
	  puts "Air loop name: #{loop.name}".light_blue
      loop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Pump:ConstantSpeed" 
		  pump = comp.to_PumpConstantSpeed.get
		  value = pump.motorEfficiency * 100.0
		  assert_in_delta(new_motor_efficiency, value, delta = 0.01, msg = 'Motor efficiency (%)')
        elsif comp.iddObject.name.include? "OS:Pump:VariableSpeed" 
		  pump = comp.to_PumpVariableSpeed.get
		  value = pump.motorEfficiency * 100.0
		  assert_in_delta(new_motor_efficiency, value, delta = 0.01, msg = 'Motor efficiency (%)')
		end
	  end
    end
    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
