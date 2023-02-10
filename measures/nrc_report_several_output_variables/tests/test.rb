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

# Core functionality for the tests. Individual test files speed up the testing.
module TestCommon

  class NrcReportSeveralOutputVariables_Test < Minitest::Test
    include(NRCReportingMeasureTestHelper)

    def setup()
      @use_json_package = false
      @use_string_double = true
      @measure_interface_detailed = [
        {
          "name" => "reporting_frequency",
          "type" => "Choice",
          "display_name" => "Reporting Frequency",
          "default_value" => "Hourly",
          "choices" => ["Hourly", "Timestep"],
          "is_required" => true
        },
        {
          "name" => "output_variables",
          "type" => "String",
          "display_name" => "Please Enter the Output Variables in the format 'OutputVariable1 : Key Name1,OutputVariable2 : Key Name2,OutputVariable3 : Key Name3'   ",
          "default_value" => "Heating Coil Heating Rate:*,Baseboard Total Heating Rate:*",
          "is_required" => true
        }
      ]
    end

    def test_report()
      building_types = ['Warehouse']
      epw_files = ['CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw']
      building_types.each do |building_type|
        epw_files.each do |epw_file|
          city = epw_file.split('.')[0]
          if city.include? '-'
            city = city.split('-')[0]
          end
          if city.include? ' '
            city = city.split(' ')[0]
          end
          if city.include? '='
            city = city.split('=')[0]
          end

          puts "Testing  model creation for".green + " #{building_type} and #{city} ".light_blue
          # Define the output folder for this test (optional - default is the method name).
          test_dir = NRCReportingMeasureTestHelper.appendOutputFolder("test_report/#{city}_#{building_type}")
          puts "Testing directory: ".green + " #{test_dir}".light_blue
          # create an instance of the measure
          measure = NrcReportSeveralOutputVariables.new
          # create an instance of a runner
          runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

          # get arguments
          arguments = measure.arguments()

          argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

          template = "NECB2017"
          prototype_creator = Standard.build(template)
          model = prototype_creator.model_create_prototype_model(
            template: template,
            epw_file: epw_file,
            sizing_run_dir: test_dir,
            debug: @debug,
            building_type: building_type)

          # Set input args. In this case the std matches the one used to create the test model.
          input_arguments = {
            "reporting_frequency" => "Hourly",
            "output_variables" => "System Node Standard Density Volume Flow Rate:Node 5, System Node Standard Density Volume Flow Rate:Node 21, Water Heater Heating Rate:*, Water Heater Water Volume Flow Rate:*"
          }

          # Create an instance of the measure
          run_measure(input_arguments, model)
        end
      end
    end
  end
end