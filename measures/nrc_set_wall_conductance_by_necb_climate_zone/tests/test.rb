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

class NrcSetWallConductanceByNecbClimateZone_Test  < Minitest::Test
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
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    #Use percentages instead of values
    @use_percentages = false

    #Set to true if debugging measure.
    @debug = true
    #this is the 'do nothing value and most arguments should have. '
    @baseline = 0.0

    @measure_interface_detailed = [
        {
            "name" => "necb_template",
            "type" => "Choice",
            "display_name" => "Template",
            "default_value" => "NECB2017",
            "choices" => ["NECB2011", "NECB2015", "NECB2017"],
            "is_required" => true
        },
        {
            "name" => "zone4_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone4 Wall Insulation U-value (W/m^2 K).",
            "default_value" => 0.29,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone5_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone5 Wall Insulation U-value (W/m^2 K).",
            "default_value" => 0.265,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone6_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone6 Wall Insulation U-value (W/m^2 K).",
            "default_value" => 0.240,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone7A_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone7A Wall Insulation U-value (W/m^2 K).",
            "default_value" => 0.215,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone7B_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone7B Wall Insulation U-value (W/m^2 K).",
            "default_value" => 0.190,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone8_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone8 Wall Insulation U-value (W/m^2 K).",
            "default_value" => 0.165,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]
    @good_input_arguments = {
        "necb_template" => "NECB2017",
        "zone4_u_value" => 0.290,
        "zone5_u_value" => 0.265,
        "zone6_u_value" => 0.240,
        "zone7A_u_value" => 0.215,
        "zone7B_u_value" => 0.190,
        "zone8_u_value" => 0.165
    }
  end
  
# Tests follow. Basically create a NECB2015 model and apply the @good_arguments (which are the NECB2017 values)
# Check that every surface that should have been update has been.
  def check_values(model, value)
  
    #Find all roofs and set the construction U_value.
    surfaces = model.getSurfaces
    surfaces.each do |surface|
      if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "Wall"
        surface_conductance = BTAP::Geometry::Surfaces.get_surface_construction_conductance(surface)
		msg = "Surface #{surface.name.to_s}"
		assert_in_delta(value, surface_conductance,0.0005, msg)
	  end
    end
  end
  
  def test_Zone4_conductance

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder_zone4")

	
    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw',
												  sizing_run_dir: output_file_path)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct u value for the correct climate zone.
	check_values(model, 0.290)
  end

  def test_Zone5_conductance

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder_zone5")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw',
												  sizing_run_dir: output_file_path)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct u value for the correct climate zone.
	check_values(model, 0.265)
  end


  def test_Zone6_conductance

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder_zone6")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw',
												  sizing_run_dir: output_file_path)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct u value for the correct climate zone.
	check_values(model, 0.240)
  end


  def test_Zone7a_conductance

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder_zone7a")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw',
												  sizing_run_dir: output_file_path)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct u value for the correct climate zone
	check_values(model, 0.215)
  end

  def test_Zone7b_conductance

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder_zone7b")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw',
												  sizing_run_dir: output_file_path)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct u value for the correct climate zone
	check_values(model, 0.190)
  end


  def test_Zone8_conductance

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_NT_Yellowknife.AP.719360_CWEC2016.epw',
												  sizing_run_dir: output_file_path)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct u value for the correct climate zone
	check_values(model, 0.165)
  end
end
