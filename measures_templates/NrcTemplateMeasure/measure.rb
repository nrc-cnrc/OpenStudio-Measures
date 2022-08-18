# Load in the helper methods. These are included below.
require_relative 'resources/NRCMeasureHelper'

# Start the measure.
class NrcModelMeasure < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  
  # Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  
  # Human readable name.
  def name
    return "NRC Template Measure"
  end

  # Human readable description.
  def description
    return "This template measure is used to ensure consistency in detailed BTAP measures using the NRC modifications."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "This template measure is used to ensure consistency in BTAP measures using the NRC modificatoins."
  end

  # Define the outputs that the measure will create. OPTIONAL - remove if not required.
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('name_of_output') # explain what this is.
    return outs
  end

  # Use the constructor to set global variables.
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
        "name" => "a_string_argument",
        "type" => "String",
        "display_name" => "A String Argument (string)",
        "default_value" => "The Default Value",
        "is_required" => true
      },
      {
        "name" => "a_double_argument",
        "type" => "Double",
        "display_name" => "A Double numeric Argument (double)",
        "default_value" => 0,
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "a_string_double_argument",
        "type" => "StringDouble",
        "display_name" => "A String Double numeric Argument (double)",
        "default_value" => 23.0,
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "valid_strings" => ["Baseline", "NA"],
        "is_required" => true
      },
      {
        "name" => "a_choice_argument",
        "type" => "Choice",
        "display_name" => "A Choice String Argument ",
        "default_value" => "choice_1",
        "choices" => ["choice_1", "choice_2"],
        "is_required" => true
      },
      {
        "name" => "a_bool_argument",
        "type" => "Bool",
        "display_name" => "A Boolean Argument ",
        "default_value" => false,
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run.
  def run(model, runner, user_arguments)
  
    # Runs parent run method.
    super(model, runner, user_arguments)
	
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    #   ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)
	
    #puts JSON.pretty_generate(arguments)
    return false if false == arguments
	
	# If required use 'NRCMeasureTestHelper.outputFolder' to get the testing output folder. This will default to $PWD in PAT.
	
    #You can now access the input argument by the name.
    # arguments['a_string_argument']
    # arguments['a_double_argument']
    # etc......
    # So write your measure code here!

    #Do something.

    # Save off the outputs. In reality the 5.2 would be replace with a variables value.
    runner.registerValue('name_of_output', 5.2, 'unit')
    return true
  end
end

# register the measure to be used by the application
NrcModelMeasure.new.registerWithApplication
