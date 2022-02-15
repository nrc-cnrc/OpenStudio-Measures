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

class NrcRenameSurfaces_Test < Minitest::Test
  include(NRCMeasureTestHelper)
  include(FindOrientation)

  def setup()
    @use_json_package = false
    @use_string_double = true

    @measure_interface_detailed = [
      {
        "name" => "rename_all_surfaces",
        "type" => "Bool",
        "display_name" => "Rename all surfaces and sub surfaces of the model.",
        "default_value" => true,
        "is_required" => true
      }
    ]
    @good_input_arguments = {
      "rename_all_surfaces" => true
    }
  end

  def test_rename_surfaces

    puts "Testing surfaces renaming".green

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_renameSurfaces")

    # create an instance of the measure
    measure = NrcRenameSurfaces.new

    # make an empty model
    model = OpenStudio::Model::Model.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(1, arguments.size)

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get
    input_arguments = @good_input_arguments

    puts "Test if the surfaces were renamed as expected"
    runner = run_measure(input_arguments, model)
    model.getSurfaces.each do |surface|
      new_name = (surface.name).to_s
      outsideBoundaryCondition = surface.outsideBoundaryCondition
      if (surface.surfaceType.to_s.include? "Wall")
        expected_name = "Wall"
        facade = find_orientation(model, surface)
        if (outsideBoundaryCondition == "Surface")
          next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
          adj_space = surface.adjacentSurface.get.space.get.name.to_s
          expected_name = ("Int" + expected_name + "-" + adj_space).to_s
        elsif (outsideBoundaryCondition == "Outdoors")
          expected_name = "Ext" + expected_name + "-" + facade
        elsif (outsideBoundaryCondition == "Ground")
          expected_name = "BasementWall" + "-" + facade
        end

      elsif (surface.surfaceType.to_s.include? "RoofCeiling")
        outsideBoundaryCondition = surface.outsideBoundaryCondition
        if (outsideBoundaryCondition == "Surface")
          next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
          adj_space = surface.adjacentSurface.get.space.get.name.to_s
          expected_name = "Ceiling" + "-" + adj_space
        elsif (outsideBoundaryCondition == "Outdoors")
          expected_name = "Roof"
        end

      elsif (surface.surfaceType.to_s.include? "Floor")
        if (outsideBoundaryCondition == "Surface")
          next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
          adj_space = surface.adjacentSurface.get.space.get.name.to_s
          expected_name = "Floor" + "-" + adj_space
        elsif (outsideBoundaryCondition == "Ground")
          expected_name = "GroundFloor"
        end
      end
      msg = "Surface name did not change correctly, was supposed to be #{expected_name} but instead got #{new_name} ".red
      assert(new_name.include?(expected_name), msg)

      surface.subSurfaces.each do |subsurf|
        new_subSurface_name = (subsurf.name).to_s
        if (subsurf.subSurfaceType.to_s.include? "Window")
          facade = find_orientation(model, subsurf)
          expected_subSurface_name = "ExtWindow" + "-" + facade
          assert(new_subSurface_name.include? "#{expected_subSurface_name}")
        elsif (subsurf.subSurfaceType.to_s.include? "Skylight")
          expected_subSurface_name = "ExtSkylight"
        end
        msg = "Subsurface name did not change correctly, was supposed to be #{expected_subSurface_name} but instead got #{new_subSurface_name} ".red
        assert(new_subSurface_name.include?(expected_subSurface_name), msg)
      end
    end

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
