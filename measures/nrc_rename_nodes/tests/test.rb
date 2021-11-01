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

class NrcRenameNodes_Test < Minitest::Test
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
        "name" => "rename_nodes",
        "type" => "Bool",
        "display_name" => "Rename nodes of the supply side of plant loops and air loops.",
        "default_value" => true,
        "is_required" => true
      }
    ]
    @good_input_arguments = {
      "rename_nodes" => true
    }
  end

  def test_number_of_arguments_and_argument_names

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/resources/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # create an instance of the measure
    measure = NrcRenameNodes.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(1, arguments.size)

    # Define the output folder for this test.
    NRCMeasureTestHelper.setOutputFolder("#{@@test_dir}")

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
      "rename_nodes" => true
    }

    # Run the measure and check if the nodes were renamed as expected
    runner = run_measure(input_arguments, model)
	
    # Check whether the names of nodes of the supply side in plant loops have been changed correctly
    model.getPlantLoops.sort.each do |plant_loop|
      plant_loop.supplyComponents.each do |component|
        plant_loop_name = plant_loop.name.get
        next unless component.to_Node.is_initialized
        node = component.to_Node.get
        if node == plant_loop.supplyInletNode
          expected_name = "#{plant_loop_name}-Return_node"
          name = component.name()
        elsif node == plant_loop.supplyOutletNode
          expected_name = "#{plant_loop_name}-Supply_node"
          name = component.name()
        elsif node.inletModelObject.is_initialized
          component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
          expected_name = "#{plant_loop_name.to_s}-Supply-#{component1.to_s}-Leaving_node"
          name = component.name()
        end
        assert(name.to_s.include?(expected_name.to_s), "Plant loop node names did not change correctly")
      end
    end

    # Check whether the names of outdoor nodes of the air loops have been changed correctly
    model.getAirLoopHVACs.sort.each do |air_loop|
      outdoorAirSystem = air_loop.airLoopHVACOutdoorAirSystem
      outdoorAirSystem_name = outdoorAirSystem.get.name
      unless outdoorAirSystem.empty?
        outdoorAirSystem = outdoorAirSystem.get
        outdoorAirComponents = outdoorAirSystem.oaComponents
        outdoorAirComponents.each do |outdoorAirComponent|
          next unless outdoorAirComponent.to_Node.is_initialized
          node = outdoorAirComponent.to_Node.get
          if node.inletModelObject.is_initialized
            component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
            expected_name = "#{outdoorAirSystem_name}-Supply-#{component1.to_s}-Leaving_node"
            name = outdoorAirComponent.name()
            assert(name.to_s.include?(expected_name.to_s), "Air Loop HVAC Outdoor Air System node names did not change correctly")
          end
        end

        reliefComponents = outdoorAirSystem.reliefComponents
        reliefComponents.each do |reliefComponent|
          next unless reliefComponent.to_Node.is_initialized
          node = reliefComponent.to_Node.get
          if node.inletModelObject.is_initialized
            next if outdoorAirSystem.outboardReliefNode
            component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
            expected_name = "#{outdoorAirSystem_name}-Supply-#{component1.to_s}-Leaving_node"
            name = reliefComponent.name()
            assert(name.to_s.include?(expected_name.to_s), "Air Loop HVAC Outdoor Air System node names did not change correctly")
          end
        end
      end
    end

    # Check whether the names of nodes of the supply side in air loops have been changed correctly
    model.getAirLoopHVACs.sort.each do |air_loop|
      air_loop_name = air_loop.name.get

      unless air_loop.outdoorAirNode.empty?
        expected_name = "#{air_loop_name} Outdoor Intake Air Node"
        name = air_loop.outdoorAirNode.get.name()
      end

      unless air_loop.reliefAirNode.empty?
        expected_name = "#{air_loop_name} Exhaust Outdoor Air Node"
        name = air_loop.reliefAirNode.get.name()
      end

      air_loop.supplyComponents.each do |component|
        next unless component.to_Node.is_initialized
        node = component.to_Node.get
        if node == air_loop.supplyInletNode
          expected_name = "#{air_loop_name}-Return_node"
          name = component.name()
        elsif node == air_loop.supplyOutletNode
          expected_name = "#{air_loop_name}-Supply_node"
          name = component.name()
        elsif node.inletModelObject.is_initialized
          component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
          expected_name = "#{air_loop_name.to_s}-Supply-#{component1.to_s}-Leaving_node"
          name = component.name()
        end
      end
      assert(name.to_s.include?(expected_name.to_s), "Air loop node names did not change correctly")
    end

    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    # save the model to test output directory
    output_file_path = "#{NRCMeasureTestHelper.outputFolder}/test_output.osm"
    model.save(output_file_path, true)

  end
end
