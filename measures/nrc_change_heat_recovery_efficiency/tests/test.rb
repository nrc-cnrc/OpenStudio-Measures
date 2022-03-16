# Standard openstudio requires for runnin test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcChangeEnergyRecoveryEfficiency_Test < Minitest::Test
  include(NRCMeasureTestHelper)

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  start_time=Time.now
  if ARGV.length == 1

    # We have a time. It will be in seconds since the epoch. Update our start_time.
    start_time=Time.at(ARGV[0].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)

  def setup()
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

  def test_argument_values
    # create an instance of the measure
    measure = NrcChangeEnergyRecoveryEfficiency.new

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/warehouse_2017.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    input_arguments = {
        "sensible_eff_at_100_heating" => 0.76,
        "latent_eff_at_100_heating" => 0.68,
        "sensible_eff_at_75_heating" => 0.81,
        "latent_eff_at_75_heating" => 0.73,
        "sensible_eff_at_100_cooling" => 0.76,
        "latent_eff_at_100_cooling" => 0.68,
        "sensible_eff_at_75_cooling" => 0.81,
        "latent_eff_at_75_cooling" => 0.73,

    }

    # Assign the user inputs to variables that can be accessed across the measure
    sensible_eff_at_100_heating = input_arguments['sensible_eff_at_100_heating']
    latent_eff_at_100_heating = input_arguments["latent_eff_at_100_heating"]
    sensible_eff_at_75_heating = input_arguments["sensible_eff_at_75_heating"]
    latent_eff_at_75_heating = input_arguments["latent_eff_at_75_heating"]

    sensible_eff_at_100_cooling = input_arguments["sensible_eff_at_100_cooling"]
    latent_eff_at_100_cooling = input_arguments["latent_eff_at_100_cooling"]
    sensible_eff_at_75_cooling = input_arguments["sensible_eff_at_75_cooling"]
    latent_eff_at_75_cooling = input_arguments["latent_eff_at_75_cooling"]

    # test if the measure would grab the correct number and value of input argument.
    assert_equal(8, arguments.size)
    assert_equal('sensible_eff_at_100_heating', arguments[0].name)
    assert_equal('latent_eff_at_100_heating', arguments[1].name)
    assert_equal('sensible_eff_at_75_heating', arguments[2].name)
    assert_equal('latent_eff_at_75_heating', arguments[3].name)
    assert_equal('sensible_eff_at_100_cooling', arguments[4].name)
    assert_equal('latent_eff_at_100_cooling', arguments[5].name)
    assert_equal('sensible_eff_at_75_cooling', arguments[6].name)
    assert_equal('latent_eff_at_75_cooling', arguments[7].name)

    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("OutputTestFolder")

    # Run the measure and check output
    runner = run_measure(input_arguments, model)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == 'Success')

    #check if efficiencies were changed correctly
    model.getAirLoopHVACOutdoorAirSystems.each do |oa_system|
      oa_system.oaComponents.each do |oa_component|
        if oa_component.to_HeatExchangerAirToAirSensibleAndLatent.is_initialized
          runner.registerInfo("*** Identified the ERV")
          erv = oa_component.to_HeatExchangerAirToAirSensibleAndLatent.get

          assert_equal(latent_eff_at_100_cooling, erv.latentEffectivenessat100CoolingAirFlow)
          assert_equal(latent_eff_at_100_heating, erv.latentEffectivenessat100HeatingAirFlow)
          assert_equal(latent_eff_at_75_cooling, erv.latentEffectivenessat75CoolingAirFlow)
          assert_equal(latent_eff_at_75_heating, erv.latentEffectivenessat75HeatingAirFlow)
          assert_equal(sensible_eff_at_100_cooling, erv.sensibleEffectivenessat100CoolingAirFlow)
          assert_equal(sensible_eff_at_100_heating, erv.sensibleEffectivenessat100HeatingAirFlow)
          assert_equal(sensible_eff_at_75_cooling, erv.sensibleEffectivenessat75CoolingAirFlow)
          assert_equal(sensible_eff_at_75_heating, erv.sensibleEffectivenessat75HeatingAirFlow)
        end
      end
    end

    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
  end
end
