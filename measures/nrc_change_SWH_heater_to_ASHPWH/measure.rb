require_relative 'resources/NRCMeasureHelper'
# Start the measure

class NrcChangeSWHtoASHPWH < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # Human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NRC Change SWH Heater to Heat Pump'
  end

  # Human readable description
  def description
    return 'This measure adds a heat pump water heater to an existing mixed water heater.'
  end

  # Human readable description of modeling approach
  def modeler_description
    return 'This measure loops through the plant loops, identifies the service water loop(s) and changes the heater to the one selected.'
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
        "display_name" => "Fraction of outside air in evaporator",
        "default_value" => 1.0,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.

    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    frac_oa = arguments['frac_oa']

    runner.registerInitialCondition("Starting SWH change to air source heat pump measure.")
    runner.registerInfo("NrcChangeSWHtoHPHeater")
    heater_component = nil
    heater_capacity_W = nil
    heater_volume_m3 = nil
    setpoint_schedule = nil
    ambient_T_schedule = nil
    model.getPlantLoops.each do |plantloop|
      puts "Plant loop name: #{plantloop.name}".light_blue
      if plantloop.name.to_s.include?("Service Water")
        plantloop.supplyComponents.each do |comp|
          if comp.iddObject.name.include? "OS:WaterHeater:Mixed"
            #"OS:WaterHeater:Stratified" ||
            #"OS:WaterHeater:HeatPump:WrappedCondenser")
            runner.registerInfo("Found mixed water heater (#{comp.name}) in plant loop #{plantloop.name}.")

            # Get the concrete object and recover the sizing info so it can be applied to the
            # new heat pump heater.
            heater_component = comp.to_WaterHeaterMixed.get
            heater_capacity_W = heater_component.heaterMaximumCapacity.get
            heater_volume_m3 = heater_component.tankVolume.get
            setpoint_schedule = heater_component.setpointTemperatureSchedule.get
            ambient_T_schedule = heater_component.ambientTemperatureSchedule.get
          end
        end

        # Get sizing factors from current heater.
        puts "Capacity ".green + "#{heater_capacity_W}".light_blue + " W".green
        puts "Volume ".green + "#{heater_volume_m3}".light_blue + " m3".green
        puts "Schedule ".green + "#{setpoint_schedule.name}".light_blue + " W".green

        # Define a new mixed water heater component for the HP to link to.
        new_water_heater = OpenStudio::Model::WaterHeaterMixed.new(model)
        new_water_heater.setName("Air Source Heat Pump Water Heater Mixed Tank")
        new_water_heater.setTankVolume(heater_volume_m3)
        new_water_heater.setSetpointTemperatureSchedule(setpoint_schedule)
        new_water_heater.setDeadbandTemperatureDifference(2.0) # K
        new_water_heater.setAmbientTemperatureIndicator('ThermalZone')
        new_water_heater.setHeaterControlType('Cycle')
        new_water_heater.setHeaterMaximumCapacity(heater_capacity_W) # Use same as before
        new_water_heater.setOffCycleParasiticHeatFractiontoTank(0.8)
        new_water_heater.setIndirectWaterHeatingRecoveryTime(1.5) # 1.5hrs
        new_water_heater.setEndUseSubcategory('Service Hot Water')
        new_water_heater.setHeaterFuelType('Electricity')
        new_water_heater.setHeaterThermalEfficiency(1.0)
        new_water_heater.setOffCycleParasiticFuelType('Electricity')
        new_water_heater.setOnCycleParasiticFuelType('Electricity')

        # Define new heat pump water heater and add to the supply side.
        hp_water_heater = add_ashpwh(model, runner, new_water_heater, frac_oa)
        plantloop.addSupplyBranchForComponent(new_water_heater)
        plantloop.removeSupplyBranchWithComponent(heater_component)
      end
    end
    return true
  end

  # Method to create an air source heat pump water heater.
  # Adds heater to the supplied plant loop and condenser to the thermal zone.
  #  model - the model to add the heat pump etc to
  #  heater_tank - existing SWH heater component (mixed heater tank) that the HP will be linked to
  #  frac_oa - fraction of outside air passing the evaporator
  def add_ashpwh(model, runner, heater_tank, frac_oa)

    # Define the required components.
    ashpwh_coil = OpenStudio::Model::CoilWaterHeatingAirToWaterHeatPump.new(model)
    ashpwh_fan = OpenStudio::Model::FanOnOff.new(model)
    ashpwh_stp = OpenStudio::Model::ScheduleRuleset.new(model)
    ashpwh_inlet_mixer_sch = OpenStudio::Model::ScheduleRuleset.new(model)

    # Heating setpoint
    ashpwh_stp_default_sched = ashpwh_stp.defaultDaySchedule
    wh_stp_default_sch = heater_tank.setpointTemperatureSchedule.get.to_ScheduleRuleset.get.defaultDaySchedule
    wh_stp_default_times = wh_stp_default_sch.times
    wh_stp_default_values = wh_stp_default_sch.values
    wh_stp_default_times.each_with_index do |time, index|

      # Get value from existing water heater and then set a lower value WHY???
      wh_stp_value = wh_stp_default_values[index]
      wh_stp_default_sch.removeValue(time)
      new_wh_stp_value = wh_stp_value - 2.5
      wh_stp_default_sch.addValue(time, new_wh_stp_value)

      # Add value to HP
      ashpwh_stp_default_sched.addValue(time, wh_stp_value)
    end

    # Set OA schedule for compressor.
    runner.registerInfo("Setting OA fraction to #{frac_oa}.")
    ashpwh_inlet_mixer_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), frac_oa)

    # Now create the ashpwh (based on the current heater_tank)
    ashpwh = OpenStudio::Model::WaterHeaterHeatPump.new(model, ashpwh_coil, heater_tank, ashpwh_fan, ashpwh_stp, ashpwh_inlet_mixer_sch)
    ashpwh.setAvailabilitySchedule(model.alwaysOnDiscreteSchedule)
    ashpwh.setName("ASHPWH replacing #{heater_tank.name}")
    ashpwh.setDeadBandTemperatureDifference(2)
    ashpwh.setTank(heater_tank)
    ashpwh_stp.setName("#{ashpwh.name} setpoint")

    # Set compressor location to match designated zone
    #if frac_oa > 1 then
    ashpwh.setCompressorLocation("Zone")
    #else
    #  ashpwh.setCompressorLocation("Zone")
    #end
    ashpwh.setInletAirConfiguration('ZoneAndOutdoorAir')

    # Set compressor operation temp min
    ashpwh.setMinimumInletAirTemperatureforCompressorOperation(5)

    #set up heat pump coil performance
    wh_tank_cap = heater_tank.heaterMaximumCapacity.get.to_f
    ashpwh.dXCoil.to_CoilWaterHeatingAirToWaterHeatPump.get.setRatedCOP(3.0)
    ashpwh.dXCoil.to_CoilWaterHeatingAirToWaterHeatPump.get.setRatedHeatingCapacity(wh_tank_cap)

    # Identify zone with the largest cooling demand and locate the compressor there.
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
      end

      # Select the largest zone as the default zone for the compressor (if a coolZone is not found)
      zoneVolume = zone.airVolume
      if zoneVolume > largestZoneVolume then
        largestZone = zone
        largestZoneVolume = zoneVolume
      end
    end
    # Add water heater to the zone with the largest cooling load (if there is one), otherwise?
    if coolZone then
      # Link the zone to the tank's ambient temperature
      heater_tank.setAmbientTemperatureThermalZone(coolZone)

      # This automatically makes the HP the first priority in the zone cooling calcs (and heating).
      ashpwh.addToThermalZone(coolZone)

      # Debug check.
      #coolZone.equipment.each do |eqp|
      #  puts "After: \n#{eqp.name}".green
      #end
    else
      puts "Adding compressor to the largest zone".green
      heater_tank.setAmbientTemperatureThermalZone(largestZone)
      ashpwh.addToThermalZone(largestZone)
    end

    return ashpwh
  end

end

# register the measure to be used by the application
NrcChangeSWHtoASHPWH.new.registerWithApplication
