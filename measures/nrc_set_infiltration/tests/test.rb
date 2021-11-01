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
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  # Define the output folder.
  @@test_dir = "#{File.dirname(__FILE__)}/output"
  # Remove if existing found. This should only be done once.
  if Dir.exists?(@@test_dir)
    FileUtils.rm_rf(@@test_dir)
  end
  Dir.mkdir(@@test_dir)

  def setup()
    @measure_interface_detailed = [
      {
        "name" => "flow_rate_75Pa",
        "type" => "Double",
        "display_name" => 'Space Infiltration Flow per Exterior Envelope Surface Area L/s/m2 at 75 Pa',
        "default_value" => 4.2,
        "is_required" => true
      },
      {
        "name" => "flow_exponent",
        "type" => "Double",
        "display_name" => 'Flow exponent',
        "default_value" => 0.6, # default; NECB 2020
        "is_required" => true
      },
      {
        "name" => "total_surface_area",
        "type" => "Double",
        "display_name" => 'Total surface area (m2), please type 0.0 to use value from model',
        "default_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "above_grade_wall_surface_area",
        "type" => "Double",
        "display_name" => 'Above grade wall surface area (m2), please type 0.0 to use value from model',
        "default_value" => 0.0,
        "is_required" => true
      }
    ]
    @good_input_arguments = {
      "flow_rate_75Pa" => 4.2,
      "flow_exponent" => 0.06,
      "total_surface_area" => 0.0,
      "above_grade_wall_surface_area" => 0.0
    }
  end

  def test_office
  
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}")
    # create an instance of the measure
    measure = NrcSetInfiltration.new
    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/resources/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    input_arguments = {
      "flow_rate_75Pa" => 4.2,
      "flow_exponent" => 0.60,
      "total_surface_area" => 6000.0,
      "above_grade_wall_surface_area" => 0.0
    }

    # Define the output folder for this test.
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}/infiltration")

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    #loop through all infiltration objects used in the model to test if the measure has successfully set the infiltration rate
    space_infiltration_objects = model.getSpaceInfiltrationDesignFlowRates
    space_infiltration_objects.each do |space_infiltration_object|
      assert_equal($infiltration_5Pa.to_f.round(6), (space_infiltration_object.flowperExteriorSurfaceArea).to_f.round(6))
    end

    # save the model to test output directory
    output_file_path = "#{NRCMeasureTestHelper.outputFolder}/test_output.osm"
    model.save(output_file_path, true)
  end
  
end
