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

class NrcResizeExistingWindowsToMatchAGivenWWR_Test < Minitest::Test
  include(NRCMeasureTestHelper)

  # Define the output folder.
  @@test_dir = "#{File.dirname(__FILE__)}/output"
  # Remove if existing found. This should only be done once.
  if Dir.exists?(@@test_dir)
    FileUtils.rm_rf(@@test_dir)
  end
  Dir.mkdir(@@test_dir)

  def setup()
    @measure_interface_detailed = [
      {
        "name" => "remove_skylight",
        "type" => "Bool",
        "display_name" => "Remove skylights?",
        "default_value" => false,
        "is_required" => true
      },
      {
        "name" => "cz_4_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 4 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_5_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 5 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_6_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 6 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_7A_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 7A FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_7B_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 7B FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_8_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 8 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "check_wall",
        "type" => "Bool",
        "display_name" => "Only affect surfaces that are 'walls'?",
        "default_value" => false,
        "is_required" => false
      },
      {
        "name" => "check_outdoors",
        "type" => "Bool",
        "display_name" => 'Only affect surfaces that have boundary condition = "Outdoor"?',
        "default_value" => true,
        "is_required" => false
      },
      {
        "name" => "check_sunexposed",
        "type" => "Bool",
        "display_name" => 'Only affect surfaces that are "SunExposed"?',
        "default_value" => true,
        "is_required" => false
      }
    ]
    @good_input_arguments = {
      "remove_skylight" => true,
      "cz_4_fdwr" => 0.2,
      "cz_5_fdwr" => 0.2,
      "cz_6_fdwr" => 0.2,
      "cz_7A_fdwr" => 0.2,
      "cz_7B_fdwr" => 0.2,
      "cz_8_fdwr" => 0.2,
      "check_wall" => true,
      "check_outdoors" => true,
      "check_sunexposed" => true
    }
  end

  def test_argument_values
    measure = NrcResizeExistingWindowsToMatchAGivenWWR.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
      "remove_skylight" => false,
      "cz_4_fdwr" => 0.2,
      "cz_5_fdwr" => 0.2,
      "cz_6_fdwr" => 0.2,
      "cz_7A_fdwr" => 0.2,
      "cz_7B_fdwr" => 0.2,
      "cz_8_fdwr" => 0.2,
      "check_wall" => true,
      "check_outdoors" => true,
      "check_sunexposed" => true
    }
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}")

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(10, arguments.size)
    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    # report final condition of model
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # save the model to test output directory
    output_file_path = "#{File.dirname(__FILE__)}/#{@@test_dir}/test_output.osm"
    model.save(output_file_path, true)
  end
end
