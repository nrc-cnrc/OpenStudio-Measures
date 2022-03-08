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

class NrcHvacModifyAirLoopGasHeatingCoil_Test < Minitest::Test

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
            "name" => "burner_efficiency",
            "type" => "Double",
            "display_name" => "Burner efficiency (%)",
            "default_value" => 82.0,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]

    @good_input_arguments = {
        "air_loop" => "All",
        "burner_efficiency" => 85.0,
    }

  end

# Test  
  def test_burner_efficiency()
    puts "Testing modification of burner efficiency".blue
	
    ####### Create a test model ######
	  # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_burner_efficiency")

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                      building_type: "RetailStripmall",
                                                      epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
													  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, model)
    puts show_output(runner.result)
    assert(runner.result.value.valueName == 'Success')
	
	# Now check that the burner efficiency has been properly changed.
    model.getLoops.each do |loop|
	  puts "Air loop name: #{loop.name}".light_blue
      loop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Coil:Heating:Gas" 
		  eff = comp.to_CoilHeatingGas.get.gasBurnerEfficiency * 100.0
		  assert_in_delta(@good_input_arguments['burner_efficiency'], eff, delta = 0.01, msg = 'Burner efficiency (%)')
		end
	  end
    end
    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
