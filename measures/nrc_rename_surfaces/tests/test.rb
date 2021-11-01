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

  def test_number_of_arguments_and_argument_names
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

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "rename_all_surfaces" => true
    }

    # Define the output folder.
    test_dir = "#{File.dirname(__FILE__)}/output"
    if !Dir.exists?(test_dir)
      Dir.mkdir(test_dir)
    end
    NRCMeasureTestHelper.setOutputFolder("#{test_dir}")

    # Run the measure and check if the surfaces were renamed as expected
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
          assert(new_name.include? "#{expected_name}")
        elsif (outsideBoundaryCondition == "Outdoors")
          expected_name = "Ext" + expected_name + "-" + facade
          assert(new_name.include? "#{expected_name}")
        elsif (outsideBoundaryCondition == "Ground")
          expected_name = "BasementWall" + "-" + facade
          assert(new_name.include? "#{expected_name}")
        end

      elsif (surface.surfaceType.to_s.include? "RoofCeiling")
        outsideBoundaryCondition = surface.outsideBoundaryCondition
        if (outsideBoundaryCondition == "Surface")
          next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
          adj_space = surface.adjacentSurface.get.space.get.name.to_s
          expected_name = "Ceiling" + "-" + adj_space
          assert(new_name.include? "#{expected_name}")
        elsif (outsideBoundaryCondition == "Outdoors")
          expected_name = "Roof"
          assert(new_name.include? "#{expected_name}")
        end

      elsif (surface.surfaceType.to_s.include? "Floor")
        if (outsideBoundaryCondition == "Surface")
          next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
          adj_space = surface.adjacentSurface.get.space.get.name.to_s
          expected_name = "Floor" + "-" + adj_space
          assert(new_name.include? "#{expected_name}")
        elsif (outsideBoundaryCondition == "Ground")
          expected_name = "GroundFloor"
          assert(new_name.include? "#{expected_name}")
        end
      end

      surface.subSurfaces.each do |subsurf|
        new_subSurface_name = (subsurf.name).to_s
        if (subsurf.subSurfaceType.to_s.include? "Window")
          facade = find_orientation(model, subsurf)
          expected_subSurface_name = "ExtWindow" + "-" + facade
          assert(new_subSurface_name.include? "#{expected_subSurface_name}")
        elsif (subsurf.subSurfaceType.to_s.include? "Skylight")
          expected_subSurface_name = "ExtSkylight"
          assert(new_subSurface_name.include? "#{expected_subSurface_name}")
        end
      end
    end

    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

  end
end
