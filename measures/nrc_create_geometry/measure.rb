# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require 'openstudio-standards'
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcCreateGeometry < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  # human readable name
  def name
    #BEFORE YOU DO anything.. please generate a new <uid>224561f4-8ccc-4f60-8118-34b85359d6f7</uid>
    return "NrcCreateGeometry"
  end

  # human readable description
  def description
    return "Create standard building shapes and define spaces. The total floor area, and number of floors are specified. The building is assumed to be in thirds (thus for the courtyard the middle third is the void)"
  end

  # human readable description of modeling approach
  def modeler_description
    return "Defines the geometry of the building based on the given inputs. Uses BTAP::Geometry::Wizards::create_shape_* methods"
  end

  #Use the constructor to set global variables
  def initialize()
    super()

    #Set to true if you want to package the arguments as json.
    @use_json_package = false

    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    #@use_string_double = true
    @use_string_double = false

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "building_shape",
        "type" => "Choice",
        "display_name" => "Building shape",
        "default_value" => "Rectangular",
        "choices" => ["Courtyard", "H-Shape", "L-Shape", "Rectangular", "T-Shape", "U-Shape"],
        "is_required" => true
      },
      {
        "name" => "template",
        "type" => "Choice",
        "display_name" => "template",
        "default_value" => "NECB2011",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020"],
        "is_required" => true
      },
      {
        "name" => "building_type",
        "type" => "Choice",
        "display_name" => "Building Type ",
        "default_value" => "SmallOffice",
        "choices" => ["SecondarySchool", "PrimarySchool", "SmallOffice", "MediumOffice", "LargeOffice", "SmallHotel", "LargeHotel", "Warehouse", "RetailStandalone", "RetailStripmall", "QuickServiceRestaurant", "FullServiceRestaurant", "MidriseApartment", "HighriseApartment", "Hospital", "Outpatient",],
        "is_required" => true
      },
      {
        "name" => "epw_file",
        "type" => "Choice",
        "display_name" => "Weather file",
        "default_value" => 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw',
        "choices" => ['CAN_AB_Banff.CS.711220_CWEC2016.epw', 'CAN_AB_Calgary.Intl.AP.718770_CWEC2016.epw', 'CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw', 'CAN_AB_Edmonton.Stony.Plain.AP.711270_CWEC2016.epw', 'CAN_AB_Fort.McMurray.AP.716890_CWEC2016.epw', 'CAN_AB_Grande.Prairie.AP.719400_CWEC2016.epw', 'CAN_AB_Lethbridge.AP.712430_CWEC2016.epw', 'CAN_AB_Medicine.Hat.AP.710260_CWEC2016.epw', 'CAN_BC_Abbotsford.Intl.AP.711080_CWEC2016.epw', 'CAN_BC_Comox.Valley.AP.718930_CWEC2016.epw', 'CAN_BC_Crankbrook-Canadian.Rockies.Intl.AP.718800_CWEC2016.epw', 'CAN_BC_Fort.St.John-North.Peace.Rgnl.AP.719430_CWEC2016.epw', 'CAN_BC_Hope.Rgnl.Airpark.711870_CWEC2016.epw', 'CAN_BC_Kamloops.AP.718870_CWEC2016.epw', 'CAN_BC_Port.Hardy.AP.711090_CWEC2016.epw', 'CAN_BC_Prince.George.Intl.AP.718960_CWEC2016.epw', 'CAN_BC_Smithers.Rgnl.AP.719500_CWEC2016.epw', 'CAN_BC_Summerland.717680_CWEC2016.epw', 'CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw', 'CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw', 'CAN_MB_Brandon.Muni.AP.711400_CWEC2016.epw', 'CAN_MB_The.Pas.AP.718670_CWEC2016.epw', 'CAN_MB_Winnipeg-Richardson.Intl.AP.718520_CWEC2016.epw', 'CAN_NB_Fredericton.Intl.AP.717000_CWEC2016.epw', 'CAN_NB_Miramichi.AP.717440_CWEC2016.epw', 'CAN_NB_Saint.John.AP.716090_CWEC2016.epw', 'CAN_NL_Gander.Intl.AP-CFB.Gander.718030_CWEC2016.epw', 'CAN_NL_Goose.Bay.AP-CFB.Goose.Bay.718160_CWEC2016.epw', 'CAN_NL_St.Johns.Intl.AP.718010_CWEC2016.epw', 'CAN_NL_Stephenville.Intl.AP.718150_CWEC2016.epw', 'CAN_NS_CFB.Greenwood.713970_CWEC2016.epw', 'CAN_NS_CFB.Shearwater.716010_CWEC2016.epw', 'CAN_NS_Sable.Island.Natl.Park.716000_CWEC2016.epw', 'CAN_NT_Inuvik-Zubko.AP.719570_CWEC2016.epw', 'CAN_NT_Yellowknife.AP.719360_CWEC2016.epw', 'CAN_ON_Armstrong.AP.718410_CWEC2016.epw', 'CAN_ON_CFB.Trenton.716210_CWEC2016.epw', 'CAN_ON_Dryden.Rgnl.AP.715270_CWEC2016.epw', 'CAN_ON_London.Intl.AP.716230_CWEC2016.epw', 'CAN_ON_Moosonee.AP.713980_CWEC2016.epw', 'CAN_ON_Mount.Forest.716310_CWEC2016.epw', 'CAN_ON_North.Bay-Garland.AP.717310_CWEC2016.epw', 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw', 'CAN_ON_Sault.Ste.Marie.AP.712600_CWEC2016.epw', 'CAN_ON_Timmins.Power.AP.717390_CWEC2016.epw', 'CAN_ON_Toronto.Pearson.Intl.AP.716240_CWEC2016.epw', 'CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw', 'CAN_PE_Charlottetown.AP.717060_CWEC2016.epw', 'CAN_QC_Kuujjuaq.AP.719060_CWEC2016.epw', 'CAN_QC_Kuujuarapik.AP.719050_CWEC2016.epw', 'CAN_QC_Lac.Eon.AP.714210_CWEC2016.epw', 'CAN_QC_Mont-Joli.AP.717180_CWEC2016.epw', 'CAN_QC_Montreal-Mirabel.Intl.AP.719050_CWEC2016.epw', 'CAN_QC_Montreal-St-Hubert.Longueuil.AP.713710_CWEC2016.epw', 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw', 'CAN_QC_Quebec-Lesage.Intl.AP.717140_CWEC2016.epw', 'CAN_QC_Riviere-du-Loup.717150_CWEC2016.epw', 'CAN_QC_Roberval.AP.717280_CWEC2016.epw', 'CAN_QC_Saguenay-Bagotville.AP-CFB.Bagotville.717270_CWEC2016.epw', 'CAN_QC_Schefferville.AP.718280_CWEC2016.epw', 'CAN_QC_Sept-Iles.AP.718110_CWEC2016.epw', 'CAN_QC_Val-d-Or.Rgnl.AP.717250_CWEC2016.epw', 'CAN_SK_Estevan.Rgnl.AP.718620_CWEC2016.epw', 'CAN_SK_North.Battleford.AP.718760_CWEC2016.epw', 'CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw', 'CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw'],
        "is_required" => true
      },
      {
        "name" => "total_floor_area",
        "type" => "Double",
        "display_name" => "Total building area (m2)",
        "default_value" => 50000.0,
        "max_double_value" => 10000000.0,
        "min_double_value" => 10.0,
        "is_required" => true
      },
      {
        "name" => "aspect_ratio",
        "type" => "Double",
        "display_name" => "Aspect ratio (width/length; width faces south before rotation)",
        "default_value" => 1.0,
        "max_double_value" => 10.0,
        "min_double_value" => 0.1,
        "is_required" => true
      },
      {
        "name" => "rotation",
        "type" => "Double",
        "display_name" => "Rotation (degrees clockwise)",
        "default_value" => 0.0,
        "max_double_value" => 360.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "above_grade_floors",
        "type" => "Integer",
        "display_name" => "Number of above grade floors",
        "default_value" => 3,
        "max_integer_value" => 200,
        "min_integer_value" => 1,
        "is_required" => true
      },
      {
        "name" => "floor_to_floor_height",
        "type" => "Double",
        "display_name" => "Floor to floor height (m)",
        "default_value" => 3.8,
        "max_double_value" => 10.0,
        "min_double_value" => 2.0,
        "is_required" => false
      },
      {
        "name" => "plenum_height",
        "type" => "Double",
        "display_name" => "Plenum height (m)",
        "default_value" => 1.0,
        "max_double_value" => 2.0,
        "min_double_value" => 0.1,
        "is_required" => false
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    #Runs parent run method.
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # assign the user inputs to variables
    building_shape = arguments['building_shape']
    building_type = arguments['building_type']
    template = arguments['template']
    epw_file = arguments['epw_file']
    total_floor_area = arguments['total_floor_area']
    aspect_ratio = arguments['aspect_ratio']
    rotation = arguments['rotation']
    above_grade_floors = arguments['above_grade_floors']
    floor_to_floor_height = arguments['floor_to_floor_height']
    plenum_height = arguments['plenum_height']
    floor_area = total_floor_area / above_grade_floors
    climate_zone = 'NECB HDD Method'

    # reporting initial condition of model
    starting_spaceTypes = model.getSpaceTypes
    starting_constructionSets = model.getDefaultConstructionSets
    stds_spc_type = ''
    runner.registerInitialCondition("The building started with #{starting_spaceTypes.size} space types.")

    #" ******************* Creating Courtyard Shape ***********************************"
    if building_shape == 'Courtyard'
      # Figure out dimensions from inputs
      len = Math::sqrt((9.0 / 8.0) * floor_area)
      a = len * aspect_ratio
      b = len / aspect_ratio
      # Set perimeter depth to min of 1/3 smallest section width or 4.57 (=BTAP default)
      perimeter_depth = [([a, b].min / 9.0), 4.57].min
      # Generate the geometry
      model = BTAP::Geometry::Wizards::create_shape_courtyard(model,
                                                              length = a,
                                                              width = b,
                                                              courtyard_length = a / 3.0,
                                                              courtyard_width = b / 3.0,
                                                              above_ground_storys = above_grade_floors,
                                                              floor_to_floor_height = floor_to_floor_height,
                                                              plenum_height = plenum_height,
                                                              perimeter_zone_depth = perimeter_depth)

      #" ******************* Creating Rectangular Shape ***********************************"
    elsif building_shape == 'Rectangular'
      # Figure out dimensions from inputs
      len = Math::sqrt(floor_area)
      a = len * aspect_ratio
      b = len / aspect_ratio
      # Set perimeter depth to min of 1/3 smallest section width or 4.57 (=BTAP default)
      perimeter_depth = [([a, b].min / 9.0), 4.57].min
      # Generate the geometry
      BTAP::Geometry::Wizards::create_shape_rectangle(model,
                                                      length = a,
                                                      width = b,
                                                      above_ground_storys = above_grade_floors,
                                                      under_ground_storys = 0,
                                                      floor_to_floor_height = floor_to_floor_height,
                                                      plenum_height = plenum_height,
                                                      perimeter_zone_depth = perimeter_depth,
                                                      initial_height = 0.0)

      #" ******************* Creating L-Shape ***********************************"
    elsif building_shape == 'L-Shape'
      # Figure out dimensions from inputs
      len = Math::sqrt((9.0 / 5.0) * floor_area)
      a = len * aspect_ratio
      b = len / aspect_ratio
      # Set perimeter depth to min of 1/3 smallest section width or 4.57 (=BTAP default)
      perimeter_depth = [([a, b].min / 9.0), 4.57].min
      # Generate the geometry
      BTAP::Geometry::Wizards::create_shape_l(model,
                                              length = a,
                                              width = b,
                                              lower_end_width = b / 3.0,
                                              upper_end_length = a / 3.0,
                                              num_floors = above_grade_floors,
                                              floor_to_floor_height = floor_to_floor_height,
                                              plenum_height = plenum_height,
                                              perimeter_zone_depth = perimeter_depth)

      #" ******************* Creating H-Shape Shape ***********************************"
    elsif building_shape == 'H-Shape'
      # Figure out dimensions from inputs
      len = Math::sqrt((9.0 / 7.0) * floor_area)
      a = len * aspect_ratio
      b = len / aspect_ratio
      # Set perimeter depth to min of 1/3 smallest section width or 4.57 (=BTAP default)
      perimeter_depth = [([a, b].min / 9.0), 4.57].min
      # Generate the geometry
      # runner.registerInfo ("center_width = b/4 : #{b/4} , left_width = b/3 : #{b/3} , left_upper_end_offset = a/15: #{a/15} ")
      BTAP::Geometry::Wizards::create_shape_h(model,
                                              len = Math::sqrt((9.0 / 7.0) * floor_area),
                                              left_width = b,
                                              center_width = b / 3.0,
                                              right_width = b,
                                              left_end_length = a / 3.0,
                                              right_end_length = a / 3.0,
                                              left_upper_end_offset = b / 3.0,
                                              right_upper_end_offset = b / 3.0,
                                              num_floors = above_grade_floors,
                                              floor_to_floor_height = floor_to_floor_height,
                                              plenum_height = plenum_height,
                                              perimeter_zone_depth = 2.67)

      #" ******************* Creating T-Shape Shape ***********************************"
    elsif building_shape == 'T-Shape'
      # Figure out dimensions from inputs
      len = Math::sqrt((9.0 / 5.0) * floor_area)
      a = len * aspect_ratio
      b = len / aspect_ratio
      # Set perimeter depth to min of 1/3 smallest section width or 4.57 (=BTAP default)
      perimeter_depth = [([a, b].min / 9), 4.57].min
      # Generate the geometry

      BTAP::Geometry::Wizards::create_shape_t(model,
                                              length = a,
                                              width = b,
                                              upper_end_width = b / 3.0,
                                              lower_end_length = a / 3.0,
                                              left_end_offset = b / 3.0,
                                              num_floors = above_grade_floors,
                                              floor_to_floor_height = floor_to_floor_height,
                                              plenum_height = plenum_height,
                                              perimeter_zone_depth = perimeter_depth)

      #" ******************* Creating U-Shape Shape ***********************************"
    elsif building_shape == 'U-Shape'
      # Figure out dimensions from inputs
      len = Math::sqrt((9.0 / 7.0) * floor_area)
      a = len * aspect_ratio
      b = len / aspect_ratio
      # Set perimeter depth to min of 1/3 smallest section width or 4.57 (=BTAP default)
      perimeter_depth = [([a, b].min / 9), 4.57].min

      BTAP::Geometry::Wizards::create_shape_u(model,
                                              length = a,
                                              left_width = b,
                                              right_width = b,
                                              left_end_length = a / 3.0,
                                              right_end_length = a / 3.0,
                                              left_end_offset = b * 2.0 / 3.0,
                                              num_floors = above_grade_floors,
                                              floor_to_floor_height = floor_to_floor_height,
                                              plenum_height = plenum_height,
                                              perimeter_zone_depth = perimeter_depth / 3.0)
    end

    #Rotate model.
    building = model.getBuilding
    runner.registerInitialCondition("The building's initial rotation was #{building.northAxis} degrees.".light_blue)
    final_rotation = building.northAxis + rotation
    building.setNorthAxis(final_rotation)
    runner.registerInfo("The building has been rotated by #{building.northAxis} degrees.")
    # Geometry is now complete. Need to add space types and then run through prototype creation methods.
    # Define version of NECB to use
    standard = Standard.build(template)

    # Need to set building level info
    building = model.getBuilding
    building_name = ("#{building_type}_#{building_shape}_#{template}")
    building.setName(building_name)
    building.setStandardsBuildingType("#{building_type}")
    building.setStandardsNumberOfStories(above_grade_floors)
    building.setStandardsNumberOfAboveGroundStories(above_grade_floors)

    # Set design days
    OpenStudio::Model::DesignDay.new(model)
    building_type1 = building_type
    # Map building type to a building space usage in NECB
    if building_type == 'SmallOffice' || building_type == 'MediumOffice' || building_type == 'LargeOffice'
      building_type = "Office"
    elsif building_type == "PrimarySchool" || building_type == "SecondarySchool"
      building_type = "School/university"
    elsif building_type == "SmallHotel" || building_type == "LargeHotel"
      if template == 'NECB2011'
        building_type = "Hotel"
      else
        building_type = "Hotel/Motel"
      end
    elsif building_type == "RetailStandalone" || building_type == "RetailStripmall"
      building_type = "Retail"
    elsif building_type == "QuickServiceRestaurant" || building_type == "FullServiceRestaurant"
      if template == 'NECB2011'
        building_type = "Dining - cafeteria"
      else
        building_type = "Dining - cafeteria/fast food"
      end
    elsif building_type == "MidriseApartment" || building_type == "HighriseApartment"
      if template == 'NECB2011'
        building_type = "Multi-unit residential"
      else
        building_type = "Multi-unit residential building"
      end
    elsif building_type == "Outpatient"
      building_type = "Health-care clinic"
    end

    # Get the space Type data from standards data
    space_type = OpenStudio::Model::SpaceType.new(model)
    space_type.setName("#{building_type} WholeBuilding")
    space_type.setStandardsSpaceType("WholeBuilding")
    space_type.setStandardsBuildingType("#{building_type}")
    building.setSpaceType(space_type)

    # Add internal loads
    standard.space_type_apply_internal_loads(space_type: space_type)

    # Schedules
    standard.space_type_apply_internal_load_schedules(space_type,
                                                      true,
                                                      true,
                                                      true,
                                                      true,
                                                      true,
                                                      true,
                                                      true)

    # Create thermal zones (these will get overwritten in the apply_standard method)
    standard.model_create_thermal_zones(model)

    # Set the start day
    model.setDayofWeekforStartDay("Sunday")

    # Apply standards ruleset to model (note this does a sizing run)
    standard.model_apply_standard(model: model,
                                  epw_file: epw_file,
                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

    finishing_spaceTypes = model.getSpaceTypes
    num_thermalZones = model.getThermalZones.size
    finishing_constructionSets = model.getDefaultConstructionSets
    runner.registerInfo("The building finished with #{finishing_spaceTypes.size} space type.")

    # Map building type to a building evel space usage in NECB
    if building_type == "School/university"
      building_type = "School"
    elsif building_type == "Hotel/Motel"
      building_type = "Hotel"
    elsif building_type == "Dining - cafeteria/fast food"
      building_type = "Dining - cafeteria"
    end

    return true
  end
end

# register the measure to be used by the application
NrcCreateGeometry.new.registerWithApplication
