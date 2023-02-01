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

class NrcModelMeasure_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  start_time=Time.now
  if ARGV.length == 1

    # We have a time. It will be in seconds since the epoch. Update our start_time.
    start_time=Time.at(ARGV[0].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)

  # Start of the test methods.
  def setup()

    # These three variables should match the definitions in the measure itself (unfortunately it has to be copied and
    #   cannot be referenced.
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "a_string_argument",
        "type" => "String",
        "display_name" => "A String Argument (string)",
        "default_value" => "The Default Value",
        "is_required" => false
      },
      {
        "name" => "a_double_argument",
        "type" => "Double",
        "display_name" => "A Double numeric Argument (double)",
        "default_value" => 0,
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "is_required" => false
      },
      {
        "name" => "a_string_double_argument",
        "type" => "StringDouble",
        "display_name" => "A String Double numeric Argument (double)",
        "default_value" => 23.0,
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "valid_strings" => ["NA"],
        "is_required" => false
      },
      {
        "name" => "a_choice_argument",
        "type" => "Choice",
        "display_name" => "A Choice String Argument ",
        "default_value" => "choice_1",
        "choices" => ["choice_1", "choice_2"],
        "is_required" => false
      },
      {
        "name" => "a_bool_argument",
        "type" => "Bool",
        "display_name" => "A Boolean Argument ",
        "default_value" => false,
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for standard BTAP checking to work.
    @good_input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 50.0,
      "a_string_double_argument" => "50.0",
      "a_choice_argument" => "choice_1",
      "a_bool_argument" => true
    }
  end

  # Now define the tests. The method names must start "test_" to be automatically detected.
  # Example of loading an existing osm file. This is the fastest method for testing.
  def test_sample_A()
    puts "Testing model creation - example A".green

    # Define the output folder for this test. Thi sis used as the folder name and in the test README.md file as the
    #  section name. (Optional - default is the method name but better to use a meaningful name here).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Test Model Creation A")

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/SmallOffice.osm")

    # Assign the local weather file (have to provide a full path to EpwFile).
    epw = OpenStudio::EpwFile.new("#{File.dirname(__FILE__)}/weather_files/CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw")
    OpenStudio::Model::WeatherFile::setWeatherFile(model, epw)

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 10.0,
      "a_string_double_argument" => 75.3,
      "a_choice_argument" => "choice_1"
    }

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that the measure returned 'success'.
    assert(runner.result.value.valueName == 'Success')

    # Check the stored outputs. This requires the output to be defined in the measure.
    output_object = runner.result.stepValues.find {|item| item.name.eql?'name_of_output'}
    value = output_object.valueAsDouble
    assert_in_delta(value.signif(2), 5.2, 0.01, "Error in example checking on an output value") # Use for comparing doubles.

    # In a real measure add tests that are specific to the measure here.
  end

  # Example of using a prototype model 
  def test_sample_B()
    puts "Testing model creation - example B".green

    # Define the output folder for this test. Thi sis used as the folder name and in the test README.md file as the
    #  section name. (Optional - default is the method name but better to use a meaningful name here).
    NRCMeasureTestHelper.appendOutputFolder("Test Model Creation B")

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "SmallOffice",
                                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                                  sizing_run_dir: NRCMeasureTestHelper.appendOutputFolder("test_sample_2"))

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 10.0,
      "a_string_double_argument" => 75.3,
      "a_choice_argument" => "choice_1"
    }

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Check the stored outputs. This requires the output to be defined in the measure.
    output_object = runner.result.stepValues.find {|item| item.name.eql?'name_of_output'}
    value = output_object.valueAsDouble
    assert_in_delta(value.signif(2), 5.2, 0.01, "Error in example checking on an output value") # Use for comparing doubles.

    # In a real measure add tests that are specific to the measure here.
  end

  # Example starting from an empty model object.
  def test_sample_C()
    puts "Testing model creation - example C".green

    # Define the output folder for this test. Thi sis used as the folder name and in the test README.md file as the
    #  section name. (Optional - default is the method name but better to use a meaningful name here).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Test Model Creation C")

    # You'll need a seed model to test against. 
    # Create an empty model and add surface geometry to the it using the BTAP wizard.
    model = OpenStudio::Model::Model.new
    BTAP::Geometry::Wizards.create_shape_rectangle(model,
                                                   length = 100.0,
                                                   width = 100.0,
                                                   above_ground_storys = 3,
                                                   under_ground_storys = 1,
                                                   floor_to_floor_height = 3.8,
                                                   plenum_height = 1,
                                                   perimeter_zone_depth = 4.57,
                                                   initial_height = 0.0)
    
    # To apply a version of NECB to the geometry first define which 'standard' is being used.
    necb2011_standard = Standard.build('NECB2011')

    # Update constructions in the initial model to match NECB 2011 (the standard created above).
    necb2011_standard.model_clear_and_set_example_constructions(model)

    # While debugging and testing, it is sometimes nice to make a copy of the model as it was.
    before_measure_model = copy_model(model)

    # Save the model to test output directory
    output_path = "#{output_file_path}/test_output-initial_model.osm"
    model.save(output_path, true)
    
    # Apply a weather file to the model. Note any other method in standards can be called too.
    necb2011_standard.model_add_design_days_and_weather_file(model, 'NECB HDD Method', 'CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw')

    # Compare the models and print to screen. Use colour coding to differentiate from other outputs on screen (green=good, yellow=warning, red=error)
    puts "#{BTAP::FileIO.compare_osm_files(before_measure_model, model)}".yellow

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 10.0,
      "a_string_double_argument" => 75.3,
      "a_choice_argument" => "choice_1"
    }

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Check the stored outputs. This requires the output to be defined in the measure.
    output_object = runner.result.stepValues.find {|item| item.name.eql?'name_of_output'}
    value = output_object.valueAsDouble
    assert_in_delta(value.signif(2), 5.2, 0.01, "Error in example checking on an output value") # Use for comparing doubles.

    # In a real measure add tests that are specific to the measure here.
  end

end
