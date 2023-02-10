# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure

class NrcChangeEnergyRecoveryEfficiency < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "NrcChangeEnergyRecoveryEfficiency"
  end

  # human readable description
  def description
    return 'This measure sets sensible and latent efficiency.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'The measure offers an options to set the sensible and latent efficiency at 75% and 100% heating air flow, also at 75% and 100% cooling air flow. This measure was obatined from https://bcl.nrel.gov/node/39440.'
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
            "name" => "sensible_eff_at_100_heating",
            "type" => "Double",
            "display_name" => "Sensible Effectiveness at 100% Heating Air Flow",
            "default_value" => 0.76,
            "is_required" => true
        },
        {
            "name" => "latent_eff_at_100_heating",
            "type" => "Double",
            "display_name" => "Latent Effectiveness at 100% Heating Air Flow",
            "default_value" => 0.68,
            "is_required" => true
        },
        {
            "name" => "sensible_eff_at_75_heating",
            "type" => "Double",
            "display_name" => "Sensible Effectiveness at 75% Heating Air Flow",
            "default_value" => 0.81,
            "is_required" => true
        },
        {
            "name" => "latent_eff_at_75_heating",
            "type" => "Double",
            "display_name" => "Latent Effectiveness at 75% Heating Air Flow",
            "default_value" => 0.73,
            "is_required" => true
        },
        {
            "name" => "sensible_eff_at_100_cooling",
            "type" => "Double",
            "display_name" => "Sensible Effectiveness at 100% Cooling Air Flow",
            "default_value" => 0.76,
            "is_required" => true
        },
        {
            "name" => "latent_eff_at_100_cooling",
            "type" => "Double",
            "display_name" => "Latent Effectiveness at 100% Cooling Air Flow",
            "default_value" => 0.68,
            "is_required" => true
        },
        {
            "name" => "sensible_eff_at_75_cooling",
            "type" => "Double",
            "display_name" => "Sensible Effectiveness at 75% Cooling Air Flow",
            "default_value" => 0.81,
            "is_required" => true
        },
        {
            "name" => "latent_eff_at_75_cooling",
            "type" => "Double",
            "display_name" => "Latent Effectiveness at 75% Cooling Air Flow",
            "default_value" => 0.73,
            "is_required" => true
        }]
  end

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    sensible_eff_at_100_heating = arguments['sensible_eff_at_100_heating']
    latent_eff_at_100_heating = arguments["latent_eff_at_100_heating"]
    sensible_eff_at_75_heating = arguments["sensible_eff_at_75_heating"]
    latent_eff_at_75_heating = arguments["latent_eff_at_75_heating"]

    sensible_eff_at_100_cooling = arguments["sensible_eff_at_100_cooling"]
    latent_eff_at_100_cooling = arguments["latent_eff_at_100_cooling"]
    sensible_eff_at_75_cooling = arguments["sensible_eff_at_75_cooling"]
    latent_eff_at_75_cooling = arguments["latent_eff_at_75_cooling"]

    model.getHeatExchangerAirToAirSensibleAndLatents.each do |oa_component|
      if oa_component.to_HeatExchangerAirToAirSensibleAndLatent.is_initialized
        runner.registerInfo("*** Identified the ERV")
        erv = oa_component.to_HeatExchangerAirToAirSensibleAndLatent.get
        if sensible_eff_at_100_cooling == 999
          runner.registerInfo("sensible_eff_at_100_cooling is skipped")
        else
          runner.registerInfo("Setting sensible_eff_at_100_cooling")
          erv.setSensibleEffectivenessat100CoolingAirFlow(sensible_eff_at_100_cooling)
        end
        if sensible_eff_at_75_cooling == 999
          runner.registerInfo("sensible_eff_at_75_cooling is skipped")
        else
          runner.registerInfo("Setting sensible_eff_at_75_cooling")
          erv.setSensibleEffectivenessat75CoolingAirFlow(sensible_eff_at_75_cooling)
        end
        if latent_eff_at_100_cooling == 999
          runner.registerInfo("latent_eff_at_100_cooling is skipped")
        else
          runner.registerInfo("Setting latent_eff_at_100_cooling")
          erv.setLatentEffectivenessat100CoolingAirFlow(latent_eff_at_100_cooling)
        end
        if latent_eff_at_75_cooling == 999
          runner.registerInfo("latent_eff_at_75_cooling is skipped")
        else
          runner.registerInfo("Setting latent_eff_at_75_cooling")
          erv.setLatentEffectivenessat75CoolingAirFlow(latent_eff_at_75_cooling)
        end
        if sensible_eff_at_100_heating == 999
          runner.registerInfo("sensible_eff_at_100_heating is skipped")
        else
          runner.registerInfo("Setting sensible_eff_at_100_heating")
          erv.setSensibleEffectivenessat100HeatingAirFlow(sensible_eff_at_100_heating)
        end
        if sensible_eff_at_75_heating == 999
          runner.registerInfo("sensible_eff_at_75_heating is skipped")
        else
          runner.registerInfo("Setting sensible_eff_at_75_heating")
          erv.setSensibleEffectivenessat75HeatingAirFlow(sensible_eff_at_75_heating)
        end
        if latent_eff_at_100_heating == 999
          runner.registerInfo("latent_eff_at_100_heating is skipped")
        else
          runner.registerInfo("Setting latent_eff_at_100_heating")
          erv.setLatentEffectivenessat100HeatingAirFlow(latent_eff_at_100_heating)
        end
        if latent_eff_at_75_heating == 999
          runner.registerInfo("latent_eff_at_75_heating is skipped")
        else
          runner.registerInfo("Setting latent_eff_at_75_heating")
          erv.setLatentEffectivenessat75HeatingAirFlow(latent_eff_at_75_heating)
        end
      end
    end
    return true
  end #end the run method
end #end the measure

#This allows the measure to be use by the application
NrcChangeEnergyRecoveryEfficiency.new.registerWithApplication