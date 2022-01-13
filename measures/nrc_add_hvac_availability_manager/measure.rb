# Start the measure
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcAddHvacAvailabilityManager < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)

  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Add HVAC Availability Manager'
  end

  # human readable description
  def description
    return 'Adds the requested availability manager to the heating/cooling HVAC system.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Creates an availability manager and uses a outdoor air node as the sensed property.
            The "AvailabilityManagerLowTemperatureTurnOff" turns the system off if the temperature at the sensor node is below the specified setpoint temperature. Whereas the
            "AvailabilityManagerHighTemperatureTurnOff" turns the system off when the temperature at sensor node is higher than the specified setpoint temperature.'
  end

  # Use the constructor to set global variables
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = true

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "heatcool",
        "type" => "Choice",
        "display_name" => "Apply to",
        "default_value" => "cooling",
        "choices" => ["cooling", "heating"],
        "is_required" => true
      },
      {
        "name" => "setPoint",
        "type" => "Double",
        "display_name" => "Turn off setpoint",
        "default_value" => 15,
        "max_double_value" => 50.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    #Runs parent run method.
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Set local variables.
    heatcool = arguments['heatcool']
    setPoint = arguments['setPoint']

    # Identify an outside node.
    oaNode = nil
    nodes = model.getNodes
    if nodes.empty? then
      puts "No nodes!".red
      return
    else
      nodes.each do |node|
        # The OA nodes have no inlet port defined, only an outlet port
        if !node.inletModelObject.is_initialized then
          puts "#{node}".green
          oaNode = node
          break # Jump out of this loop when first OA node discovered.
        end
      end
    end

    #puts "Found OA node: #{oaNode.name}".green

    # Create the correct availability manager.
    # The schedule for the manager defaults to always on (which is what we want).
    # Once created attach to the correct equipment.
    if heatcool == "cooling" then
      # The "AvailabilityManagerLowTemperatureTurnOff" turns the system off if the temperature at the sensor node is below the specified setpoint temperature.
      availabilityMgr = OpenStudio::Model::AvailabilityManagerLowTemperatureTurnOff.new(model)
      availabilityMgr.setSensorNode(oaNode)
      availabilityMgr.setTemperature(setPoint)
      # Now loop through the cooling devices and link them to the new availability manager.
      chillers = model.getChillerElectricEIRs
      if !chillers.empty? then
        chillers.each do |chiller|
          #puts "EIR Chiller\n#{chiller}".light_blue
          loop = chiller.plantLoop
          if !loop.empty? then
            loop.get.addAvailabilityManager(availabilityMgr)
            availMgrs = loop.get.availabilityManagers
            #availMgrs.each do |mgr|
            #  puts "#{mgr}".light_blue
            #end
            #puts "Updated plant loop\n#{loop.get}".pink
          end
        end
      end
      coils = model.getCoilCoolingDXSingleSpeeds
      if !coils.empty? then
        coils.each do |coil|
          puts "Coil\n#{coil}".yellow
          coil.setMinimumOutdoorDryBulbTemperatureforCompressorOperation(setPoint)
        end
      end
    else
      availabilityMgr = OpenStudio::Model::AvailabilityManagerHighTemperatureTurnOff.new(model)
      availabilityMgr.setSensorNode(oaNode)
      availabilityMgr.setTemperature(setPoint)
    end

    return true
  end
end

# register the measure to be used by the application
NrcAddHvacAvailabilityManager.new.registerWithApplication
