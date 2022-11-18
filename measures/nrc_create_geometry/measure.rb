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
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "Calgary",
        "choices" => ["Calgary", "Edmonton", "Fort.McMurray", "Kelowna", "Vancouver", "Victoria", "Thompson", "Winnipeg-Richardson", "Moncton-Greater", "Saint.John", "Corner.Brook", "St.Johns", "Halifax", "Sydney-McCurdy", "Inuvik-Zubko", "Yellowknife", "Cambridge.Bay", "Iqaluit", "Rankin.Inlet", "Ottawa-Macdonald-Cartier", "Sudbury", "Toronto.Pearson", "Charlottetown", "Jonquiere", "Montreal-Trudeau", "Quebec-Lesage", "Regina", "Saskatoon", "Dawson", "Whitehorse", "Prince.Albert", "Windsor"],
        "is_required" => true
      },
      {
        "name" => "weather_file_type",
        "type" => "Choice",
        "display_name" => "Weather Type",
        "default_value" => "ECY",
        "choices" => ["ECY", "EWY", "TDY", "TMY", "CWEC2016"],
        "is_required" => true
      },
      {
        "name" => "global_warming",
        "type" => "Choice",
        "display_name" => "Global Warming",
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

    epw_files = ["CAN_AB_Calgary.Intl.AP.718770_ECY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_ECY-3.0.epw", "CAN_AB_Calgary.Intl.AP.718770_EWY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_EWY-3.0.epw",
                 "CAN_AB_Calgary.Intl.AP.718770_TDY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_TDY-3.0.epw", "CAN_AB_Calgary.Intl.AP.718770_TMY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_TMY-3.0.epw",
                 "CAN_AB_Edmonton.Intl.AP.711230_ECY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_ECY-3.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_EWY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_EWY-3.0.epw",
                 "CAN_AB_Edmonton.Intl.AP.711230_TDY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_TDY-3.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_TMY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_TMY-3.0.epw",
                 "CAN_AB_Fort.McMurray.AP.716890_ECY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_ECY-3.0.epw", "CAN_AB_Fort.McMurray.AP.716890_EWY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_EWY-3.0.epw",
                 "CAN_AB_Fort.McMurray.AP.716890_TDY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_TDY-3.0.epw", "CAN_AB_Fort.McMurray.AP.716890_TMY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_TMY-3.0.epw",
                 "CAN_BC_Kelowna.Intl.AP.712030_ECY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_ECY-3.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_EWY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_EWY-3.0.epw",
                 "CAN_BC_Kelowna.Intl.AP.712030_TDY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_TDY-3.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_TMY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_TMY-3.0.epw",
                 "CAN_BC_Vancouver.Intl.AP.718920_ECY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_ECY-3.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_EWY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_EWY-3.0.epw",
                 "CAN_BC_Vancouver.Intl.AP.718920_TDY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_TDY-3.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_TMY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_TMY-3.0.epw",
                 "CAN_BC_Victoria.Intl.AP.717990_ECY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_ECY-3.0.epw", "CAN_BC_Victoria.Intl.AP.717990_EWY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_EWY-3.0.epw",
                 "CAN_BC_Victoria.Intl.AP.717990_TDY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_TDY-3.0.epw", "CAN_BC_Victoria.Intl.AP.717990_TMY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_TMY-3.0.epw",
                 "CAN_MB_Thompson.AP.710790_ECY-0.0.epw", "CAN_MB_Thompson.AP.710790_ECY-3.0.epw", "CAN_MB_Thompson.AP.710790_EWY-0.0.epw", "CAN_MB_Thompson.AP.710790_EWY-3.0.epw",
                 "CAN_MB_Thompson.AP.710790_TDY-0.0.epw", "CAN_MB_Thompson.AP.710790_TDY-3.0.epw", "CAN_MB_Thompson.AP.710790_TMY-0.0.epw", "CAN_MB_Thompson.AP.710790_TMY-3.0.epw",
                 "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_ECY-0.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_ECY-3.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_EWY-0.0.epw",
                 "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_EWY-3.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TDY-0.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TDY-3.0.epw",
                 "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TMY-0.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TMY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_ECY-0.0.epw",
                 "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_ECY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_EWY-0.0.epw",
                 "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_EWY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TDY-0.0.epw",
                 "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TDY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TMY-0.0.epw",
                 "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TMY-3.0.epw", "CAN_NB_Saint.John.AP.716090_ECY-0.0.epw", "CAN_NB_Saint.John.AP.716090_ECY-3.0.epw",
                 "CAN_NB_Saint.John.AP.716090_EWY-0.0.epw", "CAN_NB_Saint.John.AP.716090_EWY-3.0.epw", "CAN_NB_Saint.John.AP.716090_TDY-0.0.epw", "CAN_NB_Saint.John.AP.716090_TDY-3.0.epw",
                 "CAN_NB_Saint.John.AP.716090_TMY-0.0.epw", "CAN_NB_Saint.John.AP.716090_TMY-3.0.epw", "CAN_NL_Corner.Brook.719730_ECY-0.0.epw", "CAN_NL_Corner.Brook.719730_ECY-3.0.epw",
                 "CAN_NL_Corner.Brook.719730_EWY-0.0.epw", "CAN_NL_Corner.Brook.719730_EWY-3.0.epw", "CAN_NL_Corner.Brook.719730_TDY-0.0.epw", "CAN_NL_Corner.Brook.719730_TDY-3.0.epw",
                 "CAN_NL_Corner.Brook.719730_TMY-0.0.epw", "CAN_NL_Corner.Brook.719730_TMY-3.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_ECY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_ECY-3.0.epw",
                 "CAN_NL_St.Johns.Intl.AP.718010_EWY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_EWY-3.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_TDY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_TDY-3.0.epw",
                 "CAN_NL_St.Johns.Intl.AP.718010_TMY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_TMY-3.0.epw", "CAN_NS_Halifax.Intl.AP.713950_ECY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_ECY-3.0.epw",
                 "CAN_NS_Halifax.Intl.AP.713950_EWY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_EWY-3.0.epw", "CAN_NS_Halifax.Intl.AP.713950_TDY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_TDY-3.0.epw",
                 "CAN_NS_Halifax.Intl.AP.713950_TMY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_TMY-3.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_ECY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_ECY-3.0.epw",
                 "CAN_NS_Sydney-McCurdy.AP.717070_EWY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_EWY-3.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_TDY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_TDY-3.0.epw",
                 "CAN_NS_Sydney-McCurdy.AP.717070_TMY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_TMY-3.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_ECY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_ECY-3.0.epw",
                 "CAN_NT_Inuvik-Zubko.AP.719570_EWY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_EWY-3.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_TDY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_TDY-3.0.epw",
                 "CAN_NT_Inuvik-Zubko.AP.719570_TMY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_TMY-3.0.epw", "CAN_NT_Yellowknife.AP.719360_ECY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_ECY-3.0.epw",
                 "CAN_NT_Yellowknife.AP.719360_EWY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_EWY-3.0.epw", "CAN_NT_Yellowknife.AP.719360_TDY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_TDY-3.0.epw",
                 "CAN_NT_Yellowknife.AP.719360_TMY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_TMY-3.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_ECY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_ECY-3.0.epw",
                 "CAN_NU_Cambridge.Bay.AP.719250_EWY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_EWY-3.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_TDY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_TDY-3.0.epw",
                 "CAN_NU_Cambridge.Bay.AP.719250_TMY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_TMY-3.0.epw", "CAN_NU_Iqaluit.AP.719090_ECY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_ECY-3.0.epw",
                 "CAN_NU_Iqaluit.AP.719090_EWY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_EWY-3.0.epw", "CAN_NU_Iqaluit.AP.719090_TDY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_TDY-3.0.epw",
                 "CAN_NU_Iqaluit.AP.719090_TMY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_TMY-3.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_ECY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_ECY-3.0.epw",
                 "CAN_NU_Rankin.Inlet.AP.710830_EWY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_EWY-3.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_TDY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_TDY-3.0.epw",
                 "CAN_NU_Rankin.Inlet.AP.710830_TMY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_TMY-3.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_ECY-0.0.epw",
                 "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_ECY-3.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_EWY-0.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_EWY-3.0.epw",
                 "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TDY-0.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TDY-3.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TMY-0.0.epw",
                 "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TMY-3.0.epw", "CAN_ON_Sudbury.AP.717300_ECY-0.0.epw", "CAN_ON_Sudbury.AP.717300_ECY-3.0.epw", "CAN_ON_Sudbury.AP.717300_EWY-0.0.epw",
                 "CAN_ON_Sudbury.AP.717300_EWY-3.0.epw", "CAN_ON_Sudbury.AP.717300_TDY-0.0.epw", "CAN_ON_Sudbury.AP.717300_TDY-3.0.epw", "CAN_ON_Sudbury.AP.717300_TMY-0.0.epw",
                 "CAN_ON_Sudbury.AP.717300_TMY-3.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_ECY-0.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_ECY-3.0.epw",
                 "CAN_ON_Toronto.Pearson.Intl.AP.716240_EWY-0.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_EWY-3.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_TDY-0.0.epw",
                 "CAN_ON_Toronto.Pearson.Intl.AP.716240_TDY-3.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_TMY-0.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_TMY-3.0.epw",
                 "CAN_PE_Charlottetown.AP.717060_ECY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_ECY-3.0.epw", "CAN_PE_Charlottetown.AP.717060_EWY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_EWY-3.0.epw",
                 "CAN_PE_Charlottetown.AP.717060_TDY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_TDY-3.0.epw", "CAN_PE_Charlottetown.AP.717060_TMY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_TMY-3.0.epw",
                 "CAN_QC_Jonquiere.716170_ECY-0.0.epw", "CAN_QC_Jonquiere.716170_ECY-3.0.epw", "CAN_QC_Jonquiere.716170_EWY-0.0.epw", "CAN_QC_Jonquiere.716170_EWY-3.0.epw",
                 "CAN_QC_Jonquiere.716170_TDY-0.0.epw", "CAN_QC_Jonquiere.716170_TDY-3.0.epw", "CAN_QC_Jonquiere.716170_TMY-0.0.epw", "CAN_QC_Jonquiere.716170_TMY-3.0.epw",
                 "CAN_QC_Montreal-Trudeau.Intl.AP.716270_ECY-0.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_ECY-3.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_EWY-0.0.epw",
                 "CAN_QC_Montreal-Trudeau.Intl.AP.716270_EWY-3.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TDY-0.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TDY-3.0.epw",
                 "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TMY-0.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TMY-3.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_ECY-0.0.epw",
                 "CAN_QC_Quebec-Lesage.Intl.AP.717140_ECY-3.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_EWY-0.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_EWY-3.0.epw",
                 "CAN_QC_Quebec-Lesage.Intl.AP.717140_TDY-0.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_TDY-3.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_TMY-0.0.epw",
                 "CAN_QC_Quebec-Lesage.Intl.AP.717140_TMY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_ECY-0.0.epw", "CAN_SK_Regina.Intl.AP.715140_ECY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_EWY-0.0.epw",
                 "CAN_SK_Regina.Intl.AP.715140_EWY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_TDY-0.0.epw", "CAN_SK_Regina.Intl.AP.715140_TDY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_TMY-0.0.epw",
                 "CAN_SK_Regina.Intl.AP.715140_TMY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_ECY-0.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_ECY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_EWY-0.0.epw",
                 "CAN_SK_Saskatoon.Intl.AP.718660_EWY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_TDY-0.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_TDY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_TMY-0.0.epw",
                 "CAN_SK_Saskatoon.Intl.AP.718660_TMY-3.0.epw", "CAN_YT_Dawson.719660_ECY-0.0.epw", "CAN_YT_Dawson.719660_ECY-3.0.epw", "CAN_YT_Dawson.719660_EWY-0.0.epw",
                 "CAN_YT_Dawson.719660_EWY-3.0.epw", "CAN_YT_Dawson.719660_TDY-0.0.epw", "CAN_YT_Dawson.719660_TDY-3.0.epw", "CAN_YT_Dawson.719660_TMY-0.0.epw", "CAN_YT_Dawson.719660_TMY-3.0.epw",
                 "CAN_YT_Whitehorse.Intl.AP.719640_ECY-0.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_ECY-3.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_EWY-0.0.epw",
                 "CAN_YT_Whitehorse.Intl.AP.719640_EWY-3.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_TDY-0.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_TDY-3.0.epw",
                 "CAN_YT_Whitehorse.Intl.AP.719640_TMY-0.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_TMY-3.0.epw",
                 "CAN_AB_Calgary.Intl.AP.718770_CWEC2016.epw", "CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw", "CAN_AB_Fort.McMurray.AP.716890_CWEC2016.epw", "CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw",
                 "CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_CWEC2016.epw", "CAN_NB_Saint.John.AP.716090_CWEC2016.epw",
                 "CAN_NL_St.Johns.Intl.AP.718010_CWEC2016.epw", "CAN_NS_Halifax.Dockyard.713280_CWEC2016.epw", "CAN_NS_Sydney-McCurdy.AP.717070_CWEC2016.epw", "CAN_NT_Inuvik-Zubko.AP.719570_CWEC2016.epw",
                 "CAN_NT_Yellowknife.AP.719360_CWEC2016.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_CWEC2016.epw",
                 "CAN_PE_Charlottetown.AP.717060_CWEC2016.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_CWEC2016.epw",
                 "CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw", "CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw",
                 "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_16.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_17.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_18.epw",
                 "CAN_ON_Toronto.Pearson.Intl.AP.716240_16.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_17.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_18.epw",
                 "CAN_ON_Windsor.Intl.AP.715380_16.epw", "CAN_ON_Windsor.Intl.AP.715380_17.epw", "CAN_ON_Windsor.Intl.AP.715380_18.epw", "CAN_BC_Kelowna.Intl.AP.712030_CWEC2016.epw",
                 "CAN_MB_Thompson.AP.710790_CWEC2016.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_CWEC2016.epw",
                 "CAN_NL_Corner.Brook.719730_CWEC2016.epw", "CAN_NU_Cambridge.Bay.AP.719250_CWEC2016.epw", "CAN_NU_Iqaluit.AP.719090_CWEC2016.epw",
                 "CAN_NU_Rankin.Inlet.AP.710830_CWEC2016.epw", "CAN_ON_Sudbury.AP.717300_CWEC2016.epw", "CAN_QC_Jonquiere.716170_CWEC2016.epw",
                 "CAN_SK_Prince.Albert.AP.718690_CWEC2016.epw", "CAN_SK_Regina.Intl.AP.715140_CWEC2016.epw", "CAN_YT_Dawson.719660_CWEC2020.epw"]

    # assign the user inputs to variables
    building_shape = arguments['building_shape']
    building_type = arguments['building_type']
    template = arguments['template']
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
    sideload = arguments['sideload']

    epw_file = ""
    epw_files.each do |w_file|
      if (weather_file_type == "CWEC2016") && (w_file.include? "CWEC2016") && (w_file.include? location)
        epw_file = w_file
      elsif (weather_file_type == "CWEC2016") && (w_file.include? "Dawson")
        epw_file = "CAN_YT_Dawson.719660_CWEC2020.epw" # Only CWEC2020 is available for "CAN_YT_Dawson.719660"
      elsif (w_file.include? location) && (w_file.include? weather_file_type) && (w_file.include? global_warming)
        epw_file = w_file
      end
    end

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
    standard.model_apply_standard(model: model,
                                  epw_file: epw_file,
                                  sizing_run_dir: NRCMeasureTestHelper.outputFolder)

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
