# Standard openstudio requires for runnin test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcSetInfiltration_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'] != ""
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  else
    start_time=Time.now
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @measure_interface_detailed = [
      {
        "name" => "flow_rate",
        "type" => "Double",
        "display_name" => 'Space Infiltration Flow per Exterior Envelope Surface Area L/s/m2 at reference pressure',
        "default_value" => 4.2,
        "max_double_value" => 30.0,
        "min_double_value" => 0.05,
        "is_required" => true
      },
      {
        "name" => "reference_pressure",
        "type" => "Double",
        "display_name" => 'Reference pressure',
        "default_value" => 75, # default; NECB 2020
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "flow_exponent",
        "type" => "Double",
        "display_name" => 'Flow exponent',
        "default_value" => 0.60, # default; NECB 2020
        "max_double_value" => 1.0,
        "min_double_value" => 0.4,
        "is_required" => true
      },
      {
        "name" => "total_surface_area",
        "type" => "Double",
        "display_name" => 'Total surface area (m2), please type 0.0 to use value from model',
        "default_value" => 0.0,
        "max_double_value" => 10000000.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "above_grade_wall_surface_area",
        "type" => "Double",
        "display_name" => 'Above grade wall surface area (m2), please type 0.0 to use value from model',
        "default_value" => 0.0,
        "max_double_value" => 10000000.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for std BTAP checking to work
    @good_input_arguments = {
      "flow_rate" => 2.0,
      "reference_pressure" => 75.0,
      "flow_exponent" => 0.6,
      "total_surface_area" => 0.0,
      "above_grade_wall_surface_area" => 0.0
    }
    @no_change_input_arguments = {
      "flow_rate" => 0.25,
      "reference_pressure" => 5.0,
      "flow_exponent" => 0.6,
      "total_surface_area" => 100.0,
      "above_grade_wall_surface_area" => 100.0
    }
  end

  def test_warehouse
    puts "Testing NECB default value".green

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Warehouse Good")

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/Warehouse-NECB2017-ON_Ottawa.osm")

    # Get arguments.
    input_arguments = @good_input_arguments

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that the measure returned 'success'.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Get the calculated infiltration rate for checking.
    output_object = runner.result.stepValues.find {|item| item.name.eql?'calculated_infiltration_rate'}
    rate = output_object.valueAsDouble

    # Loop through all infiltration objects used in the model to test if the measure has successfully set the infiltration rate.
    space_infiltration_objects = model.getSpaceInfiltrationDesignFlowRates
    space_infiltration_objects.each do |space_infiltration_object|
      assert_in_delta(rate.round(6), (space_infiltration_object.flowperExteriorSurfaceArea).to_f.round(6), 0.000001, 'surface infiltration rate')
    end
  end

  def test_warehouse_no_change
    puts "Testing no change values".green

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("WarehouseNoChange")

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/Warehouse-NECB2017-ON_Ottawa.osm")

    # Get arguments.
    input_arguments = @no_change_input_arguments

    # Run the measure and check output.
    runner = run_measure(input_arguments, model)
    result = runner.result
    assert(result.value.valueName == 'Success')

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)

    # Get the calculate infiltration rate for checking.
    output_object = runner.result.stepValues.find {|item| item.name.eql?'calculated_infiltration_rate'}
    rate = output_object.valueAsDouble

    # Loop through all infiltration objects used in the model to test if the measure has successfully set the infiltration rate.
    space_infiltration_objects = model.getSpaceInfiltrationDesignFlowRates
    space_infiltration_objects.each do |space_infiltration_object|
      assert_in_delta(rate.round(6), (space_infiltration_object.flowperExteriorSurfaceArea).to_f.round(6), 0.000001, 'surface infiltration rate')
    end
  end
end
