require_relative 'resources/NRCMeasureHelper'

# Start the measure.
class NrcSetFdwr < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  
# Human readable name
  def name
    return "Set FDWR"
  end

  def description
    return "This measure sets the FDWR according to the selected rule."
  end

  def modeler_description
    return "The measure has a dropdown list to select specific pre-defined options. The options are :
    •	Remove the windows
    •	Set windows to match max FDWR from NECB
    •	Don't change windows
    •	Reduce existing window size to meet maximum NECB FDWR limit
    •	Set specific FDWR
    Specific FDWR is only used if the 'Set specific FDWR' option is selected.
    The measure will select the standards template from the model, but in case it was undefined a default value of 'NECB2017' will be used.
    The measure sets the FDWR according to NECB section 3.2.1.4 (2017 version)"
  end

  def initialize()
    super()

    # Set to true if you want to package the arguments as json.
    @use_json_package = false

    # Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false
    @measure_interface_detailed = [
      {
        "name" => "fdwr_options",
        "type" => "Choice",
        "display_name" => "Select an option for FDWR",
        "default_value" => "Set specific FDWR",
        "choices" => ["Remove the windows", "Set windows to match max FDWR from NECB", "Don't change windows", "Reduce existing window size to meet maximum NECB FDWR limit", "Set specific FDWR"],
        "is_required" => true
      },
      {
        "name" => "fdwr",
        "type" => "Double",
        "display_name" => 'Set specific FDWR (if option is selected above). Please enter a number greater than or equal to 0.0 and less than 1.0',
        "default_value" => 0.4,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => false
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    #   ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure.
    fdwr_options = arguments['fdwr_options']
    fdwr = arguments['fdwr']

    if (fdwr_options == "Remove the windows")
      fdwr = -4.0
    elsif (fdwr_options == "Set windows to match max fdwr from NECB")
      fdwr = -1.0
    elsif (fdwr_options == "Don't change windows")
      fdwr = -2.0
    elsif (fdwr_options == "Reduce existing window size to meet maximum NECB fdwr limit")
      fdwr = -3.0
    elsif (fdwr_options == "Set specific FDWR")
      fdwr = arguments['fdwr']
      if (fdwr < 0.0 || fdwr >= 1.0)
        puts 'FDWR must be greater or equal to 0.0 and less than 1.0'.red
        runner.registerError('FDWR must be greater or equal to 0.0 and less than 1.0')
        return false
      end
    end

    # Figure out which version of NECB is being used in the model.
    standard = find_standard(model)

    runner.registerInfo("Updating components in measure #{self.class.name}")
    standard.apply_standard_window_to_wall_ratio(model: model, fdwr_set: fdwr)

    return true
  end
end

# Register the measure to be used by the application.
NrcSetFdwr.new.registerWithApplication
