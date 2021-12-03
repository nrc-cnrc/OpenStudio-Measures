require_relative 'resources/NRCMeasureHelper'

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class NrcSetSrr < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  def name
    # Measure name should be the title case of the class name.
    return 'nrc_set_srr'
  end

  # human readable description
  def description
    return 'This measure sets the SRR according to the selected action.'
  end

  def modeler_description
    return "The measure has a dropdown list to select specific pre-defined options. The options are :
    •	Remove the skylights
    •	Set skylights to match max SRR from NECB
    •	Don't change skylights
    •	Reduce existing skylight size to meet maximum NECB SRR limit
    •	Set specific SRR
    Specific SRR is only used if the 'Set specific SRR' option is selected.
    This measure sets the SRR according to the NECB rules.
    The measure will detect the version of NECB automatically (default is NECB 2017)."
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
        "name" => "srr_options",
        "type" => "Choice",
        "display_name" => "Select an option for SRR",
        "default_value" => "Set specific SRR",
        "choices" => ["Remove the skylights", "Set skylights to match max SRR from NECB", "Don't change skylights", "Reduce existing skylight size to meet maximum NECB SRR limit", "Set specific SRR"],
        "is_required" => true
      },
      {
        "name" => "srr",
        "type" => "Double",
        "display_name" => 'Set specific SRR (if option is selected above). Please enter a number greater than or equal to 0.0 and less than or equal to 1.0',
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
    srr_options = arguments['srr_options']
    srr = arguments['srr']
    standard = find_standard(model)

    if (srr_options == "Remove the skylights")
      srr = -4.0
    elsif (srr_options == "Set skylights to match max SRR from NECB")
      srr = -1.0
    elsif (srr_options == "Don't change skylights")
      srr = -2.0
    elsif (srr_options == "Reduce existing skylight size to meet maximum NECB SRR limit")
      srr = -3.0
    elsif (srr_options == "Set specific SRR")
      srr = arguments['srr']
      exp_surf_info = standard.find_exposed_conditioned_roof_surfaces(model)
      if (srr < 0.0 || srr > 1.0)
        runner.registerError('SRR must be greater or equal to 0.0 and less than 1.0'.red)
        return false
      elsif (srr == 0.0)
        runner.registerInfo('Removing the skylights as value set to zero'.green)
        srr = -4.0 # Setting the option of srr = 0.0 is same as removing the skylights
      elsif exp_surf_info["exp_nonplenum_roof_area_m2"] < 0.1
        runner.registerWarning("This building has no exposed ceilings adjacent to spaces that are not attics or plenums.  No skylights will be added.".yellow)
        return false
      end
    end

    standard.apply_standard_skylight_to_roof_ratio(model: model, srr_set: srr)
    return true
  end

  def find_standard(model)
    if model.getBuilding.standardsTemplate.is_initialized
      standardsTemplate = (model.getBuilding.standardsTemplate).to_s
      standard = Standard.build(standardsTemplate)
    else
      runner.registerWarning("The measure wasn't able to determine the standards template from the model, a default value of 'NECB2017' will be used.".yellow)
      standard = Standard.build('NECB2017')
    end
    return standard
  end
end

# register the measure to be used by the application
NrcSetSrr.new.registerWithApplication
