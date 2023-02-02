# Standard openstudio requires for running test.
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper.
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test.
require 'fileutils'

# Core functionality for the tests. Individual test files speed up the testing.
module TestCommon

  def self.remove_old_test_results()

    # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
    #  If so then use it to determine what old results are (if not use now).
    if ENV['OS_MEASURES_TEST_TIME'] != ""
      start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
    else
      start_time=Time.now
    end
    NRCMeasureTestHelper.removeOldOutputs(before: start_time)
  end

  class NrcCreateNECBPrototypeBuilding_Test < Minitest::Test

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
          "name" => "location",
          "type" => "Choice",
          "display_name" => "Location",
          "default_value" => "Calgary",
          "choices" => ["Calgary", "Edmonton", "Fort.McMurray", "Kelowna", "Vancouver", "Victoria", "Thompson", "Winnipeg-Richardson", "Moncton-Greater", "Saint.John", "Corner.Brook", "St.Johns", "Halifax", "Sydney-McCurdy", "Inuvik-Zubko", "Yellowknife", "Cambridge.Bay", "Iqaluit", "Rankin.Inlet", "Ottawa-Macdonald-Cartier", "Sudbury", "Toronto.Pearson", "Charlottetown", "Jonquiere", "Montreal-Trudeau", "Quebec-Lesage", "Regina", "Saskatoon", "Dawson", "Whitehorse"],
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
          "name" => "sideload",
          "type" => "Bool",
          "display_name" => "Check for sideload files (to overwrite standards info)?",
          "default_value" => false,
          "is_required" => true
        }
      ]

      @good_input_arguments = {
        "template" => "NECB2017",
        "building_type" => "Warehouse",
        "location" => "Calgary",
        "weather_file_type" => "ECY",
        "global_warming" => "0.0",
        "sideload" => false
      }
    end

    def run_test(necb_template:, building_type_in:, location_in:, weather_file_type_in:, global_warming_in:)
      puts "Testing  model creation for ".green + "#{building_type_in}-#{necb_template}-#{location_in}".light_blue

      ####### Test Model Creation ######
      puts "  Testing model creation for:".green
      puts "  Building type: ".green + " #{building_type_in}".light_blue
      puts "  Code version: ".green + " #{necb_template}".light_blue
      puts "  Location: ".green + " #{location_in}".light_blue
      puts "  Weather Type: ".green + " #{weather_file_type_in}".light_blue
      puts "  Global Warming: ".green + " #{global_warming_in}".light_blue

      # Make an empty model.
      model = OpenStudio::Model::Model.new

      input_arguments = {
        "template" => necb_template,
        "building_type" => building_type_in,
        "location" => location_in,
        "weather_file_type" => weather_file_type_in,
        "global_warming" => global_warming_in,
        "sideload" => false
      }

      # Define specific output folder for this test.
      model_name = "#{necb_template}-#{building_type_in}-#{location_in}_#{weather_file_type_in}_#{global_warming_in.to_i}"
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{model_name}", input_arguments)
      puts "Output folder ".green + "#{output_file_path}".light_blue

      # Run the measure and check output. Model saved to file 'test_output.osm'
      runner = run_measure(input_arguments, model)
      assert(runner.result.value.valueName == 'Success')
      File.rename("#{output_file_path}/test_output.osm", "#{output_file_path}/#{model_name}.osm")

      begin
        diffs = []

        # Error trapping.
        unless model.instance_of?(OpenStudio::Model::Model)
          puts "ERROR: Creation of Model for #{osm_model_path} failed. Please check output for errors.".red
          return false
        end

        # Find old model for regression test.
        osm_file = "#{File.expand_path(__dir__)}/regression_models/#{model_name}.osm"
        unless File.exist?(osm_file)
          puts "ERROR: The regression model: #{osm_file} does not exist.".red
          return false
        end
        osm_model_path = OpenStudio::Path.new(osm_file.to_s)

        # Upgrade version if required.
        version_translator = OpenStudio::OSVersion::VersionTranslator.new
        old_model = version_translator.loadModel(osm_model_path).get

        # Compare the two models.
        diffs = BTAP::FileIO::compare_osm_files(old_model, model)
      rescue => exception
        # Log error/exception and then keep going.
        error = "#{exception.backtrace.first}: #{exception.message} (#{exception.class})"
        exception.backtrace.drop(1).map { |s| "\n#{s}" }.each { |bt| error << bt.to_s }
        diffs << "#{model_name}: Error \n#{error}"
        puts "ERROR: Checking of model against reference file failed for #{model_name}".red
      end

      # Write out diff or error message (make sure an old file does not exist).
      diff_file = "#{output_file_path}/#{model_name}_diffs.json"
      puts "diff file #{diff_file}".red
      FileUtils.rm(diff_file) if File.exists?(diff_file)
      if diffs.size > 0
        File.write(diff_file, JSON.pretty_generate(diffs))
        puts "There were #{diffs.size} differences/errors in #{building_type_in} #{necb_template} #{location_in} #{weather_file_type_in} #{global_warming_in}".red
      end

      # Check for no errors.
      assert_equal(diffs.size, 0, 'Differences detected fo model #{model_name}')
    end
  end
end
