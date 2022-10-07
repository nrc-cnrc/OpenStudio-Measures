# Start the measure
require 'openstudio-standards'
require_relative 'resources/NRCMeasureHelper'

class NrcCreateNECBPrototypeBuilding < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  # Define the name of the Measure.
  def name
    return 'NrcCreateNECBPrototypeBuilding'
  end

  # Human readable description
  def description
    return 'This measure creates an NECB prototype building from scratch and uses it as the base for an analysis.'
  end

  # Human readable description of modeling approach
  def modeler_description
    return 'This will replace the model object with a brand new model. It effectively ignores the seed model. If there are 
	updated tables/formulas to those in the standard they can be sideloaded into the standard definition - this new data will
	then be used to create the model.'
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

    # Make an argument for the building type
    building_type_chs = OpenStudio::StringVector.new
    building_type_chs << 'SecondarySchool'
    building_type_chs << 'PrimarySchool'
    building_type_chs << 'SmallOffice'
    building_type_chs << 'MediumOffice'
    building_type_chs << 'LargeOffice'
    building_type_chs << 'SmallHotel'
    building_type_chs << 'LargeHotel'
    building_type_chs << 'Warehouse'
    building_type_chs << 'RetailStandalone'
    building_type_chs << 'RetailStripmall'
    building_type_chs << 'QuickServiceRestaurant'
    building_type_chs << 'FullServiceRestaurant'
    building_type_chs << 'MidriseApartment'
    building_type_chs << 'HighriseApartment'
    building_type_chs << 'Hospital'
    building_type_chs << 'Outpatient'

    epw_files= ["AB_Calgary_ECY-0.0", "AB_Calgary_ECY-3.0", "AB_Calgary_EWY-0.0", "AB_Calgary_EWY-3.0", "AB_Calgary_TDY-0.0", "AB_Calgary_TDY-3.0", "AB_Calgary_TMY-0.0", "AB_Calgary_TMY-3.0", "AB_Edmonton_ECY-0.0", "AB_Edmonton_ECY-3.0", "AB_Edmonton_EWY-0.0", "AB_Edmonton_EWY-3.0", "AB_Edmonton_TDY-0.0", "AB_Edmonton_TDY-3.0", "AB_Edmonton_TMY-0.0", "AB_Edmonton_TMY-3.0", "AB_Fort_ECY-0.0", "AB_Fort_ECY-3.0", "AB_Fort_EWY-0.0", "AB_Fort_EWY-3.0", "AB_Fort_TDY-0.0", "AB_Fort_TDY-3.0", "AB_Fort_TMY-0.0", "AB_Fort_TMY-3.0", "BC_Kelowna_ECY-0.0", "BC_Kelowna_ECY-3.0", "BC_Kelowna_EWY-0.0", "BC_Kelowna_EWY-3.0", "BC_Kelowna_TDY-0.0", "BC_Kelowna_TDY-3.0", "BC_Kelowna_TMY-0.0", "BC_Kelowna_TMY-3.0", "BC_Vancouver_ECY-0.0", "BC_Vancouver_ECY-3.0", "BC_Vancouver_EWY-0.0", "BC_Vancouver_EWY-3.0", "BC_Vancouver_TDY-0.0", "BC_Vancouver_TDY-3.0", "BC_Vancouver_TMY-0.0", "BC_Vancouver_TMY-3.0", "BC_Victoria_ECY-0.0", "BC_Victoria_ECY-3.0", "BC_Victoria_EWY-0.0", "BC_Victoria_EWY-3.0", "BC_Victoria_TDY-0.0", "BC_Victoria_TDY-3.0", "BC_Victoria_TMY-0.0", "BC_Victoria_TMY-3.0", "MB_Thompson_ECY-0.0", "MB_Thompson_ECY-3.0", "MB_Thompson_EWY-0.0", "MB_Thompson_EWY-3.0", "MB_Thompson_TDY-0.0", "MB_Thompson_TDY-3.0", "MB_Thompson_TMY-0.0", "MB_Thompson_TMY-3.0", "MB_Winnipeg-Richardson_ECY-0.0", "MB_Winnipeg-Richardson_ECY-3.0", "MB_Winnipeg-Richardson_EWY-0.0", "MB_Winnipeg-Richardson_EWY-3.0", "MB_Winnipeg-Richardson_TDY-0.0", "MB_Winnipeg-Richardson_TDY-3.0", "MB_Winnipeg-Richardson_TMY-0.0", "MB_Winnipeg-Richardson_TMY-3.0", "NB_Moncton-Greater_ECY-0.0", "NB_Moncton-Greater_ECY-3.0", "NB_Moncton-Greater_EWY-0.0", "NB_Moncton-Greater_EWY-3.0", "NB_Moncton-Greater_TDY-0.0", "NB_Moncton-Greater_TDY-3.0", "NB_Moncton-Greater_TMY-0.0", "NB_Moncton-Greater_TMY-3.0", "NB_Saint_ECY-0.0", "NB_Saint_ECY-3.0", "NB_Saint_EWY-0.0", "NB_Saint_EWY-3.0", "NB_Saint_TDY-0.0", "NB_Saint_TDY-3.0", "NB_Saint_TMY-0.0", "NB_Saint_TMY-3.0", "NL_Corner_ECY-0.0", "NL_Corner_ECY-3.0", "NL_Corner_EWY-0.0", "NL_Corner_EWY-3.0", "NL_Corner_TDY-0.0", "NL_Corner_TDY-3.0", "NL_Corner_TMY-0.0", "NL_Corner_TMY-3.0", "NL_St_ECY-0.0", "NL_St_ECY-3.0", "NL_St_EWY-0.0", "NL_St_EWY-3.0", "NL_St_TDY-0.0", "NL_St_TDY-3.0", "NL_St_TMY-0.0", "NL_St_TMY-3.0", "NS_Halifax_ECY-0.0", "NS_Halifax_ECY-3.0", "NS_Halifax_EWY-0.0", "NS_Halifax_EWY-3.0", "NS_Halifax_TDY-0.0", "NS_Halifax_TDY-3.0", "NS_Halifax_TMY-0.0", "NS_Halifax_TMY-3.0", "NS_Sydney-McCurdy_ECY-0.0", "NS_Sydney-McCurdy_ECY-3.0", "NS_Sydney-McCurdy_EWY-0.0", "NS_Sydney-McCurdy_EWY-3.0", "NS_Sydney-McCurdy_TDY-0.0", "NS_Sydney-McCurdy_TDY-3.0", "NS_Sydney-McCurdy_TMY-0.0", "NS_Sydney-McCurdy_TMY-3.0", "NT_Inuvik-Zubko_ECY-0.0", "NT_Inuvik-Zubko_ECY-3.0", "NT_Inuvik-Zubko_EWY-0.0", "NT_Inuvik-Zubko_EWY-3.0", "NT_Inuvik-Zubko_TDY-0.0", "NT_Inuvik-Zubko_TDY-3.0", "NT_Inuvik-Zubko_TMY-0.0", "NT_Inuvik-Zubko_TMY-3.0", "NT_Yellowknife_ECY-0.0", "NT_Yellowknife_ECY-3.0", "NT_Yellowknife_EWY-0.0", "NT_Yellowknife_EWY-3.0", "NT_Yellowknife_TDY-0.0", "NT_Yellowknife_TDY-3.0", "NT_Yellowknife_TMY-0.0", "NT_Yellowknife_TMY-3.0", "NU_Cambridge_ECY-0.0", "NU_Cambridge_ECY-3.0", "NU_Cambridge_EWY-0.0", "NU_Cambridge_EWY-3.0", "NU_Cambridge_TDY-0.0", "NU_Cambridge_TDY-3.0", "NU_Cambridge_TMY-0.0", "NU_Cambridge_TMY-3.0", "NU_Iqaluit_ECY-0.0", "NU_Iqaluit_ECY-3.0", "NU_Iqaluit_EWY-0.0", "NU_Iqaluit_EWY-3.0", "NU_Iqaluit_TDY-0.0", "NU_Iqaluit_TDY-3.0", "NU_Iqaluit_TMY-0.0", "NU_Iqaluit_TMY-3.0", "NU_Rankin_ECY-0.0", "NU_Rankin_ECY-3.0", "NU_Rankin_EWY-0.0", "NU_Rankin_EWY-3.0", "NU_Rankin_TDY-0.0", "NU_Rankin_TDY-3.0", "NU_Rankin_TMY-0.0", "NU_Rankin_TMY-3.0", "ON_Ottawa-Macdonald-Cartier_ECY-0.0", "ON_Ottawa-Macdonald-Cartier_ECY-3.0", "ON_Ottawa-Macdonald-Cartier_EWY-0.0", "ON_Ottawa-Macdonald-Cartier_EWY-3.0", "ON_Ottawa-Macdonald-Cartier_TDY-0.0", "ON_Ottawa-Macdonald-Cartier_TDY-3.0", "ON_Ottawa-Macdonald-Cartier_TMY-0.0", "ON_Ottawa-Macdonald-Cartier_TMY-3.0", "ON_Sudbury_ECY-0.0", "ON_Sudbury_ECY-3.0", "ON_Sudbury_EWY-0.0", "ON_Sudbury_EWY-3.0", "ON_Sudbury_TDY-0.0", "ON_Sudbury_TDY-3.0", "ON_Sudbury_TMY-0.0", "ON_Sudbury_TMY-3.0", "ON_Toronto_ECY-0.0", "ON_Toronto_ECY-3.0", "ON_Toronto_EWY-0.0", "ON_Toronto_EWY-3.0", "ON_Toronto_TDY-0.0", "ON_Toronto_TDY-3.0", "ON_Toronto_TMY-0.0", "ON_Toronto_TMY-3.0", "PE_Charlottetown_ECY-0.0", "PE_Charlottetown_ECY-3.0", "PE_Charlottetown_EWY-0.0", "PE_Charlottetown_EWY-3.0", "PE_Charlottetown_TDY-0.0", "PE_Charlottetown_TDY-3.0", "PE_Charlottetown_TMY-0.0", "PE_Charlottetown_TMY-3.0", "QC_Jonquiere_ECY-0.0", "QC_Jonquiere_ECY-3.0", "QC_Jonquiere_EWY-0.0", "QC_Jonquiere_EWY-3.0", "QC_Jonquiere_TDY-0.0", "QC_Jonquiere_TDY-3.0", "QC_Jonquiere_TMY-0.0", "QC_Jonquiere_TMY-3.0", "QC_Montreal-Trudeau_ECY-0.0", "QC_Montreal-Trudeau_ECY-3.0", "QC_Montreal-Trudeau_EWY-0.0", "QC_Montreal-Trudeau_EWY-3.0", "QC_Montreal-Trudeau_TDY-0.0", "QC_Montreal-Trudeau_TDY-3.0", "QC_Montreal-Trudeau_TMY-0.0", "QC_Montreal-Trudeau_TMY-3.0", "QC_Quebec-Lesage_ECY-0.0", "QC_Quebec-Lesage_ECY-3.0", "QC_Quebec-Lesage_EWY-0.0", "QC_Quebec-Lesage_EWY-3.0", "QC_Quebec-Lesage_TDY-0.0", "QC_Quebec-Lesage_TDY-3.0", "QC_Quebec-Lesage_TMY-0.0", "QC_Quebec-Lesage_TMY-3.0", "SK_Regina_ECY-0.0", "SK_Regina_ECY-3.0", "SK_Regina_EWY-0.0", "SK_Regina_EWY-3.0", "SK_Regina_TDY-0.0", "SK_Regina_TDY-3.0", "SK_Regina_TMY-0.0", "SK_Regina_TMY-3.0", "SK_Saskatoon_ECY-0.0", "SK_Saskatoon_ECY-3.0", "SK_Saskatoon_EWY-0.0", "SK_Saskatoon_EWY-3.0", "SK_Saskatoon_TDY-0.0", "SK_Saskatoon_TDY-3.0", "SK_Saskatoon_TMY-0.0", "SK_Saskatoon_TMY-3.0", "YT_Dawson_ECY-0.0", "YT_Dawson_ECY-3.0", "YT_Dawson_EWY-0.0", "YT_Dawson_EWY-3.0", "YT_Dawson_TDY-0.0", "YT_Dawson_TDY-3.0", "YT_Dawson_TMY-0.0", "YT_Dawson_TMY-3.0", "YT_Whitehorse_ECY-0.0", "YT_Whitehorse_ECY-3.0", "YT_Whitehorse_EWY-0.0", "YT_Whitehorse_EWY-3.0", "YT_Whitehorse_TDY-0.0", "YT_Whitehorse_TDY-3.0", "YT_Whitehorse_TMY-0.0", "YT_Whitehorse_TMY-3.0"]

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "template",
        "type" => "Choice",
        "display_name" => "Template",
        "default_value" => "NECB2017",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020"],
        "is_required" => true
      },
      {
        "name" => "building_type",
        "type" => "Choice",
        "display_name" => "Building Type",
        "default_value" => "Warehouse",
        "choices" => building_type_chs,
        "is_required" => true
      },
      {
        "name" => "epw_file",
        "type" => "Choice",
        "display_name" => "Climate File",
        "default_value" => "YT_Dawson_TDY-3.0",
        "choices" => epw_files,
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

  # Define what happens when the measure is run.
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)
    #puts JSON.pretty_generate(arguments)
    # return false if false == arguments
    w_files = {"AB_Calgary_ECY-0.0"=>"CAN_AB_Calgary.Intl.AP.718770_ECY-0.0.epw", "AB_Calgary_ECY-3.0"=>"CAN_AB_Calgary.Intl.AP.718770_ECY-3.0.epw", "AB_Calgary_EWY-0.0"=>"CAN_AB_Calgary.Intl.AP.718770_EWY-0.0.epw", "AB_Calgary_EWY-3.0"=>"CAN_AB_Calgary.Intl.AP.718770_EWY-3.0.epw", "AB_Calgary_TDY-0.0"=>"CAN_AB_Calgary.Intl.AP.718770_TDY-0.0.epw", "AB_Calgary_TDY-3.0"=>"CAN_AB_Calgary.Intl.AP.718770_TDY-3.0.epw", "AB_Calgary_TMY-0.0"=>"CAN_AB_Calgary.Intl.AP.718770_TMY-0.0.epw", "AB_Calgary_TMY-3.0"=>"CAN_AB_Calgary.Intl.AP.718770_TMY-3.0.epw", "AB_Edmonton_ECY-0.0"=>"CAN_AB_Edmonton.Intl.AP.711230_ECY-0.0.epw", "AB_Edmonton_ECY-3.0"=>"CAN_AB_Edmonton.Intl.AP.711230_ECY-3.0.epw", "AB_Edmonton_EWY-0.0"=>"CAN_AB_Edmonton.Intl.AP.711230_EWY-0.0.epw", "AB_Edmonton_EWY-3.0"=>"CAN_AB_Edmonton.Intl.AP.711230_EWY-3.0.epw", "AB_Edmonton_TDY-0.0"=>"CAN_AB_Edmonton.Intl.AP.711230_TDY-0.0.epw", "AB_Edmonton_TDY-3.0"=>"CAN_AB_Edmonton.Intl.AP.711230_TDY-3.0.epw", "AB_Edmonton_TMY-0.0"=>"CAN_AB_Edmonton.Intl.AP.711230_TMY-0.0.epw", "AB_Edmonton_TMY-3.0"=>"CAN_AB_Edmonton.Intl.AP.711230_TMY-3.0.epw", "AB_Fort_ECY-0.0"=>"CAN_AB_Fort.McMurray.AP.716890_ECY-0.0.epw", "AB_Fort_ECY-3.0"=>"CAN_AB_Fort.McMurray.AP.716890_ECY-3.0.epw", "AB_Fort_EWY-0.0"=>"CAN_AB_Fort.McMurray.AP.716890_EWY-0.0.epw", "AB_Fort_EWY-3.0"=>"CAN_AB_Fort.McMurray.AP.716890_EWY-3.0.epw", "AB_Fort_TDY-0.0"=>"CAN_AB_Fort.McMurray.AP.716890_TDY-0.0.epw", "AB_Fort_TDY-3.0"=>"CAN_AB_Fort.McMurray.AP.716890_TDY-3.0.epw", "AB_Fort_TMY-0.0"=>"CAN_AB_Fort.McMurray.AP.716890_TMY-0.0.epw", "AB_Fort_TMY-3.0"=>"CAN_AB_Fort.McMurray.AP.716890_TMY-3.0.epw", "BC_Kelowna_ECY-0.0"=>"CAN_BC_Kelowna.Intl.AP.712030_ECY-0.0.epw", "BC_Kelowna_ECY-3.0"=>"CAN_BC_Kelowna.Intl.AP.712030_ECY-3.0.epw", "BC_Kelowna_EWY-0.0"=>"CAN_BC_Kelowna.Intl.AP.712030_EWY-0.0.epw", "BC_Kelowna_EWY-3.0"=>"CAN_BC_Kelowna.Intl.AP.712030_EWY-3.0.epw", "BC_Kelowna_TDY-0.0"=>"CAN_BC_Kelowna.Intl.AP.712030_TDY-0.0.epw", "BC_Kelowna_TDY-3.0"=>"CAN_BC_Kelowna.Intl.AP.712030_TDY-3.0.epw", "BC_Kelowna_TMY-0.0"=>"CAN_BC_Kelowna.Intl.AP.712030_TMY-0.0.epw", "BC_Kelowna_TMY-3.0"=>"CAN_BC_Kelowna.Intl.AP.712030_TMY-3.0.epw", "BC_Vancouver_ECY-0.0"=>"CAN_BC_Vancouver.Intl.AP.718920_ECY-0.0.epw", "BC_Vancouver_ECY-3.0"=>"CAN_BC_Vancouver.Intl.AP.718920_ECY-3.0.epw", "BC_Vancouver_EWY-0.0"=>"CAN_BC_Vancouver.Intl.AP.718920_EWY-0.0.epw", "BC_Vancouver_EWY-3.0"=>"CAN_BC_Vancouver.Intl.AP.718920_EWY-3.0.epw", "BC_Vancouver_TDY-0.0"=>"CAN_BC_Vancouver.Intl.AP.718920_TDY-0.0.epw", "BC_Vancouver_TDY-3.0"=>"CAN_BC_Vancouver.Intl.AP.718920_TDY-3.0.epw", "BC_Vancouver_TMY-0.0"=>"CAN_BC_Vancouver.Intl.AP.718920_TMY-0.0.epw", "BC_Vancouver_TMY-3.0"=>"CAN_BC_Vancouver.Intl.AP.718920_TMY-3.0.epw", "BC_Victoria_ECY-0.0"=>"CAN_BC_Victoria.Intl.AP.717990_ECY-0.0.epw", "BC_Victoria_ECY-3.0"=>"CAN_BC_Victoria.Intl.AP.717990_ECY-3.0.epw", "BC_Victoria_EWY-0.0"=>"CAN_BC_Victoria.Intl.AP.717990_EWY-0.0.epw", "BC_Victoria_EWY-3.0"=>"CAN_BC_Victoria.Intl.AP.717990_EWY-3.0.epw", "BC_Victoria_TDY-0.0"=>"CAN_BC_Victoria.Intl.AP.717990_TDY-0.0.epw", "BC_Victoria_TDY-3.0"=>"CAN_BC_Victoria.Intl.AP.717990_TDY-3.0.epw", "BC_Victoria_TMY-0.0"=>"CAN_BC_Victoria.Intl.AP.717990_TMY-0.0.epw", "BC_Victoria_TMY-3.0"=>"CAN_BC_Victoria.Intl.AP.717990_TMY-3.0.epw", "MB_Thompson_ECY-0.0"=>"CAN_MB_Thompson.AP.710790_ECY-0.0.epw", "MB_Thompson_ECY-3.0"=>"CAN_MB_Thompson.AP.710790_ECY-3.0.epw", "MB_Thompson_EWY-0.0"=>"CAN_MB_Thompson.AP.710790_EWY-0.0.epw", "MB_Thompson_EWY-3.0"=>"CAN_MB_Thompson.AP.710790_EWY-3.0.epw", "MB_Thompson_TDY-0.0"=>"CAN_MB_Thompson.AP.710790_TDY-0.0.epw", "MB_Thompson_TDY-3.0"=>"CAN_MB_Thompson.AP.710790_TDY-3.0.epw", "MB_Thompson_TMY-0.0"=>"CAN_MB_Thompson.AP.710790_TMY-0.0.epw", "MB_Thompson_TMY-3.0"=>"CAN_MB_Thompson.AP.710790_TMY-3.0.epw", "MB_Winnipeg-Richardson_ECY-0.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_ECY-0.0.epw", "MB_Winnipeg-Richardson_ECY-3.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_ECY-3.0.epw", "MB_Winnipeg-Richardson_EWY-0.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_EWY-0.0.epw", "MB_Winnipeg-Richardson_EWY-3.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_EWY-3.0.epw", "MB_Winnipeg-Richardson_TDY-0.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TDY-0.0.epw", "MB_Winnipeg-Richardson_TDY-3.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TDY-3.0.epw", "MB_Winnipeg-Richardson_TMY-0.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TMY-0.0.epw", "MB_Winnipeg-Richardson_TMY-3.0"=>"CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TMY-3.0.epw", "NB_Moncton-Greater_ECY-0.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_ECY-0.0.epw", "NB_Moncton-Greater_ECY-3.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_ECY-3.0.epw", "NB_Moncton-Greater_EWY-0.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_EWY-0.0.epw", "NB_Moncton-Greater_EWY-3.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_EWY-3.0.epw", "NB_Moncton-Greater_TDY-0.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TDY-0.0.epw", "NB_Moncton-Greater_TDY-3.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TDY-3.0.epw", "NB_Moncton-Greater_TMY-0.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TMY-0.0.epw", "NB_Moncton-Greater_TMY-3.0"=>"CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TMY-3.0.epw", "NB_Saint_ECY-0.0"=>"CAN_NB_Saint.John.AP.716090_ECY-0.0.epw", "NB_Saint_ECY-3.0"=>"CAN_NB_Saint.John.AP.716090_ECY-3.0.epw", "NB_Saint_EWY-0.0"=>"CAN_NB_Saint.John.AP.716090_EWY-0.0.epw", "NB_Saint_EWY-3.0"=>"CAN_NB_Saint.John.AP.716090_EWY-3.0.epw", "NB_Saint_TDY-0.0"=>"CAN_NB_Saint.John.AP.716090_TDY-0.0.epw", "NB_Saint_TDY-3.0"=>"CAN_NB_Saint.John.AP.716090_TDY-3.0.epw", "NB_Saint_TMY-0.0"=>"CAN_NB_Saint.John.AP.716090_TMY-0.0.epw", "NB_Saint_TMY-3.0"=>"CAN_NB_Saint.John.AP.716090_TMY-3.0.epw", "NL_Corner_ECY-0.0"=>"CAN_NL_Corner.Brook.719730_ECY-0.0.epw", "NL_Corner_ECY-3.0"=>"CAN_NL_Corner.Brook.719730_ECY-3.0.epw", "NL_Corner_EWY-0.0"=>"CAN_NL_Corner.Brook.719730_EWY-0.0.epw", "NL_Corner_EWY-3.0"=>"CAN_NL_Corner.Brook.719730_EWY-3.0.epw", "NL_Corner_TDY-0.0"=>"CAN_NL_Corner.Brook.719730_TDY-0.0.epw", "NL_Corner_TDY-3.0"=>"CAN_NL_Corner.Brook.719730_TDY-3.0.epw", "NL_Corner_TMY-0.0"=>"CAN_NL_Corner.Brook.719730_TMY-0.0.epw", "NL_Corner_TMY-3.0"=>"CAN_NL_Corner.Brook.719730_TMY-3.0.epw", "NL_St_ECY-0.0"=>"CAN_NL_St.Johns.Intl.AP.718010_ECY-0.0.epw", "NL_St_ECY-3.0"=>"CAN_NL_St.Johns.Intl.AP.718010_ECY-3.0.epw", "NL_St_EWY-0.0"=>"CAN_NL_St.Johns.Intl.AP.718010_EWY-0.0.epw", "NL_St_EWY-3.0"=>"CAN_NL_St.Johns.Intl.AP.718010_EWY-3.0.epw", "NL_St_TDY-0.0"=>"CAN_NL_St.Johns.Intl.AP.718010_TDY-0.0.epw", "NL_St_TDY-3.0"=>"CAN_NL_St.Johns.Intl.AP.718010_TDY-3.0.epw", "NL_St_TMY-0.0"=>"CAN_NL_St.Johns.Intl.AP.718010_TMY-0.0.epw", "NL_St_TMY-3.0"=>"CAN_NL_St.Johns.Intl.AP.718010_TMY-3.0.epw", "NS_Halifax_ECY-0.0"=>"CAN_NS_Halifax.Intl.AP.713950_ECY-0.0.epw", "NS_Halifax_ECY-3.0"=>"CAN_NS_Halifax.Intl.AP.713950_ECY-3.0.epw", "NS_Halifax_EWY-0.0"=>"CAN_NS_Halifax.Intl.AP.713950_EWY-0.0.epw", "NS_Halifax_EWY-3.0"=>"CAN_NS_Halifax.Intl.AP.713950_EWY-3.0.epw", "NS_Halifax_TDY-0.0"=>"CAN_NS_Halifax.Intl.AP.713950_TDY-0.0.epw", "NS_Halifax_TDY-3.0"=>"CAN_NS_Halifax.Intl.AP.713950_TDY-3.0.epw", "NS_Halifax_TMY-0.0"=>"CAN_NS_Halifax.Intl.AP.713950_TMY-0.0.epw", "NS_Halifax_TMY-3.0"=>"CAN_NS_Halifax.Intl.AP.713950_TMY-3.0.epw", "NS_Sydney-McCurdy_ECY-0.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_ECY-0.0.epw", "NS_Sydney-McCurdy_ECY-3.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_ECY-3.0.epw", "NS_Sydney-McCurdy_EWY-0.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_EWY-0.0.epw", "NS_Sydney-McCurdy_EWY-3.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_EWY-3.0.epw", "NS_Sydney-McCurdy_TDY-0.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_TDY-0.0.epw", "NS_Sydney-McCurdy_TDY-3.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_TDY-3.0.epw", "NS_Sydney-McCurdy_TMY-0.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_TMY-0.0.epw", "NS_Sydney-McCurdy_TMY-3.0"=>"CAN_NS_Sydney-McCurdy.AP.717070_TMY-3.0.epw", "NT_Inuvik-Zubko_ECY-0.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_ECY-0.0.epw", "NT_Inuvik-Zubko_ECY-3.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_ECY-3.0.epw", "NT_Inuvik-Zubko_EWY-0.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_EWY-0.0.epw", "NT_Inuvik-Zubko_EWY-3.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_EWY-3.0.epw", "NT_Inuvik-Zubko_TDY-0.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_TDY-0.0.epw", "NT_Inuvik-Zubko_TDY-3.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_TDY-3.0.epw", "NT_Inuvik-Zubko_TMY-0.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_TMY-0.0.epw", "NT_Inuvik-Zubko_TMY-3.0"=>"CAN_NT_Inuvik-Zubko.AP.719570_TMY-3.0.epw", "NT_Yellowknife_ECY-0.0"=>"CAN_NT_Yellowknife.AP.719360_ECY-0.0.epw", "NT_Yellowknife_ECY-3.0"=>"CAN_NT_Yellowknife.AP.719360_ECY-3.0.epw", "NT_Yellowknife_EWY-0.0"=>"CAN_NT_Yellowknife.AP.719360_EWY-0.0.epw", "NT_Yellowknife_EWY-3.0"=>"CAN_NT_Yellowknife.AP.719360_EWY-3.0.epw", "NT_Yellowknife_TDY-0.0"=>"CAN_NT_Yellowknife.AP.719360_TDY-0.0.epw", "NT_Yellowknife_TDY-3.0"=>"CAN_NT_Yellowknife.AP.719360_TDY-3.0.epw", "NT_Yellowknife_TMY-0.0"=>"CAN_NT_Yellowknife.AP.719360_TMY-0.0.epw", "NT_Yellowknife_TMY-3.0"=>"CAN_NT_Yellowknife.AP.719360_TMY-3.0.epw", "NU_Cambridge_ECY-0.0"=>"CAN_NU_Cambridge.Bay.AP.719250_ECY-0.0.epw", "NU_Cambridge_ECY-3.0"=>"CAN_NU_Cambridge.Bay.AP.719250_ECY-3.0.epw", "NU_Cambridge_EWY-0.0"=>"CAN_NU_Cambridge.Bay.AP.719250_EWY-0.0.epw", "NU_Cambridge_EWY-3.0"=>"CAN_NU_Cambridge.Bay.AP.719250_EWY-3.0.epw", "NU_Cambridge_TDY-0.0"=>"CAN_NU_Cambridge.Bay.AP.719250_TDY-0.0.epw", "NU_Cambridge_TDY-3.0"=>"CAN_NU_Cambridge.Bay.AP.719250_TDY-3.0.epw", "NU_Cambridge_TMY-0.0"=>"CAN_NU_Cambridge.Bay.AP.719250_TMY-0.0.epw", "NU_Cambridge_TMY-3.0"=>"CAN_NU_Cambridge.Bay.AP.719250_TMY-3.0.epw", "NU_Iqaluit_ECY-0.0"=>"CAN_NU_Iqaluit.AP.719090_ECY-0.0.epw", "NU_Iqaluit_ECY-3.0"=>"CAN_NU_Iqaluit.AP.719090_ECY-3.0.epw", "NU_Iqaluit_EWY-0.0"=>"CAN_NU_Iqaluit.AP.719090_EWY-0.0.epw", "NU_Iqaluit_EWY-3.0"=>"CAN_NU_Iqaluit.AP.719090_EWY-3.0.epw", "NU_Iqaluit_TDY-0.0"=>"CAN_NU_Iqaluit.AP.719090_TDY-0.0.epw", "NU_Iqaluit_TDY-3.0"=>"CAN_NU_Iqaluit.AP.719090_TDY-3.0.epw", "NU_Iqaluit_TMY-0.0"=>"CAN_NU_Iqaluit.AP.719090_TMY-0.0.epw", "NU_Iqaluit_TMY-3.0"=>"CAN_NU_Iqaluit.AP.719090_TMY-3.0.epw", "NU_Rankin_ECY-0.0"=>"CAN_NU_Rankin.Inlet.AP.710830_ECY-0.0.epw", "NU_Rankin_ECY-3.0"=>"CAN_NU_Rankin.Inlet.AP.710830_ECY-3.0.epw", "NU_Rankin_EWY-0.0"=>"CAN_NU_Rankin.Inlet.AP.710830_EWY-0.0.epw", "NU_Rankin_EWY-3.0"=>"CAN_NU_Rankin.Inlet.AP.710830_EWY-3.0.epw", "NU_Rankin_TDY-0.0"=>"CAN_NU_Rankin.Inlet.AP.710830_TDY-0.0.epw", "NU_Rankin_TDY-3.0"=>"CAN_NU_Rankin.Inlet.AP.710830_TDY-3.0.epw", "NU_Rankin_TMY-0.0"=>"CAN_NU_Rankin.Inlet.AP.710830_TMY-0.0.epw", "NU_Rankin_TMY-3.0"=>"CAN_NU_Rankin.Inlet.AP.710830_TMY-3.0.epw", "ON_Ottawa-Macdonald-Cartier_ECY-0.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_ECY-0.0.epw", "ON_Ottawa-Macdonald-Cartier_ECY-3.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_ECY-3.0.epw", "ON_Ottawa-Macdonald-Cartier_EWY-0.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_EWY-0.0.epw", "ON_Ottawa-Macdonald-Cartier_EWY-3.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_EWY-3.0.epw", "ON_Ottawa-Macdonald-Cartier_TDY-0.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TDY-0.0.epw", "ON_Ottawa-Macdonald-Cartier_TDY-3.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TDY-3.0.epw", "ON_Ottawa-Macdonald-Cartier_TMY-0.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TMY-0.0.epw", "ON_Ottawa-Macdonald-Cartier_TMY-3.0"=>"CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TMY-3.0.epw", "ON_Sudbury_ECY-0.0"=>"CAN_ON_Sudbury.AP.717300_ECY-0.0.epw", "ON_Sudbury_ECY-3.0"=>"CAN_ON_Sudbury.AP.717300_ECY-3.0.epw", "ON_Sudbury_EWY-0.0"=>"CAN_ON_Sudbury.AP.717300_EWY-0.0.epw", "ON_Sudbury_EWY-3.0"=>"CAN_ON_Sudbury.AP.717300_EWY-3.0.epw", "ON_Sudbury_TDY-0.0"=>"CAN_ON_Sudbury.AP.717300_TDY-0.0.epw", "ON_Sudbury_TDY-3.0"=>"CAN_ON_Sudbury.AP.717300_TDY-3.0.epw", "ON_Sudbury_TMY-0.0"=>"CAN_ON_Sudbury.AP.717300_TMY-0.0.epw", "ON_Sudbury_TMY-3.0"=>"CAN_ON_Sudbury.AP.717300_TMY-3.0.epw", "ON_Toronto_ECY-0.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_ECY-0.0.epw", "ON_Toronto_ECY-3.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_ECY-3.0.epw", "ON_Toronto_EWY-0.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_EWY-0.0.epw", "ON_Toronto_EWY-3.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_EWY-3.0.epw", "ON_Toronto_TDY-0.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_TDY-0.0.epw", "ON_Toronto_TDY-3.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_TDY-3.0.epw", "ON_Toronto_TMY-0.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_TMY-0.0.epw", "ON_Toronto_TMY-3.0"=>"CAN_ON_Toronto.Pearson.Intl.AP.716240_TMY-3.0.epw", "PE_Charlottetown_ECY-0.0"=>"CAN_PE_Charlottetown.AP.717060_ECY-0.0.epw", "PE_Charlottetown_ECY-3.0"=>"CAN_PE_Charlottetown.AP.717060_ECY-3.0.epw", "PE_Charlottetown_EWY-0.0"=>"CAN_PE_Charlottetown.AP.717060_EWY-0.0.epw", "PE_Charlottetown_EWY-3.0"=>"CAN_PE_Charlottetown.AP.717060_EWY-3.0.epw", "PE_Charlottetown_TDY-0.0"=>"CAN_PE_Charlottetown.AP.717060_TDY-0.0.epw", "PE_Charlottetown_TDY-3.0"=>"CAN_PE_Charlottetown.AP.717060_TDY-3.0.epw", "PE_Charlottetown_TMY-0.0"=>"CAN_PE_Charlottetown.AP.717060_TMY-0.0.epw", "PE_Charlottetown_TMY-3.0"=>"CAN_PE_Charlottetown.AP.717060_TMY-3.0.epw", "QC_Jonquiere_ECY-0.0"=>"CAN_QC_Jonquiere.716170_ECY-0.0.epw", "QC_Jonquiere_ECY-3.0"=>"CAN_QC_Jonquiere.716170_ECY-3.0.epw", "QC_Jonquiere_EWY-0.0"=>"CAN_QC_Jonquiere.716170_EWY-0.0.epw", "QC_Jonquiere_EWY-3.0"=>"CAN_QC_Jonquiere.716170_EWY-3.0.epw", "QC_Jonquiere_TDY-0.0"=>"CAN_QC_Jonquiere.716170_TDY-0.0.epw", "QC_Jonquiere_TDY-3.0"=>"CAN_QC_Jonquiere.716170_TDY-3.0.epw", "QC_Jonquiere_TMY-0.0"=>"CAN_QC_Jonquiere.716170_TMY-0.0.epw", "QC_Jonquiere_TMY-3.0"=>"CAN_QC_Jonquiere.716170_TMY-3.0.epw", "QC_Montreal-Trudeau_ECY-0.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_ECY-0.0.epw", "QC_Montreal-Trudeau_ECY-3.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_ECY-3.0.epw", "QC_Montreal-Trudeau_EWY-0.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_EWY-0.0.epw", "QC_Montreal-Trudeau_EWY-3.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_EWY-3.0.epw", "QC_Montreal-Trudeau_TDY-0.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_TDY-0.0.epw", "QC_Montreal-Trudeau_TDY-3.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_TDY-3.0.epw", "QC_Montreal-Trudeau_TMY-0.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_TMY-0.0.epw", "QC_Montreal-Trudeau_TMY-3.0"=>"CAN_QC_Montreal-Trudeau.Intl.AP.716270_TMY-3.0.epw", "QC_Quebec-Lesage_ECY-0.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_ECY-0.0.epw", "QC_Quebec-Lesage_ECY-3.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_ECY-3.0.epw", "QC_Quebec-Lesage_EWY-0.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_EWY-0.0.epw", "QC_Quebec-Lesage_EWY-3.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_EWY-3.0.epw", "QC_Quebec-Lesage_TDY-0.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_TDY-0.0.epw", "QC_Quebec-Lesage_TDY-3.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_TDY-3.0.epw", "QC_Quebec-Lesage_TMY-0.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_TMY-0.0.epw", "QC_Quebec-Lesage_TMY-3.0"=>"CAN_QC_Quebec-Lesage.Intl.AP.717140_TMY-3.0.epw", "SK_Regina_ECY-0.0"=>"CAN_SK_Regina.Intl.AP.715140_ECY-0.0.epw", "SK_Regina_ECY-3.0"=>"CAN_SK_Regina.Intl.AP.715140_ECY-3.0.epw", "SK_Regina_EWY-0.0"=>"CAN_SK_Regina.Intl.AP.715140_EWY-0.0.epw", "SK_Regina_EWY-3.0"=>"CAN_SK_Regina.Intl.AP.715140_EWY-3.0.epw", "SK_Regina_TDY-0.0"=>"CAN_SK_Regina.Intl.AP.715140_TDY-0.0.epw", "SK_Regina_TDY-3.0"=>"CAN_SK_Regina.Intl.AP.715140_TDY-3.0.epw", "SK_Regina_TMY-0.0"=>"CAN_SK_Regina.Intl.AP.715140_TMY-0.0.epw", "SK_Regina_TMY-3.0"=>"CAN_SK_Regina.Intl.AP.715140_TMY-3.0.epw", "SK_Saskatoon_ECY-0.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_ECY-0.0.epw", "SK_Saskatoon_ECY-3.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_ECY-3.0.epw", "SK_Saskatoon_EWY-0.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_EWY-0.0.epw", "SK_Saskatoon_EWY-3.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_EWY-3.0.epw", "SK_Saskatoon_TDY-0.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_TDY-0.0.epw", "SK_Saskatoon_TDY-3.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_TDY-3.0.epw", "SK_Saskatoon_TMY-0.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_TMY-0.0.epw", "SK_Saskatoon_TMY-3.0"=>"CAN_SK_Saskatoon.Intl.AP.718660_TMY-3.0.epw", "YT_Dawson_ECY-0.0"=>"CAN_YT_Dawson.719660_ECY-0.0.epw", "YT_Dawson_ECY-3.0"=>"CAN_YT_Dawson.719660_ECY-3.0.epw", "YT_Dawson_EWY-0.0"=>"CAN_YT_Dawson.719660_EWY-0.0.epw", "YT_Dawson_EWY-3.0"=>"CAN_YT_Dawson.719660_EWY-3.0.epw", "YT_Dawson_TDY-0.0"=>"CAN_YT_Dawson.719660_TDY-0.0.epw", "YT_Dawson_TDY-3.0"=>"CAN_YT_Dawson.719660_TDY-3.0.epw", "YT_Dawson_TMY-0.0"=>"CAN_YT_Dawson.719660_TMY-0.0.epw", "YT_Dawson_TMY-3.0"=>"CAN_YT_Dawson.719660_TMY-3.0.epw", "YT_Whitehorse_ECY-0.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_ECY-0.0.epw", "YT_Whitehorse_ECY-3.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_ECY-3.0.epw", "YT_Whitehorse_EWY-0.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_EWY-0.0.epw", "YT_Whitehorse_EWY-3.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_EWY-3.0.epw", "YT_Whitehorse_TDY-0.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_TDY-0.0.epw", "YT_Whitehorse_TDY-3.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_TDY-3.0.epw", "YT_Whitehorse_TMY-0.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_TMY-0.0.epw", "YT_Whitehorse_TMY-3.0"=>"CAN_YT_Whitehorse.Intl.AP.719640_TMY-3.0.epw"}

    # Assign the user inputs to variables that can be accessed across the measure
    building_type = arguments['building_type']
    template = arguments['template']
    epw_file1 = arguments['epw_file']
    sideload = arguments['sideload']
    epw_file = w_files[epw_file1]

    # Turn debugging output on/off
    @debug = false

    # Open a channel to log info/warning/error messages
    @msg_log = OpenStudio::StringStreamLogSink.new
    if @debug
      @msg_log.setLogLevel(OpenStudio::Debug)
    else
      @msg_log.setLogLevel(OpenStudio::Info)
    end
    @start_time = Time.new
    @runner = runner

    # Create model
    building_name = "#{template}_#{building_type}"
    puts "Creating #{building_name}"
    standard = Standard.build(template)

    # Side load json files into standard.
    if sideload then
      json_sideload(standard)
    end

    # Create prototype model and update to follow standard rules (plus any sideload).
    new_model = standard.model_create_prototype_model(template: template,
                                                      building_type: building_type,
                                                      epw_file: epw_file,
                                                      sizing_run_dir: NRCMeasureTestHelper.outputFolder)
    standard.model_replace_model(model, new_model)
    log_msgs
    return true
  end

  #end the run method

  # Get all the log messages and put into output
  # for users to see.
  def log_msgs
    @msg_log.logMessages.each do |msg|
      # DLM: you can filter on log channel here for now
      if /openstudio.*/.match(msg.logChannel) #/openstudio\.model\..*/
        # Skip certain messages that are irrelevant/misleading
        next if msg.logMessage.include?("Skipping layer") || # Annoying/bogus "Skipping layer" warnings
          msg.logChannel.include?("runmanager") || # RunManager messages
          msg.logChannel.include?("setFileExtension") || # .ddy extension unexpected
          msg.logChannel.include?("Translator") || # Forward translator and geometry translator
          msg.logMessage.include?("UseWeatherFile") # 'UseWeatherFile' is not yet a supported option for YearDescription

        # Report the message in the correct way
        if msg.logLevel == OpenStudio::Info
          @runner.registerInfo(msg.logMessage)
        elsif msg.logLevel == OpenStudio::Warn
          @runner.registerWarning("[#{msg.logChannel}] #{msg.logMessage}")
        elsif msg.logLevel == OpenStudio::Error
          @runner.registerError("[#{msg.logChannel}] #{msg.logMessage}")
        elsif msg.logLevel == OpenStudio::Debug && @debug
          @runner.registerInfo("DEBUG - #{msg.logMessage}")
        end
      end
    end
    @runner.registerInfo("Total Time = #{(Time.new - @start_time).round}sec.")
  end

  # Check for sideload files and update standards tables etc.
  def json_sideload(standard)
    path = "#{File.dirname(__FILE__)}/resources/data_sideload"
    raise ('Could not find data_sideload folder') unless Dir.exist?(path)
    files = Dir.glob("#{path}/*.json").select { |e| File.file? e }
    files.each do |file|
      @runner.registerInfo("Reading side load file: #{file}")
      data = JSON.parse(File.read(file))
      if not data["tables"].nil?
        data['tables'].keys.each do |table|
          @runner.registerInfo("Updating standard table: #{table}")
          @runner.registerInfo("Existing data: #{standard.standards_data[table]}")
          @runner.registerInfo("Replacement data: #{data['tables'][table]}")
        end
        standard.standards_data["tables"] = [*standard.standards_data["tables"], *data["tables"]].to_h
        standard.corrupt_standards_database
        data['tables'].keys.each do |table|
          @runner.registerInfo("Table: #{table}")
          @runner.registerInfo("Updated data: #{standard.standards_data[table]}")
        end
      elsif not data["formulas"].nil?
        data['formulas'].keys.each do |formula|
          @runner.registerInfo("Updating standard formula: #{formula}")
          @runner.registerInfo("Existing data   : #{standard.get_standards_formula(formula)}")
          @runner.registerInfo("Replacement data: #{data['formulas'][formula]['value']}")
        end
        standard.standards_data["formulas"] = [*standard.standards_data["formulas"], *data["formulas"]].to_h
        standard.corrupt_standards_database
        data['formulas'].keys.each do |formula|
          @runner.registerInfo("Formula: #{formula}")
          @runner.registerInfo("Updated data    : #{standard.get_standards_formula(formula)}")
        end
      else
        #standard.standards_data[data.keys.first] = data[data.keys.first]
      end
      @runner.registerWarning("Replaced default standard data with contents in #{file}")
    end
    return standard
  end

end #end the measure

#this allows the measure to be use by the application
NrcCreateNECBPrototypeBuilding.new.registerWithApplication