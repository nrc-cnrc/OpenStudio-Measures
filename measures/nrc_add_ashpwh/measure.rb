# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcAddASHPWH < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NrcAddASHPWH '
  end

  # human readable description
  def description
    return 'This measure replaces existing water heater with Air Source Heat Pump Water Heater.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure loops through supply components in plant loops, and replaces water heater with ASHPWH.'
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
            "name" => "frac_oa",
            "type" => "Double",
            "display_name" => 'Set frac_oa',
            "default_value" => 1.0,
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
    frac_oa = arguments['frac_oa']

    wh_type = "All" # water heater types

    if frac_oa == 999
      runner.registerInfo("NrcAddASHPWH is skipped")
    else
      runner.registerInfo("NrcAddASHPWH is not skipped")
      model_hdd = 1
      if model.building.get.name.to_s.include?("LargeOffice")
        puts "skip large office" #skip measure for large offices
      else
        if wh_type == "All"
          model.getPlantLoops.each do |plantloop|
            plantloop.supplyComponents.each do |comp|
              if comp.to_WaterHeaterMixed.is_initialized
                a = add_ashpwh_mixed(model, plantloop, comp.to_WaterHeaterMixed.get, frac_oa, model_hdd)
                #puts "#{a}"
              elsif comp.to_WaterHeaterStratified.is_initialized
                add_ashpwh_stratified(model, plantloop, comp.to_WaterHeaterStratified.get)
              end
            end #plantloop.supplyComponents.each do |comp|
          end #model.getPlantLoops.each do |plantloop|
        else # if wh_type == "All"
        end # if wh_type == "All"
      end
    end
    return true
  end

  def add_ashpwh_mixed(model, plantloop, wh_tank, frac_oa, model_hdd)
    ashpwh = 999
    building_name = model.building.get.name.to_s
    model.getZoneHVACEquipmentLists.each do |zoneHVACEquipmentList|
      this_zone = zoneHVACEquipmentList.thermalZone
      if this_zone.name.to_s.upcase == "ALL_ST=OFFICE OPEN PLAN_FL=BUILDING STORY 2_SCH=A 4" and building_name.include?("LargeOffice") #lg office
        ashpwh = create_ashpwh(model, plantloop, wh_tank, this_zone, 0.8)
        add_eqp_list_first(zoneHVACEquipmentList, ashpwh, this_zone, 0.8)
      elsif this_zone.name.to_s.upcase == "DU_BT=SPACE FUNCTION_ST=DWELLING UNITS GENERAL_FL=BUILDING STORY 10_SCHG 5" and building_name.include?("HighriseApartment") #lg office #high rise apt's office.. might not use zone air for source
        ashpwh = create_ashpwh(model, plantloop, wh_tank, this_zone, 1.0) #don't use office air; not enough
        add_eqp_list_first(zoneHVACEquipmentList, ashpwh, this_zone, 1.0) #don't use office air, not enough
      elsif this_zone.name.to_s.upcase == "ALL_ST=OFFICE OPEN PLAN_FL=BUILDING STORY 3_SCH=A 2" and building_name.include?("MediumOffice") #med office
        ashpwh = create_ashpwh(model, plantloop, wh_tank, this_zone, frac_oa)
        add_eqp_list_first(zoneHVACEquipmentList, ashpwh, this_zone, frac_oa)
      elsif this_zone.name.to_s.upcase == "ALL_ST=GYMNASIUM/FITNESS CENTRE PLAYING AREA_FL=BUILDING STORY 1_SCH=B 1" and building_name.include?("SecondarySchool") #secondary school
        ashpwh = create_ashpwh(model, plantloop, wh_tank, this_zone, frac_oa)
        add_eqp_list_first(zoneHVACEquipmentList, ashpwh, this_zone, frac_oa)
      elsif this_zone.name.to_s.upcase == "ALL_ST=WAREHOUSE STORAGE AREA MEDIUM TO BULKY PALLETIZED ITEMS_FL=BUILDING STORY 1_SCH=A" and building_name.include?("Warehouse") #warehouse
        ashpwh = create_ashpwh(model, plantloop, wh_tank, this_zone, frac_oa)
        add_eqp_list_first(zoneHVACEquipmentList, ashpwh, this_zone, frac_oa)
      elsif this_zone.name.to_s.upcase == "ALL_ST=SALES AREA_FL=BUILDING STORY 1_SCH=C" and building_name.include?("RetailStripmall") #retail strip
        ashpwh = create_ashpwh(model, plantloop, wh_tank, this_zone, frac_oa)
        add_eqp_list_first(zoneHVACEquipmentList, ashpwh, this_zone, frac_oa)
      end
    end #model.getZoneHVACEquipmentLists.each do|zoneHVACEquipmentList|

    return ashpwh

  end

  def add_ashpwh_stratified(model, plantloop, wh_tank)

  end

  def create_ashpwh(model, plantloop, wh_tank, zone, frac_oa)
    #
    ashpwh_coil = OpenStudio::Model::CoilWaterHeatingAirToWaterHeatPump.new(model)
    ashpwh_fan = OpenStudio::Model::FanOnOff.new(model)
    ashpwh_stp = OpenStudio::Model::ScheduleRuleset.new(model)
    ashpwh_inlet_mixer_sch = OpenStudio::Model::ScheduleRuleset.new(model)
    #set up heating setpoint for the ashpwh
    ashpwh = OpenStudio::Model::WaterHeaterHeatPump.new(model, ashpwh_coil, wh_tank, ashpwh_fan, ashpwh_stp, ashpwh_inlet_mixer_sch)
    ashpwh.setAvailabilitySchedule(model.alwaysOnDiscreteSchedule)
    ashpwh.setName("#{wh_tank.name} ASHPWH")
    ashpwh_stp.setName("#{ashpwh.name} setpoint")
    ashpwh_stp_default_sched = ashpwh_stp.defaultDaySchedule
    wh_stp_default_sch = wh_tank.setpointTemperatureSchedule.get.to_ScheduleRuleset.get.defaultDaySchedule
    wh_stp_default_times = wh_stp_default_sch.times
    wh_stp_default_values = wh_stp_default_sch.values
    wh_stp_default_times.each_with_index do |time, index|
      #get value from wh and then set a lower value
      wh_stp_value = wh_stp_default_values[index]
      wh_stp_default_sch.removeValue(time)
      new_wh_stp_value = wh_stp_value - 2.5
      wh_stp_default_sch.addValue(time, new_wh_stp_value)
      #add value to HP
      ashpwh_stp_default_sched.addValue(time, wh_stp_value)
    end
    #set compressor location to match designated zone
    ashpwh.setCompressorSetpointTemperatureSchedule(ashpwh_stp)
    ashpwh.setCompressorLocation("Zone")
    wh_tank.setAmbientTemperatureThermalZone(zone)
    ashpwh.setDeadBandTemperatureDifference(2)
    #set inlet mixer (zone and outdoor)
    ashpwh.setInletAirConfiguration('ZoneAndOutdoorAir')

    ashpwh_inlet_mixer_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), frac_oa)
    ashpwh.setInletAirMixerSchedule(ashpwh_inlet_mixer_sch)
    #set compressor operation temp min
    ashpwh.setMinimumInletAirTemperatureforCompressorOperation(5)
    #set wh base efficiency to 92%
    wh_tank.setHeaterThermalEfficiency(0.96)
    #set up hp coil performance
    wh_tank_cap = wh_tank.heaterMaximumCapacity.get.to_f
    ashpwh.dXCoil.to_CoilWaterHeatingAirToWaterHeatPump.get.setRatedCOP(3.0)
    ashpwh.dXCoil.to_CoilWaterHeatingAirToWaterHeatPump.get.setRatedHeatingCapacity(wh_tank_cap)

    return ashpwh
  end

  def add_eqp_list_first(zoneHVACEquipmentList, ashpwh, zone, frac_oa)
    list_of_eqp = []
    eqp_clg_priority = []
    eqp_htg_priority = []
    list_of_eqp = zoneHVACEquipmentList.equipment
    list_of_eqp.each do |eqp|
      eqp_clg_priority << zoneHVACEquipmentList.coolingPriority(eqp)
      eqp_htg_priority << zoneHVACEquipmentList.heatingPriority(eqp)
      zoneHVACEquipmentList.removeEquipment(eqp)
    end
    #reconstruct clg order
    ashpwh.addToThermalZone(zone)
    list_of_eqp.each_with_index do |eqp, index|
      clg = eqp_clg_priority[index] + 1
      htg = eqp_htg_priority[index] + 1
      zoneHVACEquipmentList.addEquipment(eqp)

    end
    ashpwh.setInletAirConfiguration('ZoneAndOutdoorAir')
  end
end

# register the measure to be used by the application
NrcAddASHPWH.new.registerWithApplication
