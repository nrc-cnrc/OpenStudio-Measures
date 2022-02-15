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

class NrcHvacModifyDxSingleStageCooling_Test < Minitest::Test

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
            "name" => "cop",
            "type" => "Double",
            "display_name" => "Rated COP (-)",
            "default_value" => 3.0,
            "max_double_value" => 10.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]

    @good_input_arguments = {
        "air_loop" => "All",
        "cop" => 4.0,
    }

  end

# Test  
  def test_dx_cooling()
    puts "Testing modification of single stage DX cooling coil".blue
	
    ####### Create a test model ######
    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

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
	
	# Set local vars for arguments.
	new_cop = @good_input_arguments['cop']
	
	# Now check that the burner efficiency has been properly changed.
    model.getLoops.each do |loop|
	  puts "Air loop name: #{loop.name}".light_blue
      loop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Coil:Cooling:DX:SingleSpeed" 
		  coil = comp.to_CoilCoolingDXSingleSpeed.get
		  value = coil.ratedCOP.get
		  assert_in_delta(new_cop, value, delta = 0.01, msg = 'Rated COP (-)')
		end
	  end
    end
    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
