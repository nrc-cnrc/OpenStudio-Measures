# Load in the helper methods. These are included below.
require_relative 'resources/NRCMeasureHelper'

# Start the measure.
class NrcAlterRefStandard < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  
  # Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  
  # Human readable name.
  def name
    return "NRC Alter Reference Standard"
  end

  # Human readable description.
  def description
    return "This measure changes the selected systems reference code. Used to support alterations to existing buildings code development."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "This measure updates the values used in the Standard class to the selected version of the code."
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
        "name" => "lighting",
        "type" => "Choice",
        "display_name" => "Lighting vintage",
        "default_value" => "NECB2020",
        "choices" => ["No change", "NECB2011", "NECB2015", "NECB2017", "NECB2020", "BTAPPRE1980", "BTAP1980TO2010"],
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

    # Assign the user inputs to variables that can be accessed across the measure
    lighting_vintage = arguments['lighting']

    # Need to keep track of the various versions of standards at play here.
    # Get the current standard being used in the model here. Other standards will be created below.
    standard_current = find_standard(model)

    #puts "Standard class: #{standard_current.standards_data.class}".yellow
    #puts "Standard class: #{standard_current.standards_data.keys}".green

    # Update lighting if requested/different from current. 
    if (lighting_vintage != "No change" && lighting_vintage != standard_current) then
      standard_lighting = Standard.build(lighting_vintage)

      # Need to change the space types to the lighting_vintage ones.
      standard_lighting.validate_and_upate_space_types(model)

      # Apply to the space types.
      model.getSpaceTypes.sort.each do |space_type|

        # Loads
        standard_lighting.space_type_apply_internal_loads(space_type: space_type,
                                      set_people: false,
                                      set_lights: true,
                                      set_electric_equipment: false,
                                      set_gas_equipment: false,
                                      set_ventilation: false,
                                      set_infiltration: false,
                                      lights_type: 'NECB_Default',
                                      lights_scale: 1.0)

        # Schedules (only update lighting).
        # def space_type_apply_internal_load_schedules(space_type, set_people, set_lights, set_electric_equipment, set_gas_equipment, set_ventilation, set_infiltration, make_thermostat)
        standard_lighting.space_type_apply_internal_load_schedules(space_type, false, true, false, false, false, false, false)
      end

      # Change the space types tback to the original names.
      standard_current.validate_and_upate_space_types(model)
    end

    #standard_current.standards_data.keys.each do |key| 
    #  if standard_current.standards_data[key].class == Hash
    #    puts "#{key}: #{standard_current.standards_data[key].keys}".red
    #  else
    #    puts "#{key}: #{standard_current.standards_data[key].class}".red
    #  end
    #end

    #puts "#{standard_current.standards_data}".yellow
	
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
NrcAlterRefStandard.new.registerWithApplication
