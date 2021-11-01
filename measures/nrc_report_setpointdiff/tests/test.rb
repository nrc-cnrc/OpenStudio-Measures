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

  def test_report()
    puts "Testing report on warehouse model"

    # create an instance of the measure
    measure = NrcReportSetPointDiff.new

    # create an instance of a runner
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    # get arguments
    arguments = measure.arguments()
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    timeStep = arguments[0].clone
    argument_map['timeStep'] = timeStep

    detail = arguments[1].clone
    argument_map['detail'] = detail

    # Define the output folder.
    test_dir = "#{File.dirname(__FILE__)}/output"
    if !Dir.exists?(test_dir)
      Dir.mkdir(test_dir)
    end
    NRCReportingMeasureTestHelper.setOutputFolder("#{test_dir}")

    ################### Create warehouse
    template = 'NECB2017'
    prototype_creator = Standard.build(template)

    model = prototype_creator.model_create_prototype_model(
      template: 'NECB2017',
      epw_file: 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw',
      sizing_run_dir: test_dir,
      debug: @debug,
      building_type: 'Warehouse')

    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
      "timeStep" => "Hourly",
      "detail" => "No"
    }

    # Create an instance of the measure
    run_measure(input_arguments, model)
  end
end
