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
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = @good_input_arguments

    # Define the output folder for this test. 
    NRCReportingMeasureTestHelper.appendOutputFolder("smallOffice", input_arguments)
	
    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/SmallOffice.osm")

    # Assign weather file 
    standard = Standard.build("NECB2017")
    standard.model_add_design_days_and_weather_file(model, 'NECB HDD Method', 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw')

    # Create an instance of the measure, run the measure and check for success.
	  runner = run_measure(input_arguments, model)
	
    # Check output values.
    outputs = runner.result.stepValues
    outputs.each do |output|
      puts "Checking output #{output.name}".light_blue
      if input_arguments.key?(output.name) then
        puts "Skipping input argument #{output.name}" # all the inputs are in the outputs so just skip these.
      elsif output.name == 'total_site_energy'
          assert_in_delta(65440, output.valueAsDouble, 1.0, 'Total site energy')
      elsif output.name == 'total_site_energy_normalized'
          assert_in_delta(128, output.valueAsDouble, 0.1, 'Total site energy normalized')
      elsif output.name == 'annual_electricity_use'
          assert_in_delta(48000, output.valueAsDouble, 1.0, 'Annual electricity use')
      elsif output.name == 'annual_natural_gas_use'
          assert_in_delta(62.7, output.valueAsDouble, 0.001, 'Annual natural gas use')
      elsif output.name == 'annual_electricity_cost'
          assert_in_delta(6592.93, output.valueAsDouble, 0.001, 'Annual electricity cost')
      elsif output.name == 'annual_natural_gas_cost'
          assert_in_delta(1279.27, output.valueAsDouble, 0.001, 'Annual natural gas cost')
      else
        assert(false, "Could not find output #{output.name}")
      end
    end

  end
end
