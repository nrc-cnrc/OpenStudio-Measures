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

class NrcNewSpacetypeLPDList_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'].nil?
    start_time=Time.now
  else
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @measure_interface_detailed = [
        {
            "name" => "skip",
            "type" => "Double",
            "display_name" => "skip?",
            "default_value" => 1.0,
            "max_double_value" => 9999,
            "min_double_value" => 0.0,
            "is_required" => false
        }]
    @good_input_arguments = {
        "skip" => 1.0
    }
  end

  def test_argument_values
    # create an instance of the measure
    measure = NrcNewSpacetypeLPDList.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # Set arguments.
    input_arguments = {
        "skip" => 1.0
    }

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder", input_arguments)

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    lpd_hash = {}
    lpd_hash['Space Function Warehouse storage area medium to bulky palletized items'] = 3.6
    lpd_hash['Space Function Warehouse storage area small hand-carried items(4)'] = 7.4
    lpd_hash['Space Function Office enclosed <= 25 m2'] = 8.0
    #check lpd

    model.getSpaceTypes.each do |space_type|
      if space_type.lightingPowerPerFloorArea.is_initialized
        lpd = space_type.lightingPowerPerFloorArea.get
        name = space_type.name.to_s
        real_lpd = lpd_hash[name]
        assert((real_lpd - lpd) < 0.001)
      end
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
