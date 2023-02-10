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

class NrcPricingMeasure_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCReportingMeasureTestHelper)

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  start_time=Time.now
  if ARGV.length == 1

    # We have a time. It will be in seconds since the epoch. Update our start_time.
    start_time=Time.at(ARGV[0].to_i)
  end
  NRCReportingMeasureTestHelper.removeOldOutputs(before: start_time)
    
  def setup()

    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
        {
            "name" => "Lighting",
            "type" => "Bool",
            "display_name" => "Include interior lighting",
            "default_value" => true,
            "is_required" => true
        }
    ]

    @good_input_arguments = {
        "Lighting" => true
    }

  end

  def test_report()
    puts "Testing report on warehouse model".blue
	
    # Define the output folder for this test. 
    output_file_path = NRCReportingMeasureTestHelper.appendOutputFolder("Warehouse")
	
    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                      building_type: "Warehouse",
                                                      epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
													  sizing_run_dir: NRCReportingMeasureTestHelper.outputFolder)
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
    }
	
    # Create an instance of the measure.
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