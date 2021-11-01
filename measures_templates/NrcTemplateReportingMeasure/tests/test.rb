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

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCReportingMeasureTestHelper)
  
  # Define the output folder.
  @@test_dir = "#{File.expand_path(__dir__)}/output"
  # Remove if existing found. This should only be done once.
  if Dir.exists?(@@test_dir)
    FileUtils.rm_rf(@@test_dir)
	sleep 10
  end
  Dir.mkdir(@@test_dir)
  
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
	
    # Define the output folder for this test. 
    NRCReportingMeasureTestHelper.setOutputFolder("#{@@test_dir}/smallOffice")
    Dir.mkdir(NRCReportingMeasureTestHelper.outputFolder) unless Dir.exists?(NRCReportingMeasureTestHelper.outputFolder)
	
    # Load osm file
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model_file = "#{File.dirname(__FILE__)}/SmallOffice.osm"
    model = translator.loadModel(model_file)
    msg = "Loading model: #{model_file}"
    assert(!model.empty?, msg)
    model = model.get

    # Assign the local weather file (have to provide a full path to EpwFile).
    epw = OpenStudio::EpwFile.new("#{File.dirname(__FILE__)}/weather_files/CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw")
    OpenStudio::Model::WeatherFile::setWeatherFile(model, epw)
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
    }
    
    # Create an instance of the measure
	runner = run_measure(input_arguments, model)
	
	# Rename output file.
    #output_file = "report_no_diffs.html"
    #File.rename("#{NRCReportingMeasureTestHelper.outputFolder}/report.html", "#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}")

    # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
	#regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
	#IO.write("#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}.reg", regression_file)
	#diffs = FileUtils.compare_file("#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}","#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}.reg")
	#assert(diffs, "There were differences to the regression files:\n")
  end
end
