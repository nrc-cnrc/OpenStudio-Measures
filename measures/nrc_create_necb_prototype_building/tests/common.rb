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

# Core functionality for the tests. Individual test files speed up the testing.
module TestCommon

  class NrcCreateNECBPrototypeBuilding_Test < Minitest::Test

    # Brings in helper methods to simplify argument testing of json and standard argument methods.
    include(NRCMeasureTestHelper)

    def setup()
      # Define the output folder.
      @test_dir = "#{File.dirname(__FILE__)}/output"

      # Create if does not exist. Different logic from outher testing as there are multiple test scripts writing 
      # to this folder so it cannot be deleted.
      if !Dir.exists?(@test_dir)
        puts "Creating output folder: #{@test_dir}"
        Dir.mkdir(@test_dir)
      end

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

      #Drop down selector for Canadian weather files.
      epw_files_chs = OpenStudio::StringVector.new
      ['AB_Banff',
       'AB_Calgary',
       'AB_Edmonton.Intl',
       'AB_Edmonton.Stony.Plain',
       'AB_Fort.McMurray',
       'AB_Grande.Prairie',
       'AB_Lethbridge',
       'AB_Medicine.Hat',
       'BC_Abbotsford',
       'BC_Comox.Valley',
       'BC_Crankbrook-Canadian.Rockies',
       'BC_Fort.St.John-North.Peace',
       'BC_Hope',
       'BC_Kamloops',
       'BC_Port.Hardy',
       'BC_Prince.George',
       'BC_Smithers',
       'BC_Summerland',
       'BC_Vancouver',
       'BC_Victoria',
       'MB_Brandon.Muni',
       'MB_The.Pas',
       'MB_Winnipeg-Richardson',
       'NB_Fredericton',
       'NB_Miramichi',
       'NB_Saint.John',
       'NL_Gander',
       'NL_Goose.Bay',
       'NL_St.Johns',
       'NL_Stephenville',
       'NS_CFB.Greenwood',
       'NS_CFB.Shearwater',
       'NS_Halifax',
       'NS_Sable.Island.Natl.Park',
       'NS_Sydney-McCurdy',
       'NS_Truro',
       'NS_Yarmouth',
       'NT_Inuvik-Zubko',
       'NT_Yellowknife',
       'ON_Armstrong',
       'ON_CFB.Trenton',
       'ON_Dryden',
       'ON_London',
       'ON_Moosonee',
       'ON_Mount.Forest',
       'ON_North.Bay-Garland',
       'ON_Ottawa',
       'ON_Sault.Ste.Marie',
       'ON_Timmins.Power',
       'ON_Toronto',
       'ON_Windsor',
       'PE_Charlottetown',
       'QC_Kuujjuaq',
       'QC_Kuujuarapik',
       'QC_Lac.Eon',
       'QC_Mont-Joli',
       'QC_Montreal-Mirabel',
       'QC_Montreal-St-Hubert.Longueuil',
       'QC_Montreal-Trudeau',
       'QC_Quebec',
       'QC_Riviere-du-Loup',
       'QC_Roberval',
       'QC_Saguenay-Bagotville',
       'QC_Schefferville',
       'QC_Sept-Iles',
       'QC_Val-d-Or',
       'SK_Estevan',
       'SK_North.Battleford',
       'SK_Saskatoon',
       'YT_Whitehorse'].each do |epw_file|
        epw_files_chs << epw_file
      end

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
          "default_value" => "AB_Banff",
          "choices" => epw_files_chs,
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
        "epw_file" => "ON_Ottawa",
        "sideload" => false
      }
    end

    def run_test(necb_template:, building_type_in:, epw_file_in:)

      puts "Testing  model creation for #{building_type_in}-#{necb_template}-#{File.basename(epw_file_in, '.epw')}".blue
      puts "Test dir: #{@test_dir}".blue

      # Make an empty model
      model = OpenStudio::Model::Model.new

      input_arguments = {
        "template" => necb_template,
        "building_type" => building_type_in,
        "epw_file" => epw_file_in,
        "sideload" => false
      }

      # Define specific output folder for this test.
      model_name = "#{building_type_in}-#{necb_template}-#{File.basename(epw_file_in, '.epw')}"
      puts "Output folder #{model_name}".pink
      if Dir.exist?(model_name) then
        puts "WARNING: Removing existing output folder #{model_name}".yellow
        FileUtils.remove_dir(model_name, force = true)
      end
      NRCMeasureTestHelper.setOutputFolder("#{@test_dir}/#{model_name}")

      # Run the measure and check output.
      runner = run_measure(input_arguments, model)
      assert(runner.result.value.valueName == 'Success')
      # save the model to test output directory
      output_file_path = "#{File.dirname(__FILE__)}//#{model_name}.osm"
      model.save(output_file_path, true)

      begin
        diffs = []

        # Error trapping.
        unless model.instance_of?(OpenStudio::Model::Model)
          puts "ERROR: Creation of Model for #{osm_model_path} failed. Please check output for errors.".red
          return false
        end

        # Find old model for regression test.
        # Load the geometry .osm
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
      diff_file = "#{@test_dir}/#{model_name}_diffs.json"
      FileUtils.rm(diff_file) if File.exists?(diff_file)
      if diffs.size > 0
        File.write(diff_file, JSON.pretty_generate(diffs))
      end

      # Check for no errors.
      msg = "There were #{diffs.size} differences/errors in #{building_type_in} #{necb_template} #{epw_file_in}"
      assert_equal(0, diffs.size, msg)

      return true
    end
  end
end
