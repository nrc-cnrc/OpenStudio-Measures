# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require 'openstudio-standards'
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcCreateGeometry < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)

  # Human readable name
  def name
    #BEFORE YOU DO anything.. please generate a new <uid>224561f4-8ccc-4f60-8118-34b85359d6f7</uid>
    return 'NrcCreateGeometry'
  end

  # human readable description
  def description
    description = 'Create standard building shapes and define spaces.'
    description << 'The total floor area, and number of floors are specified.'
    description << 'The building is assumed to be in thirds (thus for the courtyard the middle third is the void).'
    description << 'For weather file descriptions see https://climate.onebuilding.org/.'
    return description
  end

  # human readable description of modeling approach
  def modeler_description
    description = 'Defines the geometry of the building based on the given inputs.'
    description << 'Uses BTAP::Geometry::Wizards::create_shape_* methods.'
    return description
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

    # HVAC/water heating fuel choice.
    hvac_fuel_chs = OpenStudio::StringVector.new
    hvac_fuel_chs << 'DefaultFuel'
    hvac_fuel_chs << 'NaturalGas'
    hvac_fuel_chs << 'Electricity'
    hvac_fuel_chs << 'FuelOilNo2'

    # Choice vector of locations.
    location_choice = OpenStudio::StringVector.new
    location_choice << 'AB_Calgary'
    location_choice << 'AB_Edmonton'
    location_choice << 'AB_Fort.McMurray'
    location_choice << 'BC_Kelowna'
    location_choice << 'BC_Vancouver'
    location_choice << 'BC_Victoria'
    location_choice << 'MB_Thompson'
    location_choice << 'MB_Winnipeg'
    location_choice << 'NB_Moncton'
    location_choice << 'NB_Saint.John'
    location_choice << 'NL_Corner.Brook'
    location_choice << 'NL_St.Johns'
    location_choice << 'NS_Halifax.Dockyard'
    location_choice << 'NS_Sydney'
    location_choice << 'NT_Inuvik'
    location_choice << 'NT_Yellowknife'
    location_choice << 'NU_Cambridge.Bay'
    location_choice << 'NU_Iqaluit'
    location_choice << 'NU_Rankin.Inlet'
    location_choice << 'ON_Ottawa'
    location_choice << 'ON_Sudbury'
    location_choice << 'ON_Toronto'
    location_choice << 'ON_Windsor'
    location_choice << 'PE_Charlottetown'
    location_choice << 'QC_Jonquiere'
    location_choice << 'QC_Montreal'
    location_choice << 'QC_Quebec'
    location_choice << 'SK_Prince.Albert'
    location_choice << 'SK_Regina'
    location_choice << 'SK_Saskatoon'
    location_choice << 'YT_Dawson.City'
    location_choice << 'YT_Whitehorse'

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
        "name" => "necb_template",
        "type" => "Choice",
        "display_name" => "Building vintage",
        "default_value" => "NECB2020",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020", "BTAPPRE1980", "BTAP1980TO2010"],
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
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "AB_Calgary",
        "choices" => location_choice,
        "is_required" => true
      },
      {
        "name" => "weather_file_type",
        "type" => "Choice",
        "display_name" => "Weather file type",
        "default_value" => "CWEC2020",
        "choices" => ["CWEC2016", "CWEC2020", "TMY", "TRY-average", "TRY-warm", "TRY-cold"],
        "is_required" => true
      },
      {
        "name" => "global_warming",
        "type" => "Choice",
        "display_name" => "Degree of global warming (for TMY/TRY options)",
        "default_value" => "0.0",
        "choices" => ["0.0", "3.0"],
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
        "display_name" => "Plenum height (m), or Enter '0.0' for No Plenum",
        "default_value" => 0.0,
        "max_double_value" => 2.0,
        "is_required" => false
      },
      {
        "name" => "hvac_fuel",
        "type" => "Choice",
        "display_name" => "HVAC/Water heating fuel",
        "default_value" => "DefaultFuel",
        "choices" => hvac_fuel_chs,
        "is_required" => true
      },
      {
        "name" => "sideload",
        "type" => "Bool",
        "display_name" => "Check for sideload files (to overwrite standards info)?",
        "default_value" => false,
        "is_required" => true
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    #Runs parent run method.
    super(model, runner, user_arguments)

    @runner = runner
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # assign the user inputs to variables
    building_shape = arguments['building_shape']
    building_type = arguments['building_type']
    template = arguments['necb_template']
    location = arguments['location']
    weather_file_type = arguments['weather_file_type']
    global_warming = arguments['global_warming']
    total_floor_area = arguments['total_floor_area']
    aspect_ratio = arguments['aspect_ratio']
    rotation = arguments['rotation']
    above_grade_floors = arguments['above_grade_floors']
    floor_to_floor_height = arguments['floor_to_floor_height']
    plenum_height = arguments['plenum_height']
    floor_area = total_floor_area / above_grade_floors
    climate_zone = 'NECB HDD Method'
    primary_heating_fuel = arguments['hvac_fuel']
    sideload = arguments['sideload']

    # Map arguments to an epw filename.
    epw_file = "CAN_#{location}"
    case weather_file_type
    when "CWEC2016"
      epw_file << "-CWEC2016"
    when "CWEC2020"
      epw_file << "-CWEC2020"
    when "TMY"
      epw_file << "-TMY"
    when "TRY-average"
      epw_file << "-TRY_AvgTemp"
    when "TRY-warm"
      epw_file << "-TRY_MaxTemp"
    when "TRY-cold"
      epw_file << "-TRY_MinTemp"
    end

    if ["TMY", "TRY"].any? {|txt| weather_file_type.include? txt} then
      case global_warming
      when "0.0"
        epw_file << "_GW0.0"
      when "3.0"
        epw_file << "_GW3.0"
      end
    end
    epw_file << ".epw"

    if plenum_height <= 0
      plenum_height = 0.0
    end

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
                                                      under_ground_storys = 0, # Set to 1, when modeling a basement
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
                                              length = a,
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
                                              perimeter_zone_depth = perimeter_depth)

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

	# To solve the error of vertex mismatch in T-Shape buildings of more than 1 story.
    model.getPlanarSurfaces.each do |surface|
      surface.setVertices(OpenStudio::removeCollinear(surface.vertices))
    end 
	
    #Rotate model.
    building = model.getBuilding

    runner.registerInitialCondition("The building's initial rotation was #{building.northAxis} degrees.".light_blue)
    final_rotation = building.northAxis + rotation
    building.setNorthAxis(final_rotation)
    runner.registerInfo("The building has been rotated by #{building.northAxis} degrees.")

    # Define version of NECB to use
    standard = Standard.build(template)

    # Compare skylight to roof ratio before and after running the 'json_sideload' method
    srr_lim = standard.get_standards_constant('skylight_to_roof_ratio_max_value')
    runner.registerInitialCondition("The building's SRR was".green + " #{srr_lim}.".light_blue)

    # Side load json files into standard.
    if sideload then
      standard = json_sideload(standard)
    end

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
    sizing_folder = NRCMeasureTestHelper.outputFolder(arguments)
    puts "sizing run folder: #{sizing_folder}".yellow
    standard.model_apply_standard(model: model,
                                  epw_file: epw_file,
                                  primary_heating_fuel: primary_heating_fuel,
                                  sizing_run_dir: sizing_folder)

    facility = model.getFacility
    exterior_lights = facility.exteriorLights
    exterior_lights.each do |exterior_light|
      puts "Removed exterior light : #{exterior_light.name}.".green
      exterior_light.remove
    end

    # Check if new SRR was set properly
    srr_lim = standard.get_standards_constant('skylight_to_roof_ratio_max_value')
    runner.registerFinalCondition("The building's SRR is changed to ".green + " #{srr_lim}.".light_blue)

    finishing_spaceTypes = model.getSpaceTypes
    num_thermalZones = model.getThermalZones.size
    finishing_constructionSets = model.getDefaultConstructionSets
    runner.registerInfo("The building finished with #{finishing_spaceTypes.size} space type.")

    # Map building type to a building level space usage in NECB
    if building_type == "School/university"
      building_type = "School"
    elsif building_type == "Hotel/Motel"
      building_type = "Hotel"
    elsif building_type == "Dining - cafeteria/fast food"
      building_type = "Dining - cafeteria"
    end
    return true
  end

  # Check for sideload files and update standards tables etc.
  def json_sideload(standard)
    path = "#{File.dirname(__FILE__)}/resources/data_sideload"
    raise ("Could not find data_sideload folder".red) unless Dir.exist?(path)
    files = Dir.glob("#{path}/*.json").select { |e| File.file? e }
    files.each do |file|
      @runner.registerInfo("Reading side load file: ".green + "#{file}".light_blue)
      data = JSON.parse(File.read(file))
      if not data["tables"].nil?
        data['tables'].keys.each do |table|
          @runner.registerInfo("Updating standard table: ".green + " #{table}".light_blue)
          @runner.registerInfo("Existing data: ".green + " #{standard.standards_data[table]}".light_blue)
          @runner.registerInfo("Replacement data: ".green + " #{data['tables'][table]}".light_blue)
        end
        standard.standards_data["tables"] = [*standard.standards_data["tables"], *data["tables"]].to_h
        standard.corrupt_standards_database
        data['tables'].keys.each do |table|
          @runner.registerInfo("Table: ".green + " #{table}".light_blue)
          @runner.registerInfo("Updated data: ".green + " #{standard.standards_data[table]}".light_blue)
        end
      elsif not data["formulas"].nil?
        data['formulas'].keys.each do |formula|
          @runner.registerInfo("Updating standard formula: ".green + " #{formula}".light_blue)
          @runner.registerInfo("Existing data   : ".green + " #{standard.get_standards_formula(formula)}".light_blue)
          @runner.registerInfo("Replacement data: ".green + " #{data['formulas'][formula]['value']}".light_blue)
        end
        standard.standards_data["formulas"] = [*standard.standards_data["formulas"], *data["formulas"]].to_h
        standard.corrupt_standards_database
        data['formulas'].keys.each do |formula|
          @runner.registerInfo("Formula: ".green + " #{formula}".light_blue)
          @runner.registerInfo("Updated data    : ".green + " #{standard.get_standards_formula(formula)}".light_blue)
        end
      elsif not data["constants"].nil?
        data['constants'].keys.each do |value|
          @runner.registerInfo("Updating standard constants value: ".green + "#{value}".light_blue)
          @runner.registerInfo("Existing constants data   : ".green + "#{standard.get_standards_constant(value)}".light_blue)
          @runner.registerInfo("Replacement constants data: ".green + "#{data['constants'][value]['value']}".light_blue)
        end
        standard.standards_data["constants"] = [*standard.standards_data["constants"], *data["constants"]].to_h
        standard.corrupt_standards_database
        data['constants'].keys.each do |value|
          @runner.registerInfo("Constants value: ".green + "#{value}".light_blue)
          @runner.registerInfo("Updated constants data  :".green + " #{standard.get_standards_constant(value)}".light_blue)
        end
      else
        #standard.standards_data[data.keys.first] = data[data.keys.first]
      end
      @runner.registerWarning("Replaced default standard data with contents in #{file}".yellow)
    end
    return standard
  end
end

# register the measure to be used by the application
NrcCreateGeometry.new.registerWithApplication
