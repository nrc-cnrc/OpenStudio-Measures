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
require 'csv'
require 'json'

class NrcReportHourlyGhgEmissions_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCReportingMeasureTestHelper)

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  start_time = Time.now
  if ARGV.length == 1

    # We have a time. It will be in seconds since the epoch. Update our start_time.
    start_time = Time.at(ARGV[0].to_i)
  end
  NRCReportingMeasureTestHelper.removeOldOutputs(before: start_time)

  def setup()

    @use_json_package = false
    @use_string_double = false

    @measure_interface_detailed = [
      {
        "name" => "ng_emissionFactor",
        "type" => "Double",
        "display_name" => "Natural gas emission factor (kg CO2e/kWh)",
        "default_value" => 0.18,
        "max_double_value" => 20.0,
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for std BTAP checking to work.
    @good_input_arguments = {
      "ng_emissionFactor" => 0.18
    }
  end

  def test_report1()
    puts "Testing  model creation for".green + "small office".light_blue
    # Define the output folder for this test (optional - default is the method name).
    test_dir = NRCReportingMeasureTestHelper.appendOutputFolder("test_report/small_office")
    puts "Testing directory: ".green + " #{test_dir}".light_blue

    measure = NrcReportHourlyGhgEmissions.new
    # create an instance of a runner
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    # get arguments
    arguments = measure.arguments()

    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    template = "NECB2017"
    prototype_creator = Standard.build(template)
    model = prototype_creator.model_create_prototype_model(
      template: template,
      epw_file: 'CAN_ON_Toronto.Pearson.Intl.AP.716240_18.epw',
      sizing_run_dir: test_dir,
      debug: @debug,
      building_type: "Warehouse")

    input_arguments = @good_input_arguments

    # Test outputs
    runner = run_measure(input_arguments, model)
)
  end
end
