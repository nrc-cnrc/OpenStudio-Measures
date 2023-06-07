# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcAddDOASSys < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  def name
    return 'NrcAddDOASSys'
  end

  # human readable description
  def description
    return 'This measure sets dedicated outdoor air system (DOAS) for HVAC airloops.'
  end

  # human readable description of modeling approach
  def modeler_description
    return "The measure loops through supply components of HVAC airloops, sets up DOAS for the zones served by the air loop.
             Also it checks if it has a doas (erv), then it won't add a doas. This measure is skipped for office and highrise buildings"
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
            "name" => "zonesselected",
            "type" => "String",
            "display_name" => 'Choose which zones to add DOAS to',
            "default_value" => "All Zones",
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
    zonesselected = arguments['zonesselected']

    if zonesselected == '999'
      runner.registerInfo("NrcAddDOASSys is skipped")
    else
      runner.registerInfo("NrcAddDOASSys is not skipped")
      if model.building.get.name.to_s.include?("MediumOffice") or model.building.get.name.to_s.include?("LargeOffice") #or model.building.get.name.to_s.include?("HighriseApartment")
        #do nothing
        puts "Don't use NrcAddDOASSys for office or highrise"
      else
        puts "use NrcAddDOASSys "
        if zonesselected == "All Zones"
          #prep work
          #get zoneequipmentlist ready
          list_of_zone_hvac_eqp_list = model.getZoneHVACEquipmentLists
          erv_temp = OpenStudio::Model::ZoneHVACEnergyRecoveryVentilator.new(model)
          erv_class = erv_temp.class
          erv_temp.remove

          #Get the zones that are connected to an air loop with an outdoor air system
          airloops = model.getAirLoopHVACs
          zones_done = []
          airloops.each do |airloop|
            airloop.supplyComponents.each do |supplyComponent|
              if supplyComponent.to_AirLoopHVACOutdoorAirSystem.is_initialized
                airloop_oas_sys = supplyComponent.to_AirLoopHVACOutdoorAirSystem.get
                #this air loop serves zones with an OAS. Set up DOAS for the zones served by this air loop
                #record zones, check if it has a doas (erv), if it does, don't add a doas
                airloop.thermalZones.each do |zone|
                  store_zone = true
                  if not zones_done.include?(zone)
                    list_of_zone_hvac_eqp_list.each do |zone_eqp_list|
                      if zone_eqp_list.thermalZone == zone
                        zone_eqp_list.equipment.each do |zone_eqp|
                          if zone_eqp.class == erv_class.class
                            store_zone = false
                          end
                        end
                      end
                    end
                    if store_zone
                      #for the zones connected to this air loop, set up doas
                      set_up_doas(model, zone, airloop_oas_sys)
                      #remove_extra_comp(model,zone)
                      autosize_affected_hvac(model, zone)
                    end
                  end
                end
              end #supplyComponent.to_AirLoopHVACOutdoorAirSystem.is_initialized
            end #airloop.supplyComponents.each do |supplyComponent|
          end #airloops.each do |airloop|
        end #if zonesselected == "All Zones"
      end #if model.building.get.name.to_s.include?("MediumOffice") or model.building.get.name.to_s.include?("LargeOffice") or model.building.get.name.to_s.include?("HighriseApartment")
    end
    return true
  end

  def set_up_doas(model, zone, airloop_oas_sys)
    #add ERV
    erv = set_up_erv(model, zone, airloop_oas_sys)

    #adjust relevant equipment
    #set existing AirLoopHVACOutdoorAirSystem controller to 0 outdoor flow
    airloop_oas_sys.getControllerOutdoorAir.setMaximumOutdoorAirFlowRate(0.0)
    airloop_oas_sys.getControllerOutdoorAir.setMinimumOutdoorAirFlowRate(0.0)
    #adjust terminals if needed (changing setpoint manager)
    zone_term = zone.airLoopHVACTerminal.get #terminal will be defined since the zone is an air loop
    if zone_term.to_AirTerminalSingleDuctVAVReheat.is_initialized or zone_term.to_AirTerminalSingleDuctVAVHeatAndCoolReheat.is_initialized or zone_term.to_AirTerminalSingleDuctVAVHeatAndCoolNoReheat.is_initialized #change setpoint manager for vav terminals
      if zone_term.to_AirTerminalSingleDuctVAVReheat.is_initialized
        zone_term.to_AirTerminalSingleDuctVAVReheat.get.setZoneMinimumAirFlowMethod("Constant")
        zone_term.to_AirTerminalSingleDuctVAVReheat.get.setConstantMinimumAirFlowFraction(0.05)
      elsif zone_term.to_AirTerminalSingleDuctVAVHeatAndCoolNoReheat.is_initialized
        zone_term.to_AirTerminalSingleDuctVAVHeatAndCoolNoReheat.get.setZoneMinimumAirFlowFraction(0.05)
      end
      airloop = airloop_oas_sys.airLoop.get
      sup_node = airloop.supplyOutletNode
      stp_mg = sup_node.to_Node.get.setpointManagers[0]
      if stp_mg.to_SetpointManagerScheduled.is_initialized
        stp_mg.remove
        new_setpoint_manager_warmest = OpenStudio::Model::SetpointManagerWarmest.new(model)
        new_setpoint_manager_warmest.setName("#{sup_node.name} SAT stpmanager")
        new_setpoint_manager_warmest.setControlVariable("Temperature")
        new_setpoint_manager_warmest.setMinimumSetpointTemperature(12)
        new_setpoint_manager_warmest.setMaximumSetpointTemperature(35)
        new_setpoint_manager_warmest.setStrategy("MaximumTemperature")
        new_setpoint_manager_warmest.addToNode(sup_node)

      end
    end
    #set erv schedule to existing air loop hvac sched

  end

  def set_up_erv(model, zone, airloop_oas_sys)

    #get the vent req
    vent_flow = -999
    vent1 = -999
    vent2 = -999
    airloop_oas_sys
    if airloop_oas_sys.getControllerOutdoorAir.autosizedMinimumOutdoorAirFlowRate.is_initialized
      vent_flow = airloop_oas_sys.getControllerOutdoorAir.autosizedMinimumOutdoorAirFlowRate.get.to_f
    else
      dsoa = zone.spaces[0].designSpecificationOutdoorAir
      if dsoa.is_initialized
        dsoa = dsoa.get
        vent1 = dsoa.outdoorAirFlowperFloorArea
        vent2 = dsoa.outdoorAirFlowperPerson
      end
    end
    #get air loop fan sched
    airloop = airloop_oas_sys.airLoop.get
    erv_sch = airloop.availabilitySchedule
    #create erv related objects
    erv_controller = OpenStudio::Model::ZoneHVACEnergyRecoveryVentilatorController.new(model)
    erv_hx = OpenStudio::Model::HeatExchangerAirToAirSensibleAndLatent.new(model)
    erv_fan_onoff_sup = OpenStudio::Model::FanOnOff.new(model)
    erv_fan_onoff_exh = OpenStudio::Model::FanOnOff.new(model)

    #define fan on off performances
    erv_fan_onoff_sup.setName("#{zone.name} erv sup fan")
    erv_fan_onoff_sup.setAvailabilitySchedule(model.alwaysOnDiscreteSchedule)
    erv_fan_onoff_sup.setFanEfficiency(0.75)
    erv_fan_onoff_sup.setMotorEfficiency(0.9)
    erv_fan_onoff_sup.setMotorInAirstreamFraction(1.0)
    erv_fan_onoff_sup.setPressureRise(200)
    erv_fan_onoff_exh.setName("#{zone.name} erv exh fan")
    erv_fan_onoff_exh.setAvailabilitySchedule(model.alwaysOnDiscreteSchedule)
    erv_fan_onoff_exh.setFanEfficiency(0.75)
    erv_fan_onoff_exh.setMotorEfficiency(0.9)
    erv_fan_onoff_exh.setMotorInAirstreamFraction(1.0)
    erv_fan_onoff_exh.setPressureRise(200)

    #define hx parameters
    erv_hx.setName("#{zone.name} erv hx")
    erv_hx.setAvailabilitySchedule(model.alwaysOnDiscreteSchedule)
    erv_hx.setEconomizerLockout(false)
    erv_hx.setFrostControlType("ExhaustAirRecirculation")
    erv_hx.setHeatExchangerType("Rotary")
    erv_hx.setInitialDefrostTimeFraction(0.167)
    erv_hx.setRateofDefrostTimeFractionIncrease(0.012)
    erv_hx.setLatentEffectivenessat100CoolingAirFlow(0.75)
    erv_hx.setLatentEffectivenessat100HeatingAirFlow(0.75)
    erv_hx.setLatentEffectivenessat75CoolingAirFlow(0.75)
    erv_hx.setLatentEffectivenessat75HeatingAirFlow(0.75)
    erv_hx.setThresholdTemperature(-23.3) #btap number, seems low

    #define erv controller
    erv_controller.setName("#{zone.name} erv contr")
    erv_controller.setTemperatureHighLimit(19)
    erv_controller.setTemperatureLowLimit(13)
    erv_controller.setExhaustAirTemperatureLimit("NoExhaustAirTemperatureLimit")
    erv_controller.setExhaustAirEnthalpyLimit("NoExhaustAirEnthalpyLimit")
    erv_controller.setTimeofDayEconomizerFlowControlSchedule(model.alwaysOffDiscreteSchedule)
    erv_controller.setHighHumidityControlFlag(false)
    electronicEnthalpyCurveA = OpenStudio::Model::CurveCubic.new(model)
    electronicEnthalpyCurveA.setCoefficient1Constant(0.01342704)
    electronicEnthalpyCurveA.setCoefficient2x(-0.00047892)
    electronicEnthalpyCurveA.setCoefficient3xPOW2(0.000053352)
    electronicEnthalpyCurveA.setCoefficient4xPOW3(-0.0000018103)
    electronicEnthalpyCurveA.setMinimumValueofx(16.6)
    electronicEnthalpyCurveA.setMaximumValueofx(29.13)
    erv_controller.setElectronicEnthalpyLimitCurve(electronicEnthalpyCurveA)

    #set up erv
    erv = OpenStudio::Model::ZoneHVACEnergyRecoveryVentilator.new(model, erv_hx, erv_fan_onoff_sup, erv_fan_onoff_exh)
    erv.setName("#{zone.name} erv doas")
    erv.setAvailabilitySchedule(erv_sch)
    erv.setController(erv_controller)
    if not vent_flow == -999
      erv_fan_onoff_sup.setMaximumFlowRate(vent_flow)
      erv_fan_onoff_exh.setMaximumFlowRate(vent_flow)
      erv.setSupplyAirFlowRate(vent_flow)
      erv.setExhaustAirFlowRate(vent_flow)
    else
      erv_fan_onoff_sup.autosizeMaximumFlowRate
      erv_fan_onoff_exh.autosizeMaximumFlowRate
      erv.autosizeSupplyAirFlowRate
      erv.autosizeExhaustAirFlowRate
      erv.setVentilationRateperUnitFloorArea(vent1)
      erv.setVentilationRateperOccupant(vent2)

    end


    #include doas in zone equip list
    model.getZoneHVACEquipmentLists.each do |zoneHVACEquipmentList|
      list_of_eqp = []
      eqp_clg_priority = []
      eqp_htg_priority = []
      if zoneHVACEquipmentList.thermalZone == zone

        list_of_eqp = zoneHVACEquipmentList.equipment
        list_of_eqp.each do |eqp|
          eqp_clg_priority << zoneHVACEquipmentList.coolingPriority(eqp)
          eqp_htg_priority << zoneHVACEquipmentList.heatingPriority(eqp)
          zoneHVACEquipmentList.removeEquipment(eqp)

        end
        #reconstruct clg order
        #zoneHVACEquipmentList.addEquipment(erv.to_ModelObject.get)
        erv.addToThermalZone(zone)
        list_of_eqp.each_with_index do |eqp, index|
          clg = eqp_clg_priority[index] + 1
          htg = eqp_htg_priority[index] + 1
          zoneHVACEquipmentList.addEquipment(eqp)

        end

      end
    end

    #set up erv power
    eq_lists = model.getZoneHVACEquipmentLists
    model.getThermalZones.each do |zone|
      eq_lists.each do |eq_list|
        if eq_list.thermalZone == zone
          eq_list.equipmentInHeatingOrder.each do |eqp|
            if eqp.name.to_s.include?("erv doas") and eqp.to_ZoneHVACEnergyRecoveryVentilator.is_initialized
              area = zone.floorArea
              vent_per_floor = eqp.to_ZoneHVACEnergyRecoveryVentilator.get.ventilationRateperUnitFloorArea
              erv_vent_flow = area * vent_per_floor
              power = (erv_vent_flow * 212.5 / 0.5) + (erv_vent_flow * 0.9 * 162.5 / 0.5) + 50 #from op[enstudio] standards
              result = eqp.to_ZoneHVACEnergyRecoveryVentilator.get.heatExchanger.to_HeatExchangerAirToAirSensibleAndLatent.get.setNominalElectricPower(power)

            end
          end


        end
      end
    end

    return erv
  end

  def autosize_affected_hvac(model, zone)
    model.getChillerElectricEIRs.each do |chiller|
      if chiller.referenceCapacity.is_initialized
        cap = chiller.referenceCapacity.get
        if cap > 100 #sometimes chillers are sized to 0.001 in archetypes
          chiller.autosizeReferenceCapacity
        end
      end
    end

    model.getBoilerHotWaters.each do |boiler|
      if boiler.nominalCapacity.is_initialized
        cap = boiler.nominalCapacity.get
        if cap > 100 #sometimes boiler sized to 0.001
          boiler.autosizeNominalCapacity
        end
      end
    end
  end #def autosize_affected_hvac(model, zones)
end

# this allows the measure to be used by the application
NrcAddDOASSys.new.registerWithApplication
