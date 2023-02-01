# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcUpdateWaterHeater < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NrcUpdateWaterHeater'
  end

  # human readable description
  def description
    return 'This measure updates water heater.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Update water heater to PCF value.'
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
            "name" => "update_waterheater_pcf2020",
            "type" => "Bool",
            "display_name" => 'Update water heater to PCF value?',
            "default_value" => true,
            "is_required" => true
        }]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

      arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    update_waterheater_pcf2020 = arguments['update_waterheater_pcf2020']

    if update_waterheater_pcf2020

      #water heater update
      model.getWaterHeaterMixeds.each do |water_heater_mixed|
        capacity_w = water_heater_mixed.heaterMaximumCapacity
        capacity_w = capacity_w.get
        capacity_btu_per_hr = capacity_w * 3.412
        fuel_type = water_heater_mixed.heaterFuelType
        volume_m3 = water_heater_mixed.tankVolume.get
        volume_l = volume_m3 / 1000
        volume_gal = 264.172 * volume_m3
        if fuel_type == "Electricity"
          if capacity_w <= 12000
            #DO NOTHING, FOLLOW OS-STANDARD
          else
            #DO NOTHING, FOLLOW OS-STANDARD
          end

        elsif fuel_type == 'NaturalGas'
          if capacity_btu_per_hr <= 75_000
            water_heater_eff = 0.82
            if volume_l < 68
              uef = 0.5982 - 0.0005 * volume_l
              ef = 1.0005 * uef + 0.0019
            elsif volume_l >= 68 and volume_l < 193
              uef = 0.6483 - 0.00045 * volume_l
              ef = 1.0005 * uef + 0.0019
            elsif volume_l >= 193 and volume_l < 284
              uef = 0.692 - 0.00034 * volume_l
              ef = 1.0005 * uef + 0.0019
            end

            # Calculate the Recovery Efficiency (RE)
            # based on a fixed capacity of 75,000 Btu/hr
            # and a fixed volume of 40 gallons by solving
            # this system of equations:
            # ua = (1/.95-1/re)/(67.5*(24/41094-1/(re*cap)))
            # 0.82 = (ua*67.5+cap*re)/cap
            cap = 75_000.0
            re = (Math.sqrt(6724 * ef ** 2 * cap ** 2 + 40_409_100 * ef ** 2 * cap - 28_080_900 * ef * cap + 29_318_000_625 * ef ** 2 - 58_636_001_250 * ef + 29_318_000_625) + 82 * ef * cap + 171_225 * ef - 171_225) / (200 * ef * cap)
            # Calculate the skin loss coefficient (UA)
            # based on the actual capacity.
            ua_btu_per_hr_per_f = (water_heater_eff - re) * capacity_btu_per_hr / 67.5

          elsif capacity_btu_per_hr > 75_000 and capacity_btu_per_hr < 103977 and volume_l < 454
            water_heater_eff = 0.82
            uef = 0.8107 - 0.00021 * volume_l
            ef = 1.0005 * uef + 0.0019
            cap = 103977
            re = (Math.sqrt(6724 * ef ** 2 * cap ** 2 + 40_409_100 * ef ** 2 * cap - 28_080_900 * ef * cap + 29_318_000_625 * ef ** 2 - 58_636_001_250 * ef + 29_318_000_625) + 82 * ef * cap + 171_225 * ef - 171_225) / (200 * ef * cap)
            # Calculate the skin loss coefficient (UA)
            # based on the actual capacity.
            ua_btu_per_hr_per_f = (water_heater_eff - re) * capacity_btu_per_hr / 67.5
          else
            # Thermal efficiency
            et = 0.9
            sl_w = 0.84 * capacity_btu_per_hr / 3412.412 / 0.234 + 16.57 * (volume_l ** 0.5)
            sl_btu_per_hr = sl_w * 3.412
            # Calculate the skin loss coefficient (UA)
            ua_btu_per_hr_per_f = (sl_btu_per_hr * et) / 70
            # Calculate water heater efficiency
            water_heater_eff = (ua_btu_per_hr_per_f * 70 + capacity_btu_per_hr * et) / capacity_btu_per_hr
          end
          ua_btu_per_hr_per_c = (ua_btu_per_hr_per_f * 0.293071) * 9 / 5
          water_heater_mixed.setHeaterThermalEfficiency(water_heater_eff)
          # Skin loss
          water_heater_mixed.setOffCycleLossCoefficienttoAmbientTemperature(ua_btu_per_hr_per_c)
          water_heater_mixed.setOnCycleLossCoefficienttoAmbientTemperature(ua_btu_per_hr_per_c)
        end
      end
    end

    return true
  end
end

# register the measure to be used by the application
NrcUpdateWaterHeater.new.registerWithApplication
