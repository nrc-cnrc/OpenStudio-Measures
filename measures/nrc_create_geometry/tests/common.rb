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

# Core functionality for the tests. Individual test files speed up the testing.
module TestCommon

  def remove_old_test_results()

    # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
    #  If so then use it to determine what old results are (if not use now)
    start_time=Time.now
    if ARGV.length == 1

      # We have a time. It will be in seconds since the epoch. Update our start_time.
      start_time=Time.at(ARGV[0].to_i)
    end
    NRCMeasureTestHelper.removeOldOutputs(before: start_time)
  end

  class NrcCreateGeometry_Test < Minitest::Test

    # Brings in helper methods to simplify argument testing of json and standard argument methods.
    include(NRCMeasureTestHelper)

    def setup()
      # Copied from measure.
      @use_json_package = false
      @use_string_double = true
	  
	  epw_files= ["AB_Calgary_ECY-0.0", "AB_Calgary_ECY-3.0", "AB_Calgary_EWY-0.0", "AB_Calgary_EWY-3.0", "AB_Calgary_TDY-0.0", "AB_Calgary_TDY-3.0", "AB_Calgary_TMY-0.0", "AB_Calgary_TMY-3.0", "AB_Edmonton_ECY-0.0", "AB_Edmonton_ECY-3.0", "AB_Edmonton_EWY-0.0", "AB_Edmonton_EWY-3.0", "AB_Edmonton_TDY-0.0", "AB_Edmonton_TDY-3.0", "AB_Edmonton_TMY-0.0", "AB_Edmonton_TMY-3.0", "AB_Fort.McMurray_ECY-0.0", "AB_Fort.McMurray_ECY-3.0", "AB_Fort.McMurray_EWY-0.0", "AB_Fort.McMurray_EWY-3.0", "AB_Fort.McMurray_TDY-0.0", "AB_Fort.McMurray_TDY-3.0", "AB_Fort.McMurray_TMY-0.0", "AB_Fort.McMurray_TMY-3.0", "BC_Kelowna_ECY-0.0", "BC_Kelowna_ECY-3.0", "BC_Kelowna_EWY-0.0", "BC_Kelowna_EWY-3.0", "BC_Kelowna_TDY-0.0", "BC_Kelowna_TDY-3.0", "BC_Kelowna_TMY-0.0", "BC_Kelowna_TMY-3.0", "BC_Vancouver_ECY-0.0", "BC_Vancouver_ECY-3.0", "BC_Vancouver_EWY-0.0", "BC_Vancouver_EWY-3.0", "BC_Vancouver_TDY-0.0", "BC_Vancouver_TDY-3.0", "BC_Vancouver_TMY-0.0", "BC_Vancouver_TMY-3.0", "BC_Victoria_ECY-0.0", "BC_Victoria_ECY-3.0", "BC_Victoria_EWY-0.0", "BC_Victoria_EWY-3.0", "BC_Victoria_TDY-0.0", "BC_Victoria_TDY-3.0", "BC_Victoria_TMY-0.0", "BC_Victoria_TMY-3.0", "MB_Thompson_ECY-0.0", "MB_Thompson_ECY-3.0", "MB_Thompson_EWY-0.0", "MB_Thompson_EWY-3.0", "MB_Thompson_TDY-0.0", "MB_Thompson_TDY-3.0", "MB_Thompson_TMY-0.0", "MB_Thompson_TMY-3.0", "MB_Winnipeg-Richardson_ECY-0.0", "MB_Winnipeg-Richardson_ECY-3.0", "MB_Winnipeg-Richardson_EWY-0.0", "MB_Winnipeg-Richardson_EWY-3.0", "MB_Winnipeg-Richardson_TDY-0.0", "MB_Winnipeg-Richardson_TDY-3.0", "MB_Winnipeg-Richardson_TMY-0.0", "MB_Winnipeg-Richardson_TMY-3.0", "NB_Moncton-Greater_ECY-0.0", "NB_Moncton-Greater_ECY-3.0", "NB_Moncton-Greater_EWY-0.0", "NB_Moncton-Greater_EWY-3.0", "NB_Moncton-Greater_TDY-0.0", "NB_Moncton-Greater_TDY-3.0", "NB_Moncton-Greater_TMY-0.0", "NB_Moncton-Greater_TMY-3.0", "NB_Saint.John_ECY-0.0", "NB_Saint.John_ECY-3.0", "NB_Saint.John_EWY-0.0", "NB_Saint.John_EWY-3.0", "NB_Saint.John_TDY-0.0", "NB_Saint.John_TDY-3.0", "NB_Saint.John_TMY-0.0", "NB_Saint.John_TMY-3.0", "NL_Corner.Brook_ECY-0.0", "NL_Corner.Brook_ECY-3.0", "NL_Corner.Brook_EWY-0.0", "NL_Corner.Brook_EWY-3.0", "NL_Corner.Brook_TDY-0.0", "NL_Corner.Brook_TDY-3.0", "NL_Corner.Brook_TMY-0.0", "NL_Corner.Brook_TMY-3.0", "NL_St.Johns_ECY-0.0", "NL_St.Johns_ECY-3.0", "NL_St.Johns_EWY-0.0", "NL_St.Johns_EWY-3.0", "NL_St.Johns_TDY-0.0", "NL_St.Johns_TDY-3.0", "NL_St.Johns_TMY-0.0", "NL_St.Johns_TMY-3.0", "NS_Halifax_ECY-0.0", "NS_Halifax_ECY-3.0", "NS_Halifax_EWY-0.0", "NS_Halifax_EWY-3.0", "NS_Halifax_TDY-0.0", "NS_Halifax_TDY-3.0", "NS_Halifax_TMY-0.0", "NS_Halifax_TMY-3.0", "NS_Sydney-McCurdy_ECY-0.0", "NS_Sydney-McCurdy_ECY-3.0", "NS_Sydney-McCurdy_EWY-0.0", "NS_Sydney-McCurdy_EWY-3.0", "NS_Sydney-McCurdy_TDY-0.0", "NS_Sydney-McCurdy_TDY-3.0", "NS_Sydney-McCurdy_TMY-0.0", "NS_Sydney-McCurdy_TMY-3.0", "NT_Inuvik-Zubko_ECY-0.0", "NT_Inuvik-Zubko_ECY-3.0", "NT_Inuvik-Zubko_EWY-0.0", "NT_Inuvik-Zubko_EWY-3.0", "NT_Inuvik-Zubko_TDY-0.0", "NT_Inuvik-Zubko_TDY-3.0", "NT_Inuvik-Zubko_TMY-0.0", "NT_Inuvik-Zubko_TMY-3.0", "NT_Yellowknife_ECY-0.0", "NT_Yellowknife_ECY-3.0", "NT_Yellowknife_EWY-0.0", "NT_Yellowknife_EWY-3.0", "NT_Yellowknife_TDY-0.0", "NT_Yellowknife_TDY-3.0", "NT_Yellowknife_TMY-0.0", "NT_Yellowknife_TMY-3.0", "NU_Cambridge_ECY-0.0", "NU_Cambridge_ECY-3.0", "NU_Cambridge_EWY-0.0", "NU_Cambridge_EWY-3.0", "NU_Cambridge_TDY-0.0", "NU_Cambridge_TDY-3.0", "NU_Cambridge_TMY-0.0", "NU_Cambridge_TMY-3.0", "NU_Iqaluit_ECY-0.0", "NU_Iqaluit_ECY-3.0", "NU_Iqaluit_EWY-0.0", "NU_Iqaluit_EWY-3.0", "NU_Iqaluit_TDY-0.0", "NU_Iqaluit_TDY-3.0", "NU_Iqaluit_TMY-0.0", "NU_Iqaluit_TMY-3.0", "NU_Rankin_ECY-0.0", "NU_Rankin_ECY-3.0", "NU_Rankin_EWY-0.0", "NU_Rankin_EWY-3.0", "NU_Rankin_TDY-0.0", "NU_Rankin_TDY-3.0", "NU_Rankin_TMY-0.0", "NU_Rankin_TMY-3.0", "ON_Ottawa-Macdonald-Cartier_ECY-0.0", "ON_Ottawa-Macdonald-Cartier_ECY-3.0", "ON_Ottawa-Macdonald-Cartier_EWY-0.0", "ON_Ottawa-Macdonald-Cartier_EWY-3.0", "ON_Ottawa-Macdonald-Cartier_TDY-0.0", "ON_Ottawa-Macdonald-Cartier_TDY-3.0", "ON_Ottawa-Macdonald-Cartier_TMY-0.0", "ON_Ottawa-Macdonald-Cartier_TMY-3.0", "ON_Sudbury_ECY-0.0", "ON_Sudbury_ECY-3.0", "ON_Sudbury_EWY-0.0", "ON_Sudbury_EWY-3.0", "ON_Sudbury_TDY-0.0", "ON_Sudbury_TDY-3.0", "ON_Sudbury_TMY-0.0", "ON_Sudbury_TMY-3.0", "ON_Toronto_ECY-0.0", "ON_Toronto_ECY-3.0", "ON_Toronto_EWY-0.0", "ON_Toronto_EWY-3.0", "ON_Toronto_TDY-0.0", "ON_Toronto_TDY-3.0", "ON_Toronto_TMY-0.0", "ON_Toronto_TMY-3.0", "PE_Charlottetown_ECY-0.0", "PE_Charlottetown_ECY-3.0", "PE_Charlottetown_EWY-0.0", "PE_Charlottetown_EWY-3.0", "PE_Charlottetown_TDY-0.0", "PE_Charlottetown_TDY-3.0", "PE_Charlottetown_TMY-0.0", "PE_Charlottetown_TMY-3.0", "QC_Jonquiere_ECY-0.0", "QC_Jonquiere_ECY-3.0", "QC_Jonquiere_EWY-0.0", "QC_Jonquiere_EWY-3.0", "QC_Jonquiere_TDY-0.0", "QC_Jonquiere_TDY-3.0", "QC_Jonquiere_TMY-0.0", "QC_Jonquiere_TMY-3.0", "QC_Montreal-Trudeau_ECY-0.0", "QC_Montreal-Trudeau_ECY-3.0", "QC_Montreal-Trudeau_EWY-0.0", "QC_Montreal-Trudeau_EWY-3.0", "QC_Montreal-Trudeau_TDY-0.0", "QC_Montreal-Trudeau_TDY-3.0", "QC_Montreal-Trudeau_TMY-0.0", "QC_Montreal-Trudeau_TMY-3.0", "QC_Quebec-Lesage_ECY-0.0", "QC_Quebec-Lesage_ECY-3.0", "QC_Quebec-Lesage_EWY-0.0", "QC_Quebec-Lesage_EWY-3.0", "QC_Quebec-Lesage_TDY-0.0", "QC_Quebec-Lesage_TDY-3.0", "QC_Quebec-Lesage_TMY-0.0", "QC_Quebec-Lesage_TMY-3.0", "SK_Regina_ECY-0.0", "SK_Regina_ECY-3.0", "SK_Regina_EWY-0.0", "SK_Regina_EWY-3.0", "SK_Regina_TDY-0.0", "SK_Regina_TDY-3.0", "SK_Regina_TMY-0.0", "SK_Regina_TMY-3.0", "SK_Saskatoon_ECY-0.0", "SK_Saskatoon_ECY-3.0", "SK_Saskatoon_EWY-0.0", "SK_Saskatoon_EWY-3.0", "SK_Saskatoon_TDY-0.0", "SK_Saskatoon_TDY-3.0", "SK_Saskatoon_TMY-0.0", "SK_Saskatoon_TMY-3.0", "YT_Dawson_ECY-0.0", "YT_Dawson_ECY-3.0", "YT_Dawson_EWY-0.0", "YT_Dawson_EWY-3.0", "YT_Dawson_TDY-0.0", "YT_Dawson_TDY-3.0", "YT_Dawson_TMY-0.0", "YT_Dawson_TMY-3.0", "YT_Whitehorse_ECY-0.0", "YT_Whitehorse_ECY-3.0", "YT_Whitehorse_EWY-0.0", "YT_Whitehorse_EWY-3.0", "YT_Whitehorse_TDY-0.0", "YT_Whitehorse_TDY-3.0", "YT_Whitehorse_TMY-0.0", "YT_Whitehorse_TMY-3.0"]


      @measure_interface_detailed =
        [
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
            "choices" => ["SecondarySchool", "PrimarySchool", "SmallOffice", "MediumOffice", "LargeOffice", "SmallHotel", "LargeHotel", "Warehouse", "RetailStandalone", "RetailStripmall", "QuickServiceRestaurant", "FullServiceRestaurant", "MidriseApartment", "HighriseApartment" "MidriseApartment", "Hospital", "Outpatient"],
            "is_required" => true
          },
          {
            "name" => "epw_file",
            "type" => "Choice",
            "display_name" => "Weather file",
            "default_value" => epw_files[0],
            "choices" => epw_files,
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

      @good_input_arguments = {
        "building_shape" => "Rectangular",
        "template" => "NECB2017",
        "building_type" => "SmallOffice",
        "epw_file" => "ON_Ottawa-Macdonald-Cartier_ECY-0.0",
        "total_floor_area" => 50000.0,
        "aspect_ratio" => 0.5,
        "rotation" => 30.0,
        "above_grade_floors" => 2,
        "floor_to_floor_height" => 3.2,
        "plenum_height" => 1.0,
        "sideload" => false
      }
    end

    def run_test(template: 'NECB2011', building_type: 'Warehouse', building_shape: 'Rectangular', total_floor_area: 20000, above_grade_floors: 3, rotation: 0, epw_file: 'ON_Ottawa-Macdonald-Cartier_ECY-0.0', aspect_ratio: 1)
      
      ####### Test Model Creation ######
      puts "  Testing for arguments:".green
      puts "  Building type: ".green + " #{building_type}".light_blue
      puts "  Building shape: ".green + " #{building_shape}".light_blue
      puts "  Code version: ".green + " #{template}".light_blue
      puts "  Total floor area:".green + " #{total_floor_area}".light_blue
      puts "  Above grade floors: ".green + " #{above_grade_floors}".light_blue
      puts "  Rotation: ".green + " #{rotation}".light_blue
      puts "  Aspect_ratio: ".green + " #{aspect_ratio}".light_blue

      # Make an empty model.
      model = OpenStudio::Model::Model.new

      input_arguments = {
        "building_shape" => building_shape,
        "template" => template,
        "building_type" => building_type,
        "epw_file" => epw_file,
        "total_floor_area" => total_floor_area,
        "aspect_ratio" => aspect_ratio,
        "rotation" => rotation,
        "above_grade_floors" => above_grade_floors,
        "floor_to_floor_height" => 3.2,
        "plenum_height" => 0.0,
        "sideload" => false
      }

      # Get the city name from the weather file
      city1 = epw_file.split("_")
      city = city1[2].split(".").first

      # Define specific output folder for this test. In this case use the tempalet and the model name as this combination is unique.
      model_name = "#{building_shape}-#{building_type}-#{template}-#{rotation.to_int}-#{city}-#{above_grade_floors}-#{total_floor_area.to_int}-#{aspect_ratio}"
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{template}/#{model_name}")
      puts "Output folder ". green + "#{output_file_path}".light_blue
	  
      # Create an instance of the measure with good values
      runner = run_measure(input_arguments, model)

      # Test the model is correctly defined.
      assert_in_delta(total_floor_area.to_f.round(2), model.getBuilding.floorArea.to_f.round(2), 0.1)
      assert_includes(model.getBuilding.standardsTemplate.to_s, input_arguments['template'].to_s, 'code version')
      assert_includes(model.getBuilding.standardsBuildingType.to_s, input_arguments['building_type'].to_s, 'building type')
      assert(runner.result.value.valueName == 'Success')

      # save the model to test output directory
      output_file = "#{output_file_path}/#{model_name}.osm"
      model.save(output_file, true)
    end
  end
end