# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'

# Start the measure.
class NrcSetPumpEfficiency < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  # Human readable name.
  def name
    return 'Set Pump Efficiency '
  end

  # Human readable description.
  def description
    return 'Set pump motor efficiency to specified value in all fans in the model (see modeler description for specific object types).'
  end

  # Human readable description of modeling approach.
  def modeler_description
    return 'The measure sets motor efficiency of constant and variable speed pumps in the model.'
  end

  # Use the constructor to set global variables.
  def initialize()
    super()

    #Set to true if you want to package the arguments as json.
    @use_json_package = false

    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false
    @measure_interface_detailed = [
      {
        "name" => "pump_eff",
        "type" => "Double",
        "display_name" => 'Set pump efficiency (fraction between 0.0 and 1.0)',
        "default_value" => 0.91,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    #  ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure.
    pump_eff = arguments['pump_eff']

    runner.registerInfo("Updating components in measure #{self.class.name}")

    model.getPumpConstantSpeeds.each do |pump|
      pump.setMotorEfficiency(pump_eff)
    end
    model.getPumpVariableSpeeds.each do |pump|
      pump.setMotorEfficiency(pump_eff)
    end

    return true
  end
end

# register the measure to be used by the application
NrcSetPumpEfficiency.new.registerWithApplication
