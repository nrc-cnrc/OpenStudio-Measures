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

class NrcSetFenestrationWallConductanceByNecbClimateZone_Test < Minitest::Test
  include(NRCMeasureTestHelper)

  # Define the output folder.
  @@test_dir = "#{File.dirname(__FILE__)}/output"
  # Remove if existing found. This should only be done once.
  if Dir.exists?(@@test_dir)
    FileUtils.rm_rf(@@test_dir)
  end
  Dir.mkdir(@@test_dir)

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
        "display_name" => "NECB Zone4 Fenestration Insulation U-value (W/m^2 K).",
        "default_value" => 1.9,
        "max_double_value" => 5.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "zone5_u_value",
        "type" => "Double",
        "display_name" => "NECB Zone5 Fenestration Insulation U-value (W/m^2 K).",
        "default_value" => 1.8,
        "max_double_value" => 5.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "zone6_u_value",
        "type" => "Double",
        "display_name" => "NECB Zone6 Fenestration Insulation U-value (W/m^2 K).",
        "default_value" => 1.7,
        "max_double_value" => 5.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "zone7A_u_value",
        "type" => "Double",
        "display_name" => "NECB Zone7A Fenestration Insulation U-value (W/m^2 K).",
        "default_value" => 1.5,
        "max_double_value" => 5.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "zone7B_u_value",
        "type" => "Double",
        "display_name" => "NECB Zone7B Fenestration Insulation U-value (W/m^2 K).",
        "default_value" => 1.4,
        "max_double_value" => 5.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "zone8_u_value",
        "type" => "Double",
        "display_name" => "NECB Zone8 Fenestration Insulation U-value (W/m^2 K).",
        "default_value" => 1.3,
        "max_double_value" => 5.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]

    @good_input_arguments = {
      "necb_template" => "NECB2017",
      "zone4_u_value" => 1.9,
      "zone5_u_value" => 1.8,
      "zone6_u_value" => 1.7,
      "zone7A_u_value" => 1.5,
      "zone7B_u_value" => 1.4,
      "zone8_u_value" => 1.3
    }
  end

  # Tests follow. Basically create a NECB2015 model and apply the @good_arguments (which are the NECB2017 values)
  # Check that every surface that should have been update has been.
  def check_values(model, value)

    #Find all roofs and set the construction U_value.
    sub_surfaces = model.getSubSurfaces
    sub_surfaces.each do |sub_surface|
      if sub_surface.outsideBoundaryCondition == "Outdoors" and (sub_surface.subSurfaceType == "FixedWindow" || sub_surface.subSurfaceType == "OperableWindow" || sub_surface.subSurfaceType == "Skylight" || sub_surface.subSurfaceType == "TubularDaylightDiffuser" || sub_surface.subSurfaceType == "TubularDaylightDome")
        surface_conductance = BTAP::Geometry::Surfaces.get_surface_construction_conductance(sub_surface)
        msg = "Surface #{sub_surface.name.to_s}"
        assert_in_delta(value, surface_conductance, 0.005, msg)
      end
    end
  end

  def test_Zone4_conductance

    # Define the output folder for this test. 
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/4")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw',
                                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct u value for the correct climate zone.
    check_values(model, 1.9)
  end

  def test_Zone5_conductance

    # Define the output folder for this test. 
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/5")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw',
                                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct u value for the correct climate zone.
    check_values(model, 1.8)
  end

  def test_Zone6_conductance

    # Define the output folder for this test. 
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/6")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw',
                                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Test if the measure would grab the correct u value for the correct climate zone.
    check_values(model, 1.7)
  end

  def test_Zone7a_conductance

    # Define the output folder for this test. 
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/7a")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw',
                                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct u value for the correct climate zone
    check_values(model, 1.5)
  end

  def test_Zone7b_conductance

    # Define the output folder for this test. 
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/7b")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw',
                                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct u value for the correct climate zone
    check_values(model, 1.4)
  end

  def test_Zone8_conductance

    # Define the output folder for this test. 
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/8")

    # Create a default model.
    standard = Standard.build("NECB2017")
    model = standard.model_create_prototype_model(template: "NECB2015",
                                                  building_type: "SmallOffice",
                                                  epw_file: 'CAN_NT_Yellowknife.AP.719360_CWEC2016.epw',
                                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    # Set argument values to good values and run the measure on model with spaces
    runner = run_measure(@good_input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # test if the measure would grab the correct u value for the correct climate zone
    check_values(model, 1.3)
  end
end
