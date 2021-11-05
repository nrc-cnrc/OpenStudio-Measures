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

class NrcReportUtilityCosts_Test < Minitest::Test

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
            "name" => "calc_choice",
            "type" => "Choice",
            "display_name" => "Utility cost choice",
            "default_value" => "Use rates below",
            "choices" => ["Use rates below", "Nova Scotia rates 2021"],
            "is_required" => true
        },
        {
            "name" => "electricity_cost",
            "type" => "Double",
            "display_name" => "Electricity rate ($/kWh)",
            "default_value" => 0.10,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => false
        },
        {
            "name" => "gas_cost",
            "type" => "Double",
            "display_name" => "Natural gas rate ($/m3)",
            "default_value" => 0.20,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => false
        }
    ]

    @good_input_arguments = {
        "calc_choice" => "Nova Scotia rates 2021",
        "electricity_cost" => 20.0,
        "gas_cost" => 30.0,
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
    input_arguments = @good_input_arguments
	#{
    #}
    
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
