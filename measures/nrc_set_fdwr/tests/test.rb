# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcSetFdwr_Test < Minitest::Test
  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  start_time=Time.now
  if ARGV.length == 1

    # We have a time. It will be in seconds since the epoch. Update our start_time.
    start_time=Time.at(ARGV[0].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)

  def setup()
    @measure_interface_detailed = [
      {
        "name" => "fdwr_options",
        "type" => "Choice",
        "display_name" => "Select an option for FDWR",
        "default_value" => "Set specific FDWR",
        "choices" => ["Remove the windows", "Set windows to match max FDWR from NECB", "Don't change windows", "Reduce existing window size to meet maximum NECB FDWR limit", "Set specific FDWR"],
        "is_required" => true
      },
      {
        "name" => "fdwr",
        "type" => "Double",
        "display_name" => 'Set specific FDWR (if option is selected above). Please enter a number greater than or equal to 0.0 and less than 1.0',
        "default_value" => 0.4,
        "is_required" => false
      }
    ]
  end

  # Loop through all input arguments to test all possibilities
  def test_inputArguments
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/resources/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    initial_fdwr = 0.0
    #loop through all surfaces used in the model to get the initial fdwr before running the measure
    model.getSpaces.sort.each do |space|
      space.surfaces.sort.each do |surface|
        if surface.outsideBoundaryCondition == 'Outdoors' and surface.surfaceType == "Wall"
          initial_fdwr = surface.windowToWallRatio.round(3)
        end
      end
    end

    standard = Standard.build("NECB2017")
    all_fdwr_options = ["Remove the windows", "Set windows to match max FDWR from NECB", "Don't change windows", "Reduce existing window size to meet maximum NECB FDWR limit", "Set specific FDWR"]
    all_fdwr_options.each do |fdwr_options|

      puts "################# Testing #{fdwr_options} #################".green

      # get arguments
      input_arguments = {
        "fdwr_options" => fdwr_options,
        "fdwr" => 0.6
      }
      fdwr = input_arguments['fdwr']
      fdwr_options = input_arguments['fdwr_options']
      fdwr_options_noSpaces = fdwr_options.gsub(/[[:space:]]/, '_') # Replace spaces by '_'
      hdd = standard.get_necb_hdd18(model)

      # Define the output folder for this test (optional - default is the method name).
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{fdwr_options_noSpaces}")

      # Set argument values to good values and run the measure on model with spaces
      runner = run_measure(input_arguments, model)
      result = runner.result
      assert(result.value.valueName == 'Success')

      if (fdwr_options == "Remove the windows")
        expected_fdwr = 0.0
      elsif (fdwr_options == "Set windows to match max FDWR from NECB")
        expected_fdwr = eval(standard.get_standards_formula('fdwr_formula'))
        standard.apply_max_fdwr_nrcan(model: model, fdwr_lim: expected_fdwr.to_f)
      elsif (fdwr_options == "Don't change windows")
        expected_fdwr = initial_fdwr
      elsif (fdwr_options == "Reduce existing window size to meet maximum NECB FDWR limit")
        expected_fdwr = eval(standard.get_standards_formula('fdwr_formula'))
        fdwr_limit = expected_fdwr * 100
        standard.apply_limit_fdwr(model: model, fdwr_lim: fdwr_limit.to_f)
      elsif (fdwr_options == "Set specific FDWR")
        expected_fdwr = fdwr
      end

      fdwr_calculated = calculateFDWR(model)
      assert_equal(fdwr_calculated.round(3), expected_fdwr.round(3), "Fenestration did not change correctly")
      puts "fdwr #{fdwr_calculated.round(3)}; expected fdwr #{expected_fdwr.round(3)}".yellow
      # test if the measure would grab the correct number and value of input argument.
      assert_equal(2, input_arguments.size)

      # Save the model to test output directory.
      output_path = "#{output_file_path}/test_output.osm"
      model.save(output_path, true)
    end
  end

  def calculateFDWR(model)
    # This method will loop through all subsurfaces and calculate the fdwr
    window_area_total = 0.0
    model.getBuilding.exteriorWalls.each do |surface|
      surface.subSurfaces.each do |subsurf|
        area = subsurf.netArea
        window_area_total += area
      end
    end
    fdwr_calculated = window_area_total / (model.getBuilding.exteriorWallArea)
    return fdwr_calculated
  end

end
