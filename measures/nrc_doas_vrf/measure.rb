# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcDOASVRF < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # human readable name
  def name
    return "NrcDOASVRF"
  end

  # human readable description
  def description
    return "Changes air loop to Deicated Outdoor Air Systems (DOAS), adds Variable Refrigerant Flow (VRF) for those zones."
  end

  # human readable description of modeling approach
  def modeler_description
    return "The measure loops through air loops, changes them to DOAS and adds VRF."
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
            "name" => "loops_to_change",
            "type" => "String",
            "display_name" => 'Loops to change',
            "default_value" => "All",
            "is_required" => true
        }]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    #Runs parent run method.
    super(model, runner, user_arguments)
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    loops_to_change = arguments['loops_to_change']

    if loops_to_change == "999"
      runner.registerInfo("NrcDOASVRF is skipped")

    else
      runner.registerInfo("NrcDOASVRF is not skipped")

      #if model.building.get.name.to_s.include?("MediumOffice") or model.building.get.name.to_s.include?("HighriseApartment") or model.building.get.name.to_s.include?("LargeOffice")

      if loops_to_change == "All"
        list_of_vrf_zones = []
        model.getAirLoopHVACs.each do |airloop|
          #turn each air loop into a doas
          loop_zones = airloop.thermalZones
          set_up_doas(model, airloop, loop_zones)
          #add vrf if these are offices
          if model.building.get.name.to_s.include?("MediumOffice") or model.building.get.name.to_s.include?("LargeOffice") #one vrf outdoor unit for each air loop
            add_vrf_for_offices(model, loop_zones)
            #remove_extra_comp(model,loop_zones)
            autosize_affected_hvac(model, loop_zones)
          end
          loop_zones.each do |zone|
            list_of_vrf_zones << zone
          end
        end
        if model.building.get.name.to_s.include?("MediumOffice") or model.building.get.name.to_s.include?("LargeOffice")
        else #if model.building.get.name.to_s.include?("HighriseApartment") #highrise will share a single vrf outdoor unit
          add_vrf_for_offices(model, list_of_vrf_zones)
          #remove_extra_comp(model,list_of_vrf_zones)
          autosize_affected_hvac(model, list_of_vrf_zones)
        end
      end #if loops_to_change == 'All'
      #else
      #puts "not a medium office or highrise"
      #end#if model.building.get.name.to_s.include?("LargeOffice") or model.building.get.name.to_s.include?("MediumOffice") or model.buil....
    end
    return true
  end

  def set_up_doas(model,airloop,loop_zones)

    oas_system_flag = false
    has_fan_flag = false
    oas_system = 999
    has_fan = 999
    new_vav_term=999
    sup_node=999
    elec_htg_coil= 999
    elec_htg_coil_flag = false
    airloop.supplyComponents.each do |supply_component|
      if supply_component.to_AirLoopHVACOutdoorAirSystem.is_initialized
        oas_system_flag = true
        oas_system = supply_component.to_AirLoopHVACOutdoorAirSystem.get
      elsif supply_component.to_FanConstantVolume.is_initialized or supply_component.to_FanOnOff.is_initialized or supply_component.to_FanVariableVolume.is_initialized
        has_fan_flag = true
        if supply_component.to_FanConstantVolume.is_initialized
          has_fan = supply_component.to_FanConstantVolume.get
        elsif supply_component.to_FanOnOff.is_initialized
          has_fan = supply_component.to_FanOnOff.get
        else
          has_fan = supply_component.to_FanVariableVolume.get
        end
      elsif supply_component.to_CoilHeatingElectric.is_initialized
        elec_htg_coil_flag = true
        elec_htg_coil = supply_component.to_CoilHeatingElectric.get
      end #supply_component.to_airLoopHVACOutdoorAirSystem.is_initialized
    end #airloop.supplyComponents.each do |supply_component|

    if oas_system_flag and has_fan_flag
      #define supply node
      sup_node = airloop.supplyOutletNode.to_Node.get
      #remove old setpoint manager
      setpoint_manager_found = sup_node.setpointManagers[0]
      setpoint_manager_found.remove
      #define new vav fan if it doesnt' have a vav fan
      if not has_fan.to_FanVariableVolume.is_initialized
        new_vav_fan = OpenStudio::Model::FanVariableVolume.new(model)
        new_vav_fan.setPressureRise(has_fan.pressureRise)
        #remove fan
        has_fan.remove
        #add vav fan
        new_vav_fan.addToNode(sup_node)
      end

      #Define new setpoint manager: warmest
      new_setpoint_manager_warmest = OpenStudio::Model::SetpointManagerWarmest.new(model)
      new_setpoint_manager_warmest.setName("#{sup_node.name} SAT stpmanager")
      new_setpoint_manager_warmest.setControlVariable("Temperature")
      new_setpoint_manager_warmest.setMinimumSetpointTemperature(12)
      new_setpoint_manager_warmest.setMaximumSetpointTemperature(24)
      new_setpoint_manager_warmest.setStrategy("MaximumTemperature")
      #add new components to loop
      new_setpoint_manager_warmest.addToNode(sup_node)
      #reset heating coil
      if  elec_htg_coil_flag
        elec_htg_coil.setTemperatureSetpointNode(sup_node)
      end
      #set up sizing object
      sizing_obj = airloop.sizingSystem
      sizing_obj.setTypeofLoadtoSizeOn("VentilationRequirement")
      sizing_obj.setAllOutdoorAirinCooling(true)
      sizing_obj.setAllOutdoorAirinHeating(true)
      #change terminal of each zone in this loop
      loop_zones.each do |zone|
        #adjust zone sizing object
        zone_sizing_obj = zone.sizingZone
        zone_sizing_obj.setAccountforDedicatedOutdoorAirSystem(true)
        zone_sizing_obj.setDedicatedOutdoorAirSystemControlStrategy("ColdSupplyAir")
        zone_sizing_obj.setDedicatedOutdoorAirLowSetpointTemperatureforDesign(12.2)
        zone_sizing_obj.setDedicatedOutdoorAirHighSetpointTemperatureforDesign(14.4)

        #create new terminal
        new_vav_term = OpenStudio::Model::AirTerminalSingleDuctVAVHeatAndCoolNoReheat.new(model)
        new_vav_term.setName("#{zone.name.to_s} DOAS terminal")
        new_vav_term.setAvailabilitySchedule(model.alwaysOnDiscreteSchedule)
        new_vav_term.autosizeMaximumAirFlowRate
        new_vav_term.setZoneMinimumAirFlowFraction(1)

        # remove existing terminal
        zone.airLoopHVACTerminal.get.to_StraightComponent.get.remove

        #begin to terminal to eqp list as first piece of eqp
        model.getZoneHVACEquipmentLists.each do|zoneHVACEquipmentList|
          #get eqp list for this zone
          if zoneHVACEquipmentList.thermalZone == zone
            eqp_clg_priority = []
            eqp_htg_priority = []
            list_of_eqp = zoneHVACEquipmentList.equipment

            #record original cooling/heating order; remove all eqp from list
            list_of_eqp.each do|eqp|
              eqp_clg_priority << zoneHVACEquipmentList.coolingPriority(eqp)
              eqp_htg_priority << zoneHVACEquipmentList.heatingPriority(eqp)
              zoneHVACEquipmentList.removeEquipment(eqp)
            end

            #remove branch from loop
            airloop.removeBranchForZone(zone)

            #add the new terminal 1st so that's it's first
            new_vav_term_hvaccomponent = new_vav_term.to_HVACComponent.get
            airloop.addBranchForZone(zone,new_vav_term_hvaccomponent)

            #then add the other eqp in the original order after the new termina
            list_of_eqp.each_with_index do |eqp,index|
              clg  = eqp_clg_priority[index]+1
              htg = eqp_htg_priority[index]+1
              zoneHVACEquipmentList.addEquipment(eqp)
              zoneHVACEquipmentList.setCoolingPriority(eqp,clg)
              zoneHVACEquipmentList.setHeatingPriority(eqp,htg)
            end

          end # if zoneHVACEquipmentList.thermalZone == zone
        end #model.getZoneHVACEquipmentLists.each do|zoneHVACEquipmentList|
      end #loop_zones.each do |zone| , change the temrinal in each zone
    end # if oas_system_flag and has_fan_flag

  end #def set_up_doas(model,airloop)

  def add_vrf_for_offices(model,list_of_vrf_zones)
    ac_vrf_term = 999
    ac_vrf = 999
    #create the outdoor units first
    ac_vrf = OpenStudio::Model::AirConditionerVariableRefrigerantFlow.new(model)
    #create and connect the evaporative unit
    list_of_vrf_zones.each do|zone|
      zone_sizing_obj = zone.sizingZone
      #set SAT for vrf, since acess to sizing object is available here
      zone_sizing_obj.setZoneHeatingDesignSupplyAirTemperature(35)
      #vrf_htg = OpenStudio::Model::CoilHeatingDXVariableRefrigerantFlow.new(model)
      #vrf_htg.setName ("boo")
      #vrf_clg = OpenStudio::Model::CoilCoolingDXVariableRefrigerantFlow.new(model)
      #vrf_fan = OpenStudio::Model::FanVariableVolume.new(model)
      #vrf_fan = vrf_fan.to_HVACComponent.get
      #ac_vrf_term = OpenStudio::Model::ZoneHVACTerminalUnitVariableRefrigerantFlow.new(model,vrf_clg,vrf_htg,vrf_fan)
      #ac_vrf_term.addToThermalZone(zone)
      #ac_vrf.addTerminal(ac_vrf_term)
      ac_vrf_term = OpenStudio::Model::ZoneHVACTerminalUnitVariableRefrigerantFlow.new(model)
      #ac_vrf_term.setHeatingCoil(vrf_htg)
      ac_vrf_term.addToThermalZone(zone)
      ac_vrf_term.setOutdoorAirFlowRateDuringCoolingOperation(0.0)
      ac_vrf_term.setOutdoorAirFlowRateDuringHeatingOperation(0.0)
      ac_vrf_term.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(0.0)
      ac_vrf.addTerminal(ac_vrf_term)
      #set load priority for the vrf, assuming there is a doas system
      model.getZoneHVACEquipmentLists.each do |zoneHVACEquipmentList|
        if zoneHVACEquipmentList.thermalZone == zone
          zoneHVACEquipmentList.setCoolingPriority(ac_vrf_term, 2.0.to_i)
          zoneHVACEquipmentList.setHeatingPriority(ac_vrf_term, 2.0.to_i)
        end
      end
      #set coil COP
      ac_vrf.setRatedCoolingCOP(3.7)
      ac_vrf.setRatedHeatingCOP(4.2)
      #SET HEAT RECOVERY

      ac_vrf.setHeatPumpWasteHeatRecovery(true)
      #puts "ac_vrf.setHeatPumpWasteHeatRecovery(true) #{ac_vrf.setHeatPumpWasteHeatRecovery(true)}"
      #puts "ac_vrf_term #{ac_vrf_term}"
      #puts "ac_vrf_term #{ac_vrf_term.coolingCoil.get}"
      #puts "ac_vrf_term #{ac_vrf_term.heatingCoil.get}"
    end #list_of_vrf_zones.each do|zone|
  end

  def autosize_affected_hvac(model, zones)
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

# register the measure to be used by the application
NrcDOASVRF.new.registerWithApplication
