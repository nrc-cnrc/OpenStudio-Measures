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

class NrcResizeExistingWindowsToMatchAGivenWWR_Test < Minitest::Test

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
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "remove_skylight",
        "type" => "Bool",
        "display_name" => "Remove skylights?",
        "default_value" => false,
        "is_required" => true
      },
      {
        "name" => "cz_4_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 4 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_5_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 5 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_6_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 6 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_7A_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 7A FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_7B_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 7B FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_8_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 8 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "check_wall",
        "type" => "Bool",
        "display_name" => "Only affect surfaces that are 'walls'?",
        "default_value" => false,
        "is_required" => false
      },
      {
        "name" => "check_outdoors",
        "type" => "Bool",
        "display_name" => 'Only affect surfaces that have boundary condition = "Outdoor"?',
        "default_value" => true,
        "is_required" => false
      },
      {
        "name" => "check_sunexposed",
        "type" => "Bool",
        "display_name" => 'Only affect surfaces that are "SunExposed"?',
        "default_value" => true,
        "is_required" => false
      }
    ]
    @good_input_arguments = {
      "remove_skylight" => true,
      "cz_4_fdwr" => 0.2,
      "cz_5_fdwr" => 0.2,
      "cz_6_fdwr" => 0.2,
      "cz_7A_fdwr" => 0.2,
      "cz_7B_fdwr" => 0.2,
      "cz_8_fdwr" => 0.2,
      "check_wall" => true,
      "check_outdoors" => true,
      "check_sunexposed" => true
    }
  end

  def test_argument_values
    puts "Testing window resizing".green

    # Set arguments.
    input_arguments = {
      "remove_skylight" => false,
      "cz_4_fdwr" => 0.2,
      "cz_5_fdwr" => 0.2,
      "cz_6_fdwr" => 0.2,
      "cz_7A_fdwr" => 0.2,
      "cz_7B_fdwr" => 0.2,
      "cz_8_fdwr" => 0.2,
      "check_wall" => true,
      "check_outdoors" => true,
      "check_sunexposed" => true
    }

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_windowResizing", input_arguments)

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # Run the measure and check output
    runner = run_measure(input_arguments, model)

    # Test if the measure has set the correct WWR
    # counters
    total_gross_ext_wall_area = 0
    total_ext_window_area = 0
    spaces = model.getSpaces
    spaces.each do |space|

      #get surface area adjusting for zone multiplier
      zone = space.thermalZone
      if not zone.empty?
        zone_multiplier = zone.get.multiplier
        if zone_multiplier > 1
        end
      else
        zone_multiplier = 1 #space is not in a thermal zone
      end

      puts "Testing space ".green + "#{space.name.get}".light_blue

      space.surfaces.each do |surface|
        next if not surface.surfaceType == "Wall"
        next if not surface.outsideBoundaryCondition == "Outdoors"
        # Surface has to be Sun Exposed!
        next if not surface.sunExposure == "SunExposed"

        puts "Surface name : ".green + "#{surface.name.get}".light_blue + " Surface Type : " + "#{surface.surfaceType}".light_blue + " Outside Boundary Condition: ".green + "#{surface.outsideBoundaryCondition}".light_blue + " Sun Exposure: ".green + "#{surface.sunExposure}"

        surface_gross_area = surface.grossArea * zone_multiplier

        #loop through sub surfaces and add area including multiplier
        ext_window_area = 0
        surface.subSurfaces.each do |subSurface|
          ext_window_area = ext_window_area + subSurface.grossArea * subSurface.multiplier * zone_multiplier
        end

        total_gross_ext_wall_area += surface_gross_area
        total_ext_window_area += ext_window_area
      end #end of surfaces.each do
    end # end of space.each do
    wwr_result = total_ext_window_area / total_gross_ext_wall_area

    puts " Testing if the measure has set the WWR to".green + " #{input_arguments['cz_6_fdwr']}".light_blue
    msg = "The measure failed to set the WWR to #{input_arguments['cz_6_fdwr']}, instead the WWR is #{wwr_result}".red
    assert(wwr_result.round(2) == input_arguments['cz_6_fdwr'].round(2), msg)

    # report final condition of model
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
    puts "Runner output #{show_output(runner.result)}".green
    assert(runner.result.value.valueName == 'Success')
  end
end
