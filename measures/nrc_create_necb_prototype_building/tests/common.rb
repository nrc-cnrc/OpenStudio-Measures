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

  def remove_old_test_results()

    # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
    #  If so then use it to determine what old results are (if not use now).
    start_time=Time.now
    if ARGV.length == 1

      # We have a time. It will be in seconds since the epoch. Update our start_time.
      start_time=Time.at(ARGV[0].to_i)
    end
    NRCMeasureTestHelper.removeOldOutputs(before: start_time)
  end

  class NrcCreateNECBPrototypeBuilding_Test < Minitest::Test

    # Brings in helper methods to simplify argument testing of json and standard argument methods.
    include(NRCMeasureTestHelper)

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

      epw_files= ["AB_Calgary_ECY-0.0", "AB_Calgary_ECY-3.0", "AB_Calgary_EWY-0.0", "AB_Calgary_EWY-3.0", "AB_Calgary_TDY-0.0", "AB_Calgary_TDY-3.0", "AB_Calgary_TMY-0.0", "AB_Calgary_TMY-3.0", "AB_Edmonton_ECY-0.0", "AB_Edmonton_ECY-3.0", "AB_Edmonton_EWY-0.0", "AB_Edmonton_EWY-3.0", "AB_Edmonton_TDY-0.0", "AB_Edmonton_TDY-3.0", "AB_Edmonton_TMY-0.0", "AB_Edmonton_TMY-3.0", "AB_Fort_ECY-0.0", "AB_Fort_ECY-3.0", "AB_Fort_EWY-0.0", "AB_Fort_EWY-3.0", "AB_Fort_TDY-0.0", "AB_Fort_TDY-3.0", "AB_Fort_TMY-0.0", "AB_Fort_TMY-3.0", "BC_Kelowna_ECY-0.0", "BC_Kelowna_ECY-3.0", "BC_Kelowna_EWY-0.0", "BC_Kelowna_EWY-3.0", "BC_Kelowna_TDY-0.0", "BC_Kelowna_TDY-3.0", "BC_Kelowna_TMY-0.0", "BC_Kelowna_TMY-3.0", "BC_Vancouver_ECY-0.0", "BC_Vancouver_ECY-3.0", "BC_Vancouver_EWY-0.0", "BC_Vancouver_EWY-3.0", "BC_Vancouver_TDY-0.0", "BC_Vancouver_TDY-3.0", "BC_Vancouver_TMY-0.0", "BC_Vancouver_TMY-3.0", "BC_Victoria_ECY-0.0", "BC_Victoria_ECY-3.0", "BC_Victoria_EWY-0.0", "BC_Victoria_EWY-3.0", "BC_Victoria_TDY-0.0", "BC_Victoria_TDY-3.0", "BC_Victoria_TMY-0.0", "BC_Victoria_TMY-3.0", "MB_Thompson_ECY-0.0", "MB_Thompson_ECY-3.0", "MB_Thompson_EWY-0.0", "MB_Thompson_EWY-3.0", "MB_Thompson_TDY-0.0", "MB_Thompson_TDY-3.0", "MB_Thompson_TMY-0.0", "MB_Thompson_TMY-3.0", "MB_Winnipeg-Richardson_ECY-0.0", "MB_Winnipeg-Richardson_ECY-3.0", "MB_Winnipeg-Richardson_EWY-0.0", "MB_Winnipeg-Richardson_EWY-3.0", "MB_Winnipeg-Richardson_TDY-0.0", "MB_Winnipeg-Richardson_TDY-3.0", "MB_Winnipeg-Richardson_TMY-0.0", "MB_Winnipeg-Richardson_TMY-3.0", "NB_Moncton-Greater_ECY-0.0", "NB_Moncton-Greater_ECY-3.0", "NB_Moncton-Greater_EWY-0.0", "NB_Moncton-Greater_EWY-3.0", "NB_Moncton-Greater_TDY-0.0", "NB_Moncton-Greater_TDY-3.0", "NB_Moncton-Greater_TMY-0.0", "NB_Moncton-Greater_TMY-3.0", "NB_Saint_ECY-0.0", "NB_Saint_ECY-3.0", "NB_Saint_EWY-0.0", "NB_Saint_EWY-3.0", "NB_Saint_TDY-0.0", "NB_Saint_TDY-3.0", "NB_Saint_TMY-0.0", "NB_Saint_TMY-3.0", "NL_Corner_ECY-0.0", "NL_Corner_ECY-3.0", "NL_Corner_EWY-0.0", "NL_Corner_EWY-3.0", "NL_Corner_TDY-0.0", "NL_Corner_TDY-3.0", "NL_Corner_TMY-0.0", "NL_Corner_TMY-3.0", "NL_St_ECY-0.0", "NL_St_ECY-3.0", "NL_St_EWY-0.0", "NL_St_EWY-3.0", "NL_St_TDY-0.0", "NL_St_TDY-3.0", "NL_St_TMY-0.0", "NL_St_TMY-3.0", "NS_Halifax_ECY-0.0", "NS_Halifax_ECY-3.0", "NS_Halifax_EWY-0.0", "NS_Halifax_EWY-3.0", "NS_Halifax_TDY-0.0", "NS_Halifax_TDY-3.0", "NS_Halifax_TMY-0.0", "NS_Halifax_TMY-3.0", "NS_Sydney-McCurdy_ECY-0.0", "NS_Sydney-McCurdy_ECY-3.0", "NS_Sydney-McCurdy_EWY-0.0", "NS_Sydney-McCurdy_EWY-3.0", "NS_Sydney-McCurdy_TDY-0.0", "NS_Sydney-McCurdy_TDY-3.0", "NS_Sydney-McCurdy_TMY-0.0", "NS_Sydney-McCurdy_TMY-3.0", "NT_Inuvik-Zubko_ECY-0.0", "NT_Inuvik-Zubko_ECY-3.0", "NT_Inuvik-Zubko_EWY-0.0", "NT_Inuvik-Zubko_EWY-3.0", "NT_Inuvik-Zubko_TDY-0.0", "NT_Inuvik-Zubko_TDY-3.0", "NT_Inuvik-Zubko_TMY-0.0", "NT_Inuvik-Zubko_TMY-3.0", "NT_Yellowknife_ECY-0.0", "NT_Yellowknife_ECY-3.0", "NT_Yellowknife_EWY-0.0", "NT_Yellowknife_EWY-3.0", "NT_Yellowknife_TDY-0.0", "NT_Yellowknife_TDY-3.0", "NT_Yellowknife_TMY-0.0", "NT_Yellowknife_TMY-3.0", "NU_Cambridge_ECY-0.0", "NU_Cambridge_ECY-3.0", "NU_Cambridge_EWY-0.0", "NU_Cambridge_EWY-3.0", "NU_Cambridge_TDY-0.0", "NU_Cambridge_TDY-3.0", "NU_Cambridge_TMY-0.0", "NU_Cambridge_TMY-3.0", "NU_Iqaluit_ECY-0.0", "NU_Iqaluit_ECY-3.0", "NU_Iqaluit_EWY-0.0", "NU_Iqaluit_EWY-3.0", "NU_Iqaluit_TDY-0.0", "NU_Iqaluit_TDY-3.0", "NU_Iqaluit_TMY-0.0", "NU_Iqaluit_TMY-3.0", "NU_Rankin_ECY-0.0", "NU_Rankin_ECY-3.0", "NU_Rankin_EWY-0.0", "NU_Rankin_EWY-3.0", "NU_Rankin_TDY-0.0", "NU_Rankin_TDY-3.0", "NU_Rankin_TMY-0.0", "NU_Rankin_TMY-3.0", "ON_Ottawa-Macdonald-Cartier_ECY-0.0", "ON_Ottawa-Macdonald-Cartier_ECY-3.0", "ON_Ottawa-Macdonald-Cartier_EWY-0.0", "ON_Ottawa-Macdonald-Cartier_EWY-3.0", "ON_Ottawa-Macdonald-Cartier_TDY-0.0", "ON_Ottawa-Macdonald-Cartier_TDY-3.0", "ON_Ottawa-Macdonald-Cartier_TMY-0.0", "ON_Ottawa-Macdonald-Cartier_TMY-3.0", "ON_Sudbury_ECY-0.0", "ON_Sudbury_ECY-3.0", "ON_Sudbury_EWY-0.0", "ON_Sudbury_EWY-3.0", "ON_Sudbury_TDY-0.0", "ON_Sudbury_TDY-3.0", "ON_Sudbury_TMY-0.0", "ON_Sudbury_TMY-3.0", "ON_Toronto_ECY-0.0", "ON_Toronto_ECY-3.0", "ON_Toronto_EWY-0.0", "ON_Toronto_EWY-3.0", "ON_Toronto_TDY-0.0", "ON_Toronto_TDY-3.0", "ON_Toronto_TMY-0.0", "ON_Toronto_TMY-3.0", "PE_Charlottetown_ECY-0.0", "PE_Charlottetown_ECY-3.0", "PE_Charlottetown_EWY-0.0", "PE_Charlottetown_EWY-3.0", "PE_Charlottetown_TDY-0.0", "PE_Charlottetown_TDY-3.0", "PE_Charlottetown_TMY-0.0", "PE_Charlottetown_TMY-3.0", "QC_Jonquiere_ECY-0.0", "QC_Jonquiere_ECY-3.0", "QC_Jonquiere_EWY-0.0", "QC_Jonquiere_EWY-3.0", "QC_Jonquiere_TDY-0.0", "QC_Jonquiere_TDY-3.0", "QC_Jonquiere_TMY-0.0", "QC_Jonquiere_TMY-3.0", "QC_Montreal-Trudeau_ECY-0.0", "QC_Montreal-Trudeau_ECY-3.0", "QC_Montreal-Trudeau_EWY-0.0", "QC_Montreal-Trudeau_EWY-3.0", "QC_Montreal-Trudeau_TDY-0.0", "QC_Montreal-Trudeau_TDY-3.0", "QC_Montreal-Trudeau_TMY-0.0", "QC_Montreal-Trudeau_TMY-3.0", "QC_Quebec-Lesage_ECY-0.0", "QC_Quebec-Lesage_ECY-3.0", "QC_Quebec-Lesage_EWY-0.0", "QC_Quebec-Lesage_EWY-3.0", "QC_Quebec-Lesage_TDY-0.0", "QC_Quebec-Lesage_TDY-3.0", "QC_Quebec-Lesage_TMY-0.0", "QC_Quebec-Lesage_TMY-3.0", "SK_Regina_ECY-0.0", "SK_Regina_ECY-3.0", "SK_Regina_EWY-0.0", "SK_Regina_EWY-3.0", "SK_Regina_TDY-0.0", "SK_Regina_TDY-3.0", "SK_Regina_TMY-0.0", "SK_Regina_TMY-3.0", "SK_Saskatoon_ECY-0.0", "SK_Saskatoon_ECY-3.0", "SK_Saskatoon_EWY-0.0", "SK_Saskatoon_EWY-3.0", "SK_Saskatoon_TDY-0.0", "SK_Saskatoon_TDY-3.0", "SK_Saskatoon_TMY-0.0", "SK_Saskatoon_TMY-3.0", "YT_Dawson_ECY-0.0", "YT_Dawson_ECY-3.0", "YT_Dawson_EWY-0.0", "YT_Dawson_EWY-3.0", "YT_Dawson_TDY-0.0", "YT_Dawson_TDY-3.0", "YT_Dawson_TMY-0.0", "YT_Dawson_TMY-3.0", "YT_Whitehorse_ECY-0.0", "YT_Whitehorse_ECY-3.0", "YT_Whitehorse_EWY-0.0", "YT_Whitehorse_EWY-3.0", "YT_Whitehorse_TDY-0.0", "YT_Whitehorse_TDY-3.0", "YT_Whitehorse_TMY-0.0", "YT_Whitehorse_TMY-3.0"]

      @measure_interface_detailed = [
        {
          "name" => "template",
          "type" => "Choice",
          "display_name" => "Template",
          "default_value" => "NECB2017",
          "choices" => ["NECB2011", "NECB2015", "NECB2017"],
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
          "default_value" => epw_files[0],
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

      @good_input_arguments = {
        "template" => "NECB2017",
        "building_type" => "Warehouse",
        "epw_file" => "AB_Calgary_ECY-0.0",
        "sideload" => false
      }
    end

    def run_test(necb_template:, building_type_in:, epw_file_in:)
      puts "Testing  model creation for ".green + "#{building_type_in}-#{necb_template}-#{File.basename(epw_file_in, '.epw')}".light_blue

      ####### Test Model Creation ######
      puts "  Testing model creation for:".green
      puts "  Building type: ".green + " #{building_type_in}".light_blue
      puts "  Code version: ".green + " #{necb_template}".light_blue
      puts "  Location: ".green + " #{File.basename(epw_file_in, '.epw')}".light_blue

      # Make an empty model.
      model = OpenStudio::Model::Model.new

      input_arguments = {
        "template" => necb_template,
        "building_type" => building_type_in,
        "epw_file" => epw_file_in,
        "sideload" => false
      }

      # Define specific output folder for this test.
      model_name = "#{building_type_in}-#{necb_template}-#{File.basename(epw_file_in, '.epw')}"
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{necb_template}/#{model_name}")
      puts "Output folder ". green + "#{output_file_path}".light_blue

      # Run the measure and check output.
      runner = run_measure(input_arguments, model)
      assert(runner.result.value.valueName == 'Success')
      # Save the model to test output directory
      output_file = "#{output_file_path}/#{model_name}.osm"
      model.save(output_file, true)

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
      FileUtils.rm(diff_file) if File.exists?(diff_file)
      if diffs.size > 0
        $num_failed += 1
        File.write(diff_file, JSON.pretty_generate(diffs))
      end

      # Check for no errors.
      puts "There were #{diffs.size} differences/errors in #{building_type_in} #{necb_template} #{epw_file_in}".yellow
      return true
    end
  end
end
