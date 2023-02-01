# Start the measure
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcHvacModifyPlantLoopPump < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double
  
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  
  # Human readable name
  def name
    return "Modify HVAC Plant Loop Pump Parameters"
  end

  # Human readable description
  def description
    return "This measure modifies the selected plant loop pump."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "This measure modifies the selected plant loop pump. Applies to constant and variable speed pumps."
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
            "name" => "motor_efficiency",
            "type" => "Double",
            "display_name" => "Motor efficiency (%)",
            "default_value" => 65.0,
            "max_double_value" => 100.0,
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
	
    #puts JSON.pretty_generate(arguments).
    return false if false == arguments
	
	# Set local variables.
	new_motor_efficiency = arguments['motor_efficiency'] / 100.0
	puts "new_motor_efficiency #{new_motor_efficiency}".yellow
	
	# Track if the modifications are successsful.
	success = true
	
	# Loop through the model and make changes.
    model.getPlantLoops.each do |loop|
	  puts "Plant loop name: #{loop.name}".light_blue
      loop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Pump:ConstantSpeed" 
	      puts "Constant speed pump name: #{comp.name}".green
		  pump = comp.to_PumpConstantSpeed.get
		  success = pump.setMotorEfficiency(new_motor_efficiency)
        elsif comp.iddObject.name.include? "OS:Pump:VariableSpeed" 
	      puts "Variable speed pump name: #{comp.name}".green
		  pump = comp.to_PumpVariableSpeed.get
		  success = pump.setMotorEfficiency(new_motor_efficiency)
		end
	  end
	end

    return success
  end
end

# register the measure to be used by the application
NrcHvacModifyPlantLoopPump.new.registerWithApplication
