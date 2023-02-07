# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCReportingMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcReportingMeasure_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCReportingMeasureTestHelper)
  NRCReportingMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'] != ""
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  else
    start_time=Time.now
  end
  NRCReportingMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()

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
            "name" => "an_integer_argument",
            "type" => "Integer",
            "display_name" => "An Integer numeric Argument (integer)",
            "default_value" => 1,
            "max_double_value" => 20,
            "min_double_value" => 0,
            "is_required" => true
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

    # Must have @good_input_arguments defined for std BTAP checking to work.
    @good_input_arguments = {
        "a_string_argument" => "MyString",
        "a_double_argument" => 50.0,
        "an_integer_argument" => 5,
        "a_string_double_argument" => "50.0",
        "a_choice_argument" => "choice_1",
        "a_bool_argument" => true
    }

  end

  def test_report()
    puts "Testing report on small Office model".blue
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
    }

    # Define the output folder for this test. Set a local var for use later.
    output_folder = NRCReportingMeasureTestHelper.appendOutputFolder("smallOffice", input_arguments)
	
    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/SmallOffice.osm")

    # Assign the local weather file (have to provide a full path to EpwFile).
    epw = OpenStudio::EpwFile.new("#{File.dirname(__FILE__)}/weather_files/CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw")
    OpenStudio::Model::WeatherFile::setWeatherFile(model, epw)

    # Create an instance of the measure
	runner = run_measure(input_arguments, model)
	
	# Rename output file.
    #output_file = "report_no_diffs.html"
    #File.rename("#{output_folder}/report.html", "#{output_folder}/#{output_file}")

    # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
	#regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
	#IO.write("#{output_folder}/#{output_file}.reg", regression_file)
	#diffs = FileUtils.compare_file("#{output_folder}/#{output_file}","#{output_folder}/#{output_file}.reg")
	#assert(diffs, "There were differences to the regression files:\n")
  end
end
