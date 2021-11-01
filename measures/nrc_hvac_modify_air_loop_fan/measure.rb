# Start the measure
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcHvacModifyAirLoopFan < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)

  # Human readable name
  def name
    return "Modify HVAC Air Loop Fan Parameters"
  end

  # Human readable description
  def description
    return "This measure modifies the selected air loop fan."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "This measure modifies the selected air loop fan."
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
        "name" => "air_loop",
        "type" => "String",
        "display_name" => "Air loop to apply change to (currently all is only option)",
        "default_value" => "All",
        "is_required" => true
      },
      {
        "name" => "pressure_rise",
        "type" => "Double",
        "display_name" => "Pressure rise (Pa)",
        "default_value" => 640.0,
        "max_double_value" => 2000.0,
        "min_double_value" => -1.0,
        "is_required" => true
      },
      {
        "name" => "fan_efficiency",
        "type" => "Double",
        "display_name" => "Fan efficiency (%)",
        "default_value" => 80.0,
        "max_double_value" => 100.0,
        "min_double_value" => -1.0,
        "is_required" => true
      },
      {
        "name" => "motor_efficiency",
        "type" => "Double",
        "display_name" => "Motor efficiency (%)",
        "default_value" => 80.0,
        "max_double_value" => 100.0,
        "min_double_value" => -1.0,
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
    new_pressure_rise = arguments['pressure_rise']
    new_fan_efficiency = arguments['fan_efficiency'] / 100.0
    new_motor_efficiency = arguments['motor_efficiency'] / 100.0
    puts "new_pressure_rise #{new_pressure_rise}".yellow
    puts "new_fan_efficiency #{new_fan_efficiency}".yellow
    puts "new_motor_efficiency #{new_motor_efficiency}".yellow

    # Track if the modifications are successful.
    success_pressure_rise = true
    success_fan_efficiency = true
    success_motor_efficiency = true

    # Loop through the model and make changes.
    model.getLoops.each do |loop|
      puts "Air loop name: #{loop.name}".light_blue
      loop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Fan:ConstantVolume"
          puts "CAV Fan name: #{comp.name}".green
          fan = comp.to_FanConstantVolume.get
          if new_pressure_rise > 0.0
            success_pressure_rise = fan.setPressureRise(new_pressure_rise)
          end
          if new_fan_efficiency > 0.0
            success_fan_efficiency = fan.setFanTotalEfficiency(new_fan_efficiency)
          end
          if new_motor_efficiency > 0.0
            success_motor_efficiency = fan.setMotorEfficiency(new_motor_efficiency)
          end
        elsif comp.iddObject.name.include? "OS:Fan:VariableVolume"
          puts "VAV Fan name: #{comp.name}".green
          fan = comp.to_FanVariableVolume.get
          if new_pressure_rise > 0.0
            success_pressure_rise = fan.setPressureRise(new_pressure_rise)
          end
          if new_fan_efficiency > 0.0
            success_fan_efficiency = fan.setFanTotalEfficiency(new_fan_efficiency)
          end
          if new_motor_efficiency > 0.0
            success_motor_efficiency = fan.setMotorEfficiency(new_motor_efficiency)
          end
        end
      end
    end

    return (success_pressure_rise && success_fan_efficiency && success_motor_efficiency)
  end
end

# register the measure to be used by the application
NrcHvacModifyAirLoopFan.new.registerWithApplication
