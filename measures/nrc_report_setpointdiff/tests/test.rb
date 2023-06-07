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

class NrcReportSetPointDiff_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCReportingMeasureTestHelper)
  NRCReportingMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'].nil?
    start_time=Time.now
  else
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  end
  NRCReportingMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "timeStep",
        "type" => "Choice",
        "display_name" => "Time Step",
        "default_value" => "Hourly",
        "choices" => ["Hourly", "Daily", "Zone Timestep"],
        "is_required" => true
      },
      {
        "name" => "detail",
        "type" => "Choice",
        "display_name" => "Create detailed hourly Excel files?",
        "default_value" => "Yes",
        "choices" => ["Yes", "No"],
        "is_required" => true
      }
    ]
    possible_sections.each do |method_name|
      @measure_interface_detailed << {
        "name" => method_name,
        "type" => "Bool",
        "display_name" => "OsLib_Reporting.#{method_name}(nil,nil,nil,true)[:title]",
        "default_value" => true,
        "is_required" => true
      }
    end
  end

  def possible_sections
    result = []
    # methods for sections in order that they will appear in report
    result << 'model_summary_section'
    result << 'temperature_detailed_section'
    result << 'temp_diff_summary_section'
    result
  end

  def test_report()
    puts "Testing report on warehouse model".green

    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
      "timeStep" => "Hourly",
      "detail" => "No"
    }

    # Define the output folder for this test.
    test_dir = NRCReportingMeasureTestHelper.appendOutputFolder("test_report", input_arguments)

    # Create warehouse.
    template = 'NECB2017'
    prototype_creator = Standard.build(template)

    model = prototype_creator.model_create_prototype_model(
      template: 'NECB2017',
      epw_file: 'CAN_ON_Ottawa-CWEC2016.epw',
      sizing_run_dir: test_dir,
      building_type: 'Warehouse')

    # Create an instance of the measure, run the measure and check for success.
	runner = run_measure(input_arguments, model)
	
	# Check output values.
  end
end
