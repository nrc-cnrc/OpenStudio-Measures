require_relative 'resources/NRCMeasureHelper'
# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class NrcSetFdwr < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'nrc_set_fdwr'
  end

  def description
    return 'This measure sets the FDWR according to the selected action'
  end

  def modeler_description
    return "The measure has a dropdown list to select specific pre-defined options. The options are :
    •	Remove the windows
    •	Set windows to match max FDWR from NECB
    •	Don't change windows
    •	Reduce existing window size to meet maximum NECB FDWR limit
    •	Set specific FDWR
    Specific FDWR is only used if the 'Set specific FDWR' option is selected.
    The measure will grab the standards template from the model, but in case it was undefined a default value of 'NECB2017' will be used.
    The measure sets the FDWR according to NECB 2017 section 3.2.1.4"
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
        "is_required" => false
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
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

    standard = find_standard(model)
    standard.apply_standard_window_to_wall_ratio(model: model, fdwr_set: fdwr)
    return true
  end

  def find_standard(model)
    if model.getBuilding.standardsTemplate.is_initialized
      standardsTemplate = (model.getBuilding.standardsTemplate).to_s
      standard = Standard.build(standardsTemplate)
    else
      puts "The measure wasn't able to determine the standards template from the model, a default value of 'NECB2017' will be used.".red
      standard = Standard.build('NECB2017')
    end
    return standard
  end
end

# register the measure to be used by the application
NrcSetFdwr.new.registerWithApplication
