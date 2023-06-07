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

class NrcCreateFromExistingOsmFile_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'].nil?
    start_time=Time.now
  else
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    # Copied from measure.
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed =
      [
        {
          "name" => "upload_osm_file",
          "type" => "Choice",
          "display_name" => "Upload OSM File",
          "default_value" => $all_osm_files[0],
          "choices" => $all_osm_files,
          "is_required" => true
        },
        {
          "name" => "update_code_version",
          "type" => "Bool",
          "display_name" => "Update to match version of code?",
          "default_value" => true,
          "is_required" => true
        },
        {
          "name" => "necb_template",
          "type" => "Choice",
          "display_name" => "Building vintage",
          "default_value" => "NECB2020",
          "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020", "BTAPPRE1980", "BTAP1980TO2010"],
          "is_required" => true
        }
      ]

    @good_input_arguments = {
      "upload_osm_file" => "smallOffice_Victoria.osm",
      "update_code_version" => true,
      "necb_template" => "NECB2020"
    }
  end

  def test_model_upload
    model = OpenStudio::Model::Model.new
    # create an instance of the measure
    measure = NrcCreateFromExistingOsmFile.new

    # Set arguments.
    input_arguments = @good_input_arguments

    # Define the output folder for this test.
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_uploaded_model", input_arguments)

    upload_osm_file = input_arguments['upload_osm_file']
    update_code_version = input_arguments['update_code_version']
    template = input_arguments['necb_template']

    # Create an instance of the measure with good values
    runner = run_measure(input_arguments, model)

    # Test if Standards is applied correctly
    expected_template = model.getBuilding.standardsTemplate
    if update_code_version
      assert_equal(expected_template.to_s, template.to_s)
    end

    # save the model to test output directory
    output_file_path1 = "#{output_file_path}/#{template}.osm"
    model.save(output_file_path1, true)
    assert(runner.result.value.valueName == 'Success')
  end

  def test_model_diff
    # The test will compare models with different templates.
    all_templates = ["NECB2011", "NECB2015", "NECB2020"] # Will compare 2011, 2015, and 2020 to the NECB 2017 small office in Victoria
    # Load osm file
    translator = OpenStudio::OSVersion::VersionTranslator.new
    original_path = "#{File.expand_path(__dir__)}"
    osm_file_path = File.expand_path("../input_osm_files/smallOffice_Victoria.osm", original_path)
    initial_model = translator.loadModel(osm_file_path.to_s).get
    initial_template = initial_model.getBuilding.standardsTemplate
    model = translator.loadModel(osm_file_path.to_s).get

    all_templates.each do |template|
      puts "Comparing".green + " #{initial_template}".light_blue + " and".green + " #{template}"

      # Set arguments.
      input_arguments = {
        "upload_osm_file" => "smallOffice_Victoria.osm",
        "update_code_version" => true,
        "template" => template
      }

      # Define the output folder for this test
      outputFolder = "diff_templates_#{initial_template}_#{template}"
      output_file_path = NRCMeasureTestHelper.appendOutputFolder(outputFolder, input_arguments)

      # Create an instance of the measure with good values.
      runner = run_measure(input_arguments, model)

      # Compare the two models.
      begin
        diffs = []
        diffs = BTAP::FileIO::compare_osm_files(initial_model, model)

      rescue => exception
        # Log error/exception and then keep going.
        error = "#{exception.backtrace.first}: #{exception.message} (#{exception.class})"
        exception.backtrace.drop(1).map { |s| "\n#{s}" }.each { |bt| error << bt.to_s }
        diffs << ": Error \n#{error}"
      end

      # Write out diff or error message.
      diff_file = "#{output_file_path}_diffs.json"
      FileUtils.rm(diff_file) if File.exists?(diff_file)

      if diffs.size > 0
        File.write(diff_file, JSON.pretty_generate(diffs))
        puts "There were".green + " #{diffs.size}".light_blue + " differences/errors in".green + " #{initial_template} - #{template} ".light_blue
        { "diffs-errors" => diffs }
      end
    end
  end
end
