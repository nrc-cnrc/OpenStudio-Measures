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

  def self.remove_old_test_results()

    # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
    #  If so then use it to determine what old results are (if not use now).
    if ENV['OS_MEASURES_TEST_TIME'].nil?
      start_time=Time.now
    else
      start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
    end
      NRCMeasureTestHelper.removeOldOutputs(before: start_time)
    end

  class NrcCreateGeometry_Test < Minitest::Test

    # Brings in helper methods to simplify argument testing of json and standard argument methods
    # and set standard output folder.
    include(NRCMeasureTestHelper)
    folder = "#{self.name}"
    folder.slice!("TestCommon::")
    NRCMeasureTestHelper.setOutputFolder("#{folder}")


    def setup()
      # Copied from measure.
      @use_json_package = false
      @use_string_double = true

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
            "choices" => ["SecondarySchool", "PrimarySchool", "SmallOffice", "MediumOffice", "LargeOffice", "SmallHotel", "LargeHotel", "Warehouse", "RetailStandalone", "RetailStripmall", "QuickServiceRestaurant", "FullServiceRestaurant", "MidriseApartment", "HighriseApartment" "MidriseApartment", "Hospital", "Outpatient"],
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

      @good_input_arguments = {
        "building_shape" => "Rectangular",
        "necb_template" => "NECB2017",
        "building_type" => "SmallOffice",
        "location" => "AB_Calgary",
        "weather_file_type" => "CWEC2020",
        "global_warming" => "0.0",
        "total_floor_area" => 50000.0,
        "aspect_ratio" => 0.5,
        "rotation" => 30.0,
        "above_grade_floors" => 2,
        "floor_to_floor_height" => 3.2,
        "plenum_height" => 1.0,
        "hvac_fuel" => "DefaultFuel",
        "sideload" => false
      }
    end

    def run_test(template: 'NECB2017', building_type: 'Warehouse', building_shape: 'Rectangular', total_floor_area: 20000, above_grade_floors: 3, rotation: 0, location: "Calgary", weather_file_type: "ECY", global_warming: "0.0", aspect_ratio: 1, hvac_fuel: "DefaultFuel")

      ####### Test Model Creation ######
      puts "  Testing for arguments:".green
      puts "  Building type: ".green + " #{building_type}".light_blue
      puts "  Building shape: ".green + " #{building_shape}".light_blue
      puts "  Code version: ".green + " #{template}".light_blue
      puts "  Total floor area:".green + " #{total_floor_area}".light_blue
      puts "  Above grade floors: ".green + " #{above_grade_floors}".light_blue
      puts "  Rotation: ".green + " #{rotation}".light_blue
      puts "  Aspect_ratio: ".green + " #{aspect_ratio}".light_blue
      puts "  Location: ".green + " #{location}".light_blue
      puts "  Weather Type: ".green + " #{weather_file_type}".light_blue
      puts "  HVAC Fuel: ".green + " #{hvac_fuel}".light_blue
      puts "  Global Warming: ".green + " #{global_warming}".light_blue

      # Make an empty model.
      model = OpenStudio::Model::Model.new

      input_arguments = {
        "building_shape" => building_shape,
        "necb_template" => template,
        "building_type" => building_type,
        "location" => location,
        "weather_file_type" => weather_file_type,
        "global_warming" => global_warming,
        "total_floor_area" => total_floor_area,
        "aspect_ratio" => aspect_ratio,
        "rotation" => rotation,
        "above_grade_floors" => above_grade_floors,
        "floor_to_floor_height" => 3.2,
        "plenum_height" => 0.0,
        "hvac_fuel" => hvac_fuel,
        "sideload" => false
      }

      # Define specific output folder for this test. In this case use the tempalet and the model name as this combination is unique.
      model_name = "#{building_shape}-#{building_type}-#{template}-#{rotation.to_int}-#{above_grade_floors}-#{total_floor_area.to_int}-#{aspect_ratio}_#{location}_#{weather_file_type}_#{global_warming.to_i}_#{hvac_fuel}"
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{model_name}", input_arguments)
      puts "Output folder ".green + "#{output_file_path}".light_blue

      # Create an instance of the measure with good values
      runner = run_measure(input_arguments, model)

      # Test the model is correctly defined.
      assert_in_delta(total_floor_area.to_f.round(2), model.getBuilding.floorArea.to_f.round(2), 0.1)
      assert_includes(model.getBuilding.standardsTemplate.to_s, input_arguments['template'].to_s, 'code version')
      assert_includes(model.getBuilding.standardsBuildingType.to_s, input_arguments['building_type'].to_s, 'building type')
      assert(runner.result.value.valueName == 'Success')

      # Save the model to test output directory.
      output_file = "#{output_file_path}.osm"
      model.save(output_file, true)
    end
  end
end