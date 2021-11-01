# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcSetBoilerEfficiency < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NrcSetBoilerEfficiency'
  end

  # human readable description
  def description
    return 'This measure sets boiler efficiency that affects heating energy consumption.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'The measure offers an options to set the boiler thermal efficiency. Measure retrieved and updated on 22/05/2020 from NREL, Building Component Library https://bcl.nrel.gov/node/39443.'
  end

  #Use the constructor to set global variables
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false
    @measure_interface_detailed = [
        {
            "name" => "boiler_eff",
            "type" => "Double",
            "display_name" => 'Set Boiler efficiency between 0.0 and 1.0',
            "default_value" => 0.85,
            "is_required" => true
        }]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    boiler_eff = arguments['boiler_eff']

    if boiler_eff == 999
      runner.registerInfo("NrcSetBoilerEfficiency is skipped")
    else
      runner.registerInfo("NrcSetBoilerEfficiency is not skipped")
      model.getBoilerHotWaters.each do |boiler_water|
        boiler_water.setNominalThermalEfficiency(boiler_eff)
      end
    end

    return true
  end
end

# register the measure to be used by the application
NrcSetBoilerEfficiency.new.registerWithApplication
