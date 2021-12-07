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

class NrcAddOverhangsByProjectionFactor_Test < Minitest::Test
  include(NRCMeasureTestHelper)

  def setup()
    @use_json_package = false
    @use_string_double = false

    @measure_interface_detailed = [
      {
        "name" => "facade",
        "type" => "Choice",
        "display_name" => "Cardinal Direction",
        "default_value" => "South",
        "choices" => ["North", "East", "South", "West"],
        "is_required" => true
      },
      {
        "name" => "projection_factor",
        "type" => "Double",
        "display_name" => "Projection Factor.",
        "default_value" => 0.5,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "remove_ext_space_shading",
        "type" => "Bool",
        "display_name" => "Remove Existing Space Shading Surfaces From the Model.",
        "default_value" => false,
        "is_required" => true
      }
    ]
    @good_input_arguments = {
      "facade" => "South",
      "projection_factor" => 0.5,
      "remove_ext_space_shading" => false
    }
  end

  def checkFacade(absoluteAzimuth)
    until absoluteAzimuth < 360.0
      absoluteAzimuth = absoluteAzimuth - 360.0
    end
    if (absoluteAzimuth >= 315.0 || absoluteAzimuth < 45.0)
      facade = "North"
    elsif (absoluteAzimuth >= 45.0 && absoluteAzimuth < 135.0)
      facade = "East"
    elsif (absoluteAzimuth >= 135.0 && absoluteAzimuth < 225.0)
      facade = "South"
    elsif (absoluteAzimuth >= 225.0 && absoluteAzimuth < 315.0)
      facade = "West"
    end
    return facade
  end

  def test_NrcAddOverhangsByProjectionFactor
    puts "Testing Add Overhangs By Projection Factor".green

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_AddOverhangsByProjectionFactor")

    # Create an instance of the measure
    measure = NrcAddOverhangsByProjectionFactor.new

    # Make an empty model
    model = OpenStudio::Model::Model.new

    # Get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(3, arguments.size)

    # Load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    input_arguments = {
      "facade" => "South",
      "projection_factor" => 0.5,
      "remove_ext_space_shading" => false
    }
    facade = input_arguments['facade']

    # Run the measure
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)

    num_overHangsCreated = 0

    # Loop through surfaces finding exterior walls with proper orientation
    sub_surfaces = model.getSubSurfaces
    sub_surfaces.each do |sub_surface|
      absoluteAzimuth = OpenStudio::convert(sub_surface.azimuth, "rad", "deg").get + sub_surface.space.get.directionofRelativeNorth + model.getBuilding.northAxis
      next if sub_surface.outsideBoundaryCondition != 'Outdoors'
      if sub_surface.name.to_s.include? "Window"
        # Check if measure has created overhangs
        shading_groups = model.getShadingSurfaceGroups
        shading_groups.each do |shading_group|
          shading_s = shading_group.shadingSurfaces
          shading_s.each do |shading_surface|
            if shading_surface.name.to_s == "#{sub_surface.name} - Overhang"
              # The 'checkFacade' function returns the facade of subsurface that the measure created an overhang to
              testFacade = checkFacade(absoluteAzimuth)
              #Test if overhangs are created in correct facade selected by user
              assert(testFacade == facade)
              num_overHangsCreated += 1
            end
          end
        end
      end
    end

    # Test that there are overhangs created by the measure
    assert(num_overHangsCreated > 0)
    puts "There are".green + " #{num_overHangsCreated}".light_blue + " over hangs created.".green

    # Save the model to test output directory
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
    puts "Runner output #{show_output(runner.result)}".green
    assert(runner.result.value.valueName == 'Success')
  end
end
