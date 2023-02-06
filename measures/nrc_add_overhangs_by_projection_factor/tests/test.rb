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

    # Create an instance of the measure
    measure = NrcAddOverhangsByProjectionFactor.new

    # Make an empty model
    model = OpenStudio::Model::Model.new

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
    projection_factor = input_arguments['projection_factor']

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_AddOverhangsByProjectionFactor", input_arguments)

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

        # Check if measure has created overhangs with the correct projection factor
        # The overhang depth = Height of window * projection factor
        # Inorder to test if the measure has set the projection factor correctly:
        # 1- The overhang depth will be calculated by calculating the difference between maximum and minimum y vertices
        # 2- The window height will be calculated by calculating the difference between maximum and minimum z vertices
        # 3- The calculated projection factor = overhang depth / window height should be same as projection factor given by user.
        puts "Testing if the measure has set the projection factor correctly for ".green + "#{sub_surface.name}".light_blue
        shading_groups = model.getShadingSurfaceGroups
        shading_groups.each do |shading_group|
          shading_s = shading_group.shadingSurfaces
          shading_s.each do |shading_surface|
            if shading_surface.name.to_s == "#{sub_surface.name} - Overhang"
              # 1- Find the min and max y values to calculate the overhang depth
              min_y_val = 999
              max_y_val = -999
              shading_surface_vertices = shading_surface.vertices
              shading_surface_vertices.each do |vertex|
                # Min y value
                if vertex.y < min_y_val
                  min_y_val = vertex.y
                end
                # Max y value
                if vertex.y > max_y_val
                  max_y_val = vertex.y
                end
              end

              # Calculate the depth of shading_surface
              shading_surface_depth = max_y_val - min_y_val
              puts "Shading surface depth is  ".green + "#{shading_surface_depth}".light_blue

              # 2- Find the min and max z values to calculate the height of the window
              min_z_val = 999
              max_z_val = -999
              allVertices = sub_surface.vertices
              allVertices.each do |vertex|
                # Min z value
                if vertex.z < min_z_val
                  min_z_val = vertex.z
                end
                # Max z value
                if vertex.z > max_z_val
                  max_z_val = vertex.z
                end
              end

              # Calculate the window height
              window_height = max_z_val - min_z_val
              puts "The height of widow is ".green + " #{window_height}".light_blue

              # 3- Calculated projection factor = overhang depth / window height
              calculated_projection_factor = shading_surface_depth / window_height

              # Assert that the calculated projection factor = overhang depth / window height are same as projection factor given by user.
              msg = "The projection factor was supposed to be equal #{projection_factor} but instead got #{calculated_projection_factor}".red
              assert_equal(projection_factor.round(2), calculated_projection_factor.round(2), msg)

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
