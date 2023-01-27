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
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => false
      }
    ]

    # Must have @good_input_arguments defined for std BTAP checking to work.
    @good_input_arguments = {
      "fdwr_options" => "Set specific FDWR",
      "fdwr" => 0.3
    }
  end

  # Loop through all input arguments to test all possibilities.
  def test_inputArguments

    # Load osm file.
    model = load_test_osm("#{File.dirname(__FILE__)}/resources/Warehouse-NECB2017-ON_Ottawa.osm")

    initial_fdwr = 0.0
    # Loop through all surfaces used in the model to get the initial fdwr before running the measure.
    model.getSpaces.sort.each do |space|
      space.surfaces.sort.each do |surface|
        if surface.outsideBoundaryCondition == 'Outdoors' and surface.surfaceType == "Wall"
          initial_fdwr = surface.windowToWallRatio.round(3)
        end
      end
    end

    # Test using NECB 2017.
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

      # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
      runner = run_measure(input_arguments, model)

      # Check that it ran successfully.
      assert(runner.result.value.valueName == 'Success', "Error in running measure.")

      # Get expected FDWR for checking.
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
      assert_in_delta(fdwr_calculated.round(3), expected_fdwr.round(3), 0.001, "Expected FDWR.")
      puts "fdwr #{fdwr_calculated.round(3)}; expected fdwr #{expected_fdwr.round(3)}".yellow
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
