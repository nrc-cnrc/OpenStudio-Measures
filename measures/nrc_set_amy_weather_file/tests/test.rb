# Standard openstudio requires for running test.
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper.
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcSetAmyWeatherFile_Test < Minitest::Test

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

    location_choice = OpenStudio::StringVector.new
    location_choice << 'ON_Ottawa'
    location_choice << 'ON_Toronto'
    location_choice << 'ON_Windsor'
    
    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "ON_Toronto",
        "choices" => location_choice,
        "is_required" => true
      },
      {
        "name" => "year",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "2016",
        "choices" => ["2016", "2017", "2018"],
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for standard BTAP checking to work.
    @good_input_arguments = {
      "location" => "ON_Ottawa",
      "year" => "2017"
    }
  end

  def test_weather_file()
    puts "Testing setting weather file".green

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = @good_input_arguments

    # Define the output folder for this test. This is used as the folder name and in the test README.md file as the
    #  section name. The arguments are used to store the path in a hash for when we have multiple test methods in a class.
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("WeatherFile", input_arguments)

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "SmallOffice",
                                                  epw_file: "CAN_AB_Edmonton-CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Measure specific tests.
    expected_location=input_arguments["location"]
    expected_year=input_arguments["year"]
    weatherFile=model.getWeatherFile.url.get
    assert((weatherFile.include? expected_location), "Weather file does not match expected location.")
    assert((weatherFile.include? expected_year), "Weather file does not match expected year.")

    model_year = model.getYearDescription.calendarYear.get
    assert_equal(expected_year.to_i, model_year.to_i, "Model year does not match expected weather year.")
  end

end
