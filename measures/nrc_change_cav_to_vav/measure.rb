# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcChangeCAVToVAV < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)

  # human readable name
  def name
    return "NrcChangeCAVToVAV"
  end

  # human readable description
  def description
    return "This measure turns constant air volume (CAV) to variable air volume (VAV) systems. This measure will automatically skip air loops
            that already contain a VAV fan."
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure loops through every AirLoopHVAC object and replaces the CAV fan with a VAV fan (OS default efficiency), and sets a new setpoint:warmest
             if the original air loop uses a scheduled or SingleZoneReheat setpoint manager (or other managers as selected by the user)"
  end

  #Use the constructor to set global variables
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    user_defined_spm = OpenStudio::StringVector.new
    user_defined_spm << "SPM_multizone_cooling_average"
    user_defined_spm << "SPM_multizone_heating_average" 
    user_defined_spm << "SPM_warmest"  
    user_defined_spm << "SPM_coldest"  
    user_defined_spm << "Default" 
    @measure_interface_detailed = [
        {
            "name" => "airLoopSelected",
            "type" => "String",
            "display_name" => "Enter name of air loops (separated in commas) to switch from CAV to VAV, 'AllAirLoops', or 'SkipAllAirLoops'",
            "default_value" => "AllAirLoops",
            "is_required" => true
        },
        {
          "name" => "user_defined_spm",
          "type" => "Choice",
          "display_name" => "Enter a sepoint manager to be used",
          "default_value" => "Default",
          "choices" => user_defined_spm,
          "is_required" => true
      }      
      ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    #Runs parent run method.
    super(model, runner, user_arguments)

    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    airLoopSelected = runner.getStringArgumentValue('airLoopSelected', user_arguments)
    user_defined_spm = runner.getStringArgumentValue('user_defined_spm', user_arguments)
    if airLoopSelected == "SkipAllAirLoops"
      runner.registerInfo("NrcChangeCAVToVAV is skipped")
    elsif airLoopSelected == "AllAirLoops"
      runner.registerInfo("NrcChangeCAVToVAV is being run")

      all_air_loops = model.getAirLoopHVACs
      air_loops_to_change = []

      # select air loops to change (non vav loops)
      all_air_loops.each do |airloop|
        found_vav_fan = false
        # loop through components on supply side of air loop to identify fan type (skip loop if it's a vav fan)
        airloop.supplyComponents.each do |supply_component| 
          if not supply_component.to_Node.is_initialized # only look at components (ignore nodes)
            if supply_component.to_FanVariableVolume.is_initialized
              found_vav_fan = true
            elsif supply_component.to_FanSystemModel.is_initialized
              fan_system_model = supply_component.to_FanSystemModel.get  
              if fan_system_model.speedControlMethod.to_s.downcase == 'continuous' or
                (fan_system_model.speedControlMethod.to_s.downcase == 'discrete' and fan_system_model.numberofSpeeds.to_i > 1) 
                found_vav_fan = true
              end
            end
          end # not supply_component.to_Node.is_initialized 
        end # airloop.supplyComponents.each do |supply_component| 
        if not found_vav_fan 
          air_loops_to_change << airloop
        end
      end # all_air_loops.each do |airloop|

      # loop through the air loops that should be changed and make the change
      air_loops_to_change.each do |air_loop|
        heating_coil_flag = false
        cooling_coil_flag = false
        const_fan_flag = false
        reheat_terminal_flag = false
        need_sched_setpointmanager = false
        fan_component_index = 1
        always_on = model.alwaysOnDiscreteSchedule
        const_fan = 1
        htg_coil = 1
        clg_coil = 1
        #Go through each component of the air loop, changes are based on combination of components
        air_loop.supplyComponents.each do |supply_component| #loop thru each component in the supply side of the loop
          if supply_component.to_FanConstantVolume.is_initialized #true if there is a constant fan, set the const_fan_flag to true
            const_fan_flag = true
            const_fan = supply_component.to_FanConstantVolume.get
          elsif supply_component.to_FanSystemModel.is_initialized
            fan_system_model = supply_component.to_FanSystemModel.get  
            if fan_system_model.speedControlMethod.to_s.downcase == 'discrete' and fan_system_model.numberofSpeeds.to_i == 1 
              const_fan_flag = true
              const_fan = fan_system_model
            end
          elsif not supply_component.to_CoilHeatingDesuperheater.empty? or not supply_component.to_CoilHeatingDXMultiSpeed.empty? or #check if it's a heating coil
              not supply_component.to_CoilHeatingDXMultiSpeedStageData.empty? or not supply_component.to_CoilHeatingDXSingleSpeed.empty? or
              not supply_component.to_CoilHeatingDXVariableRefrigerantFlow.empty? or not supply_component.to_CoilHeatingDXVariableSpeed.empty? or
              not supply_component.to_CoilHeatingDXVariableSpeedSpeedData.empty? or not supply_component.to_CoilHeatingElectric.empty? or
              not supply_component.to_CoilHeatingFourPipeBeam.empty? or not supply_component.to_CoilHeatingGas.empty? or
              not supply_component.to_CoilHeatingGasMultiStage.empty? or not supply_component.to_CoilHeatingGasMultiStageStageData.empty? or
              not supply_component.to_CoilHeatingLowTempRadiantConstFlow.empty? or not supply_component.to_CoilHeatingLowTempRadiantVarFlow.empty? or
              not supply_component.to_CoilHeatingWater.empty? or not supply_component.to_CoilHeatingWaterBaseboard.empty? or
              not supply_component.to_CoilHeatingWaterBaseboardRadiant.empty? or not supply_component.to_CoilHeatingWaterToAirHeatPumpEquationFit.empty? or
              not supply_component.to_CoilHeatingWaterToAirHeatPumpVariableSpeedEquationFit.empty? or not supply_component.to_CoilHeatingWaterToAirHeatPumpVariableSpeedEquationFitSpeedData.empty?
            not supply_component.to_CoilWaterHeatingAirToWaterHeatPump.empty? or not supply_component.to_CoilWaterHeatingAirToWaterHeatPumpWrapped.empty? or
                not supply_component.to_CoilWaterHeatingDesuperheater.empty? or not supply_component.to_HeatPumpWaterToWaterEquationFitHeating.empty?
            heating_coil_flag = true
            htg_coil = supply_component
          elsif not supply_component.to_CoilCoolingCooledBeam.empty? or not supply_component.to_CoilCoolingDXMultiSpeed.empty? or #check if it's a cooling coil
              not supply_component.to_CoilCoolingDXMultiSpeedStageData.empty? or not supply_component.to_CoilCoolingDXSingleSpeed.empty? or
              not supply_component.to_CoilCoolingDXTwoSpeed.empty? or not supply_component.to_CoilCoolingDXTwoStageWithHumidityControlMode.empty? or
              not supply_component.to_CoilCoolingDXVariableRefrigerantFlow.empty? or not supply_component.to_CoilCoolingDXVariableSpeed.empty? or
              not supply_component.to_CoilCoolingDXVariableSpeedSpeedData.empty? or not supply_component.to_CoilCoolingFourPipeBeam.empty? or
              not supply_component.to_CoilCoolingLowTempRadiantConstFlow.empty? or not supply_component.to_CoilCoolingLowTempRadiantVarFlow.empty? or
              not supply_component.to_CoilCoolingWater.empty? or not supply_component.to_CoilCoolingWaterToAirHeatPumpEquationFit.empty? or
              not supply_component.to_CoilCoolingWaterToAirHeatPumpVariableSpeedEquationFit.empty? or not supply_component.to_CoilCoolingWaterToAirHeatPumpVariableSpeedEquationFitSpeedData.empty? or
              not supply_component.to_CoilPerformanceDXCooling.empty? or not supply_component.to_CoilSystemCoolingDXHeatExchangerAssisted.empty? or
              not supply_component.to_CoilSystemCoolingWaterHeatExchangerAssisted.empty? or not supply_component.to_HeatPumpWaterToWaterEquationFitCooling.empty?
            cooling_coil_flag = true
            clg_coil = supply_component
          end # if not supply_component.to_FanConstantVolume.empty?
        end #end of air_loop.supplyComponents.each do |supply_component|

        # there's heating, cooling, and a constant fan 1) fan, 2) setpoint, 3) terminal
        if const_fan_flag && heating_coil_flag && cooling_coil_flag
          #switch setpoint manager from singlezonereheat to warmest
          if not air_loop.supplyOutletNode.to_Node.empty? #if there's a node
            node = air_loop.supplyOutletNode.to_Node.get
            if not air_loop.supplyOutletNode.to_Node.get.setpointManagers.empty? #if the node has setpoint managers
              
              #remove the const fan as well and add the vav
              new_vav_fan = OpenStudio::Model::FanVariableVolume.new(model, always_on)
              new_vav_fan.setName("#{air_loop.name} new VAV fan")
              new_vav_fan.setPressureRise(const_fan.pressureRise)
              new_vav_fan.autosizeMaximumFlowRate
              new_vav_fan.setFanPowerMinimumFlowRateInputMethod("Fraction")
              new_vav_fan.setFanPowerMinimumFlowFraction(0.3)
              new_vav_fan.setMotorInAirstreamFraction(1.0)
              new_vav_fan.setFanPowerCoefficient1(0.0407598940)
              new_vav_fan.setFanPowerCoefficient2(0.08804497)
              new_vav_fan.setFanPowerCoefficient3(-0.072926120)
              new_vav_fan.setFanPowerCoefficient4(0.9437398230)
              new_vav_fan.setFanPowerCoefficient5(0.0)
              const_fan.remove
              new_vav_fan.addToNode(node)

              setpoint_manager_found = air_loop.supplyOutletNode.to_Node.get.setpointManagers[0] #.setpointManagers method returns an array
              new_setpoint_manager = ""
              if user_defined_spm == 'SPM_warmest'
                #remove the setpoint manager
                setpoint_manager_found.remove
                new_setpoint_manager = OpenStudio::Model::SetpointManagerWarmest.new(model)
                new_setpoint_manager.setControlVariable("Temperature")
                new_setpoint_manager.setMinimumSetpointTemperature(13)
                new_setpoint_manager.setMaximumSetpointTemperature(35)
                new_setpoint_manager.setStrategy("MaximumTemperature")
              elsif user_defined_spm == 'SPM_multizone_cooling_average'
                setpoint_manager_found.remove
                new_setpoint_manager = OpenStudio::Model::SetpointManagerMultiZoneCoolingAverage.new(model)
                new_setpoint_manager.setMinimumSetpointTemperature(13)
                new_setpoint_manager.setMaximumSetpointTemperature(35)
              elsif user_defined_spm == 'SPM_multizone_heating_average'
                setpoint_manager_found.remove
                new_setpoint_manager = OpenStudio::Model::SetpointManagerMultiZoneHeatingAverage.new(model)
                new_setpoint_manager.setMinimumSetpointTemperature(13)
                new_setpoint_manager.setMaximumSetpointTemperature(35)
              elsif user_defined_spm == 'SPM_coldest'
                setpoint_manager_found.remove
                new_setpoint_manager = OpenStudio::Model::SetpointManagerColdest.new(model)
                new_setpoint_manager.setControlVariable("Temperature")
                new_setpoint_manager.setMinimumSetpointTemperature(13)
                new_setpoint_manager.setMaximumSetpointTemperature(35)
              elsif user_defined_spm == 'Default' and (setpoint_manager_found.to_SetpointManagerSingleZoneReheat.is_initialized or 
                 setpoint_manager_found.to_SetpointManagerScheduled.is_initialized)
                #remove the setpoint manager
                setpoint_manager_found.remove
                puts "air_loop.supplyOutletNode.to_Node.get.setpointManagers[0] #{air_loop.supplyOutletNode.to_Node.get.setpointManagers[0]}"
                new_setpoint_manager = OpenStudio::Model::SetpointManagerWarmest.new(model)
                new_setpoint_manager.setControlVariable("Temperature")
                new_setpoint_manager.setMinimumSetpointTemperature(13)
                new_setpoint_manager.setMaximumSetpointTemperature(35)
                new_setpoint_manager.setStrategy("MaximumTemperature")
              end
              
              #set the node as the setpoint for this manager
              a = new_setpoint_manager.addToNode(node)
              #set heating coil setpoints
              if not htg_coil.to_CoilHeatingElectric.empty?
                coil = htg_coil.to_CoilHeatingElectric.get
                coil.setTemperatureSetpointNode(node)
              end
              puts "a #{a}"
              puts "node #{node}"
              puts "air_loop.supplyOutletNode #{air_loop.supplyOutletNode}"
            end #if not air_loop.supplyOutletNode.to_Node.get.setpointManagers.empty?
          end #not air_loop.supplyOutletNode.to_Node.empty?
          #end of switch setpoint manager from singlezonereheat to warmest

          #Go through each terminal connected to this air loop and remove it if it's uncontrolled
          model.getThermalZones.each do |zone| #start by identifying the current terminals attached to zones that are connected to this air loop
            if zone.airLoopHVAC.get == air_loop
              current_term = zone.airLoopHVACTerminal.get
              #puts "before #{air_loop.zoneSplitter.branchIndexForOutletModelObject(current_term)}"
              if not current_term.to_AirTerminalSingleDuctUncontrolled.empty? #if it's an uncontrolled terminal, replace with vav no reheat terminal
                #get heaitng/cooling priority, serach for the matching zoneHVACEquipmentList
                cool_priority = 1
                heat_priority = 1
                this_zone_eqp_list_index = 1
                term_branch_index = air_loop.zoneSplitter.branchIndexForOutletModelObject(current_term)
                model.getZoneHVACEquipmentLists.each_with_index do |zoneHVACEquipmentList, index|
                  if zoneHVACEquipmentList.thermalZone == zone
                    cool_priority = zoneHVACEquipmentList.coolingPriority(current_term)
                    heat_priority = zoneHVACEquipmentList.heatingPriority(current_term)
                    this_zone_eqp_list_index = index
                  end
                end
                #remove terminal
                current_term.to_StraightComponent.get.remove
                air_loop.removeBranchForZone(zone)
                #create new vav terminal
                new_vav_term = OpenStudio::Model::AirTerminalSingleDuctVAVHeatAndCoolNoReheat.new(model)
                new_vav_term.setName("#{zone.name.to_s} vav terminal")
                new_vav_term.setAvailabilitySchedule(always_on)
                new_vav_term.autosizeMaximumAirFlowRate
                new_vav_term.setZoneMinimumAirFlowFraction(0.3)
                #find space's designspecificationoutdooraiobject, set to controller false
                #new_vav_term.setControlForOutdoorAir(false) #
                #model.getSpaces.each do |space|
                #  if space.thermalZone.get == zone
                #    if not space.designSpecificationOutdoorAir.empty?
                #new_vav_term.setControlForOutdoorAir(true)
                #    end
                #  end
                #end
                #add the branch and zone to the air loop
                air_loop.addBranchForZone(zone, new_vav_term.to_StraightComponent)
                #set cooling/heating priority to be the same as the deleted terminal
                this_zone_eqp_list = model.getZoneHVACEquipmentLists[this_zone_eqp_list_index]
                this_zone_eqp_list.setCoolingPriority(new_vav_term, cool_priority)
                this_zone_eqp_list.setHeatingPriority(new_vav_term, heat_priority)
                #puts "after #{air_loop.zoneSplitter.branchIndexForOutletModelObject(new_vav_term)}"
              end # end of if not current_term.to_AirTerminalSingleDuctUncontrolled.empty?
            end # end if zone.airLoopHVAC.get == air_loop
          end #end model.getThermalZones.each do |zone|
          #End of Go through each terminal connected to this air loop and remove it if it's uncontrolled
         
        end #if const_fan_flag && heating_coil_flag && cooling_coil_flag
        #End there's heating, cooling, and a constant fan
      end # end of air_loops_to_change.each do |air_loop|



    end # end of if airLoopSelected == "All Air Loops"
    return true
  end
end


# register the measure to be used by the application
NrcChangeCAVToVAV.new.registerWithApplication
