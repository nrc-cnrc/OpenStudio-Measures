require_relative 'resources/NRCMeasureHelper'

# Start the measure.
class NrcSetSHGC < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # Human readable name.
  def name
    return "Set SHGC"
  end

  # Human readable description.
  def description
    return "Changes solar heat gain coefficient (SHGC) of simple glazing systems."
  end

  # Human readable description of modeling approach.
  def modeler_description
    return "For all simple glazing systems in the model changes the SHGC to the value specified."
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
        "name" => "new_shgc",
        "type" => "Double",
        "display_name" => 'SHGC',
        "default_value" => 0.3,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run.
  def run(model, runner, user_arguments)
    
	#Runs parent run method.
    super(model, runner, user_arguments)
    
	# Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    #  ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure.
    new_shgc = arguments['new_shgc']

    runner.registerInfo("Updating components in measure #{self.class.name}")
    model.getSimpleGlazings.each do |sim_glaz|
      runner.registerInfo("Changing SHGC for #{sim_glaz}")
      sim_glaz.setSolarHeatGainCoefficient(new_shgc)
    end
	
    return true
  end
end

# Register the measure to be used by the application.
NrcSetSHGC.new.registerWithApplication
