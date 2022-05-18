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
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
    include(NRCMeasureTestHelper)

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
          "name" => "template",
          "type" => "Choice",
          "display_name" => "template",
          "default_value" => "NECB2017",
          "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020"],
          "is_required" => true
        }
      ]

    @good_input_arguments = {
      "upload_osm_file" => "smallOffice_Windsor.osm",
      "update_code_version" => true,
      "template" => "NECB2020"
    }
  end

  def test_model_upload
    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_model")

    model = OpenStudio::Model::Model.new
    # create an instance of the measure
    measure = NrcCreateFromExistingOsmFile.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(3, arguments.size)

    input_arguments=@good_input_arguments
    # Create an instance of the measure with good values
    runner = run_measure(input_arguments, model)
    puts "In the test , the Standards Template".green + "  #{model.getBuilding.standardsTemplate}".light_blue

    # Save the model to test output directory.
    model.save(output_file_path, true)
    puts "Runner output #{show_output(runner.result)}".green
    assert(runner.result.value.valueName == 'Success')
  end
end
