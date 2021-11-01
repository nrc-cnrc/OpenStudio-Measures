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
    # Define the output folder.
    @test_dir = "#{File.dirname(__FILE__)}/output"

    # Create if does not exist. Different logic from outher testing as there are multiple test scripts writing
    # to this folder so it cannot be deleted.
    if !Dir.exists?(@test_dir)
      puts "Creating output folder: #{@test_dir}"
      Dir.mkdir(@test_dir)
    end

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

  def test_NrcAddOverhangsByProjectionFactor_good
    # create an instance of the measure
    measure = NrcAddOverhangsByProjectionFactor.new

    # make an empty model
    model = OpenStudio::Model::Model.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(3, arguments.size)

    # load the test model
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

    # Define the output folder.
    test_dir = "#{File.dirname(__FILE__)}/output"
    if !Dir.exists?(test_dir)
      Dir.mkdir(test_dir)
    end
    NRCMeasureTestHelper.setOutputFolder("#{test_dir}")

    # Run the measure and check if the surfaces were renamed as expected
    runner = run_measure(input_arguments, model)

    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # loop through surfaces finding exterior walls with proper orientation
    sub_surfaces = model.getSubSurfaces
    sub_surfaces.each do |sub_surface|
      next if sub_surface.outsideBoundaryCondition != 'Outdoors'
      next if sub_surface.subSurfaceType == 'Skylight'
      next if sub_surface.subSurfaceType == 'Door'
      next if sub_surface.subSurfaceType == 'GlassDoor'
      next if sub_surface.subSurfaceType == 'OverheadDoor'
      next if sub_surface.subSurfaceType == 'TubularDaylightDome'
      next if sub_surface.subSurfaceType == 'TubularDaylightDiffuser'

      # Check if measure has created overhangs
      shading_groups = model.getShadingSurfaceGroups
      shading_groups.each do |shading_group|
        shading_s = shading_group.shadingSurfaces
        shading_s.each do |shading_surface|
          if shading_surface.name.to_s == "#{sub_surface.name} - Overhang"
            runner.registerInfo("There exists window overhangs named '#{shading_surface.name}'.")
          else
            runner.registerWarning("No overhangs were created.")
          end
        end
      end
    end
    # save the model to test output directory
    output_file_path = "#{@test_dir}/OverHangsOutput.osm"
    puts "  Saving: #{output_file_path}".yellow
    model.save(output_file_path, true)
  end
end
