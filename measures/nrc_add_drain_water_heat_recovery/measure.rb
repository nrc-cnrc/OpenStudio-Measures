# Start the measure
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcDrainWaterHeatRecovery < OpenStudio::Measure::EnergyPlusMeasure
  attr_accessor :use_json_package, :use_string_double
  
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Drain Water Heat Recovery'
  end

  # human readable description
  def description
    return 'E+ measure to add dragin water heat recovery'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'E+ measure to add dragin water heat recovery (V3.2 will have this in openstudio but need to use E+ measure for now)'
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
            "name" => "plant_loop",
            "type" => "String",
            "display_name" => "Plant loop to apply change to (currently all is only option)",
            "default_value" => "All",
            "is_required" => true
        },
        {
            "name" => "ua",
            "type" => "Double",
            "display_name" => "UA value of heat exchanger (W/mK)",
            "default_value" => 3000,
            "is_required" => true
        }
    ]
  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(workspace, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Create local copies of the arguments.
    ua_value = arguments["ua"]
	
    # Get all water use connections in the model
    connections = workspace.getObjectsByType('WaterUse:Connections'.to_IddObjectType)

    # Reporting initial condition of model.
    runner.registerInitialCondition("The model started with #{connections.size} water connections.")

    # Loop through connections.
	connections.each do |connection|
      runner.registerInfo("Updating connection #{connection.name}.")
	  #puts "#{connection.name}".green
	  #puts "#{connection.class}".yellow
	  idfObject = connection.idfObject.clone
	  #puts "#{idfObject}".light_blue
	  idfObject.setString(7,"counterflow")
	  idfObject.setString(8,"plant")
	  idfObject.setDouble(9, ua_value)
	  #puts "#{idfObject.class}".blue
	  #puts "#{idfObject}".yellow
	  workspace.swap(connection, idfObject)
	
	
	end
	#idfFile = workspace.toIdfFile()
	#puts "#{idfFile}".green
	
    # echo the new zone's name back to the user, using the index based getString method
    #runner.registerInfo("A zone named '#{new_zone.getString(0)}' was added.")

    # report final condition of model
    connections = workspace.getObjectsByType('WaterUse:Connections'.to_IddObjectType)
    runner.registerFinalCondition("The model finished with #{connections.size} water connections.")

    return true
  end
end

# register the measure to be used by the application
NrcDrainWaterHeatRecovery.new.registerWithApplication
