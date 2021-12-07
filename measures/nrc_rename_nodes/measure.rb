# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcRenameNodes < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  def name
    # Measure name should be the title case of the class name.
    return 'NrcRenameNodes'
  end

  # human readable description
  def description
    return 'This measure loops through a model and update the node names based on the component type before it in all of the supply side of plant loops , air loops and air Loop outdoor air systems.'
  end

  # human readable description of modeling approach
  def modeler_description
    return "The measure loops through the plant/air loops, and for each loop extracts the supply side.
            Then the measure would identify the nodes and the component before it in the supply side branch, and
            rename the nodes name as 'Plant/Air/OutdoorAir LoopName'-'Supply'-ComponentName'-'Leaving' "
  end

  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false
    @measure_interface_detailed = [
      {
        "name" => "rename_nodes",
        "type" => "Bool",
        "display_name" => "Rename nodes of the supply side of plant loops and air loops.",
        "default_value" => true,
        "is_required" => true
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    rename_nodes = arguments['rename_nodes']
    if (rename_nodes)
      # Rename the nodes of the supply side in plant loops
      model.getPlantLoops.sort.each do |plant_loop|
        plant_loop.supplyComponents.each do |component|
          plant_loop_name = plant_loop.name.get
          next unless component.to_Node.is_initialized
          node = component.to_Node.get
          if node == plant_loop.supplyInletNode
            new_name = "#{plant_loop_name}-Return_node"
            component.setName(new_name.to_s)
          elsif node == plant_loop.supplyOutletNode
            new_name = "#{plant_loop_name}-Supply_node"
            component.setName(new_name.to_s)
          elsif node.inletModelObject.is_initialized
            component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
            new_name = "#{plant_loop_name.to_s}-Supply-#{component1.to_s}-Leaving_node"
            component.setName(new_name.to_s)
          end
        end
      end

      # Rename the outdoor nodes of the air loops
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
              new_name = "#{outdoorAirSystem_name}-Supply-#{component1.to_s}-Leaving_node"
              outdoorAirComponent.setName(new_name.to_s)
            end
          end

          reliefComponents = outdoorAirSystem.reliefComponents
          reliefComponents.each do |reliefComponent|
            next unless reliefComponent.to_Node.is_initialized
            node = reliefComponent.to_Node.get
            if node.inletModelObject.is_initialized
              component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
              new_name = "#{outdoorAirSystem_name}-Supply-#{component1.to_s}-Leaving_node"
              reliefComponent.setName(new_name.to_s)
            end
          end
        end
      end

      # Rename the nodes of the supply side in air loops
      model.getAirLoopHVACs.sort.each do |air_loop|
        air_loop_name = air_loop.name.get

        unless air_loop.outdoorAirNode.empty?
          air_loop.outdoorAirNode.get.setName("#{air_loop_name} Outdoor Intake Air Node")
        end

        unless air_loop.reliefAirNode.empty?
          air_loop.reliefAirNode.get.setName("#{air_loop_name} Exhaust Outdoor Air Node")
        end

        air_loop.supplyComponents.each do |component|
          next unless component.to_Node.is_initialized
          node = component.to_Node.get
          if node == air_loop.supplyInletNode
            new_name = "#{air_loop_name}-Return_node"
            component.setName(new_name.to_s)
          elsif node == air_loop.supplyOutletNode
            new_name = "#{air_loop_name}-Supply_node"
            component.setName(new_name.to_s)
          elsif node.inletModelObject.is_initialized
            component1 = "#{node.inletModelObject.get.name.get}" # find the component just before the node
            new_name = "#{air_loop_name.to_s}-Supply-#{component1.to_s}-Leaving_node"
            component.setName(new_name.to_s)
          end
        end
      end

    else
      # if the user selected false as the measure argument
      runner.registerInfo("You have selected 'false', so the measure won't change the names of any nodes. Please select 'true' to change the nodes' names.")
    end
    return true
  end
end

# register the measure to be used by the application
NrcRenameNodes.new.registerWithApplication
