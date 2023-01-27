# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcChangeSWHtoASHPWH_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'] != ""
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  else
    start_time=Time.now
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @use_json_package = false
    @use_string_double = false
    @measure_interface_detailed = [
      {
        "name" => "frac_oa",
        "type" => "Double",
        "display_name" => "Fraction of outside air in evaporator",
        "default_value" => 1.0,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }]

    @good_input_arguments = {
      "frac_oa" => 0.75
    }
  end

  def test_office()
    building_types = ["MediumOffice", "SecondarySchool"]
    building_types.each { |building_type|
      puts "Test swapping mixed water heater for heat pump water heater in #{building_type} model".green

      # Define the output folder for this test (optional - default is the method name).
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_#{building_type}")

      # Set standard to use.
      standard = Standard.build("NECB2017")

      # Create prototype model and update to follow standard rules (plus any sideload).
      model = standard.model_create_prototype_model(template: "NECB2017",
                                                    building_type: building_type,
                                                    epw_file: "CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw",
                                                    sizing_run_dir: output_file_path)

      # Set up your argument list to test.
      input_arguments = @good_input_arguments

      # Create an instance of the measure
      runner = run_measure(input_arguments, model)

      model.getPlantLoops.each do |plantloop|
        puts " Test if an air source heat pump water heater was created in plant loop".green + " #{plantloop.name}.".light_blue
        if plantloop.name.to_s.include?("Service Water")
          plantloop.supplyComponents.each do |comp|
            if comp.iddObject.name.include? "OS:WaterHeater:Mixed"
              # Test if ASHPWP was created
              heater_component = comp.to_WaterHeaterMixed.get
              comp_name = heater_component.name.to_s
              assert(comp_name.include? "Air Source Heat Pump Water Heater")
              puts " An air source heat pump water heater was created in plant loop".green + " #{plantloop.name}.".light_blue
            end
          end
        end
      end

      puts " Find the zone with the largest cooling demand, or the zone with largest volume if a cooling zone is not found".green
      coolZone = nil
      largestCoolingLoadValue = 0.0
      largestZone = nil
      largestZoneVolume = 0.0
      model.getZoneHVACEquipmentLists.each do |zoneHVACEquipmentList|
        zone = zoneHVACEquipmentList.thermalZone
        # Get the design load in the space (assumes a sizing run is complete). Method returns an optional.
        coolingLoad = zone.coolingDesignLoad
        coolingLoadValue = 0.0
        if coolingLoad.is_initialized then
          # Not sure why we need to use the is_initialised method here. Without it the optional does not work as expected.
          coolingLoadValue = coolingLoad.get
          if coolingLoadValue > largestCoolingLoadValue then
            coolZone = zone
            largestCoolingLoadValue = coolingLoadValue
          end
        else
          # Select the largest zone as the default zone for the compressor (if a coolZone is not found)
          zoneVolume = zone.airVolume
          if zoneVolume > largestZoneVolume then
            largestZone = zone
            largestZoneVolume = zoneVolume
          end
        end
      end

      ashpwh_created = false
      if coolZone
        puts " The zone with the largest cooling demand is" .green + " #{coolZone.name}".light_blue
        puts " Test if ASHPWH is created in the zone with the largest cooling demand".green
        coolZone.equipment.each do |eqp|
          hp = eqp.to_WaterHeaterHeatPump
          hp_name = hp.get.name if hp.is_initialized
          if (hp_name.to_s).include? "Air Source Heat Pump Water Heater"
            ashpwh_created = true
            puts " Air Source Heat Pump Water Heater".green + " #{eqp.iddObject.name}".light_blue + " is added to the zone with the largest cooling demand".green + " #{coolZone.name} ".light_blue
            break
          end
        end
        msg = "No Air Sourse Heat Pump was added to the zone with the highest cooling load #{coolZone.name}".red
        assert(ashpwh_created, msg)
      else
        puts "Test if ASHPWH is created in the zone with the largest volume as a cooling zone is not found "
        largestZone.equipment.each do |eqp|
          hp = eqp.to_WaterHeaterHeatPump
          hp_name = hp.get.name if hp.is_initialized
          if (hp_name.to_s).include? "Air Source Heat Pump Water Heater"
            ashpwh_created = true
            puts " Air Source Heat Pump Water Heater".green + " #{eqp.iddObject.name}".light_blue + " is added to the zone with the largest cooling demand".green + " #{coolZone.name} ".light_blue
            break
          end
        end
        msg = " No Air Source Heat Pump was added to the zone with the largest volume #{largestZone.name}".red
        assert(ashpwh_created, msg)
      end

      # Save the model to test output directory.
      output_path = "#{output_file_path}/test_output.osm"
      model.save(output_path, true)
      assert(runner.result.value.valueName == 'Success')
    }
  end
end


