# Start the measure
require_relative 'resources/NRCReportingMeasureHelper'
require 'erb'

# start the measure
class NrcPricingMeasure < OpenStudio::Measure::ReportingMeasure

  attr_accessor :use_json_package, :use_string_double
  
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCReportingMeasureHelper)
  
  # Human readable name
  def name
    return "Pricing Measure"
  end

  # Human readable description
  def description
    return "Measure creates a template csv file for pricing building components."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "Measure creates a template csv file for pricing building components."
  end
  
  # Define the outputs that the measure will create. These are single numbers (generally).
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new
	#outs << "EquipmentSummary"
    return outs
  end

  # Return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # Warning: Do not change the name of this method to be snake_case. The method must be lowerCamelCase.
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    requests = OpenStudio::IdfObjectVector.new

    # Use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return requests
    end

    #request = OpenStudio::IdfObject.load('Output:Variable,,Site Outdoor Air Drybulb Temperature,Hourly;').get
    #requests << request

    return requests
  end
  
  # Use the constructor to set global variables
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = true

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
        {
            "name" => "Lighting",
            "type" => "Bool",
            "display_name" => "Include interior lighting",
            "default_value" => true,
            "is_required" => true
        }
    ]
  end

  # Define what happens when the measure is run
  def run(runner, user_arguments)
  
    # Runs parent run method.
    super(runner, user_arguments)
	
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(runner, user_arguments)
	
    #puts JSON.pretty_generate(arguments)
    return false if false == arguments
	
    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    @sql_file = runner.lastEnergyPlusSqlFile
    if @sql_file.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    @sql_file = @sql_file.get
    model.setSqlFile(@sql_file)

    # Generate output for the html file. Will be written at the end of the method.
    # Put data into the local variable 'output', all local variables are 
	# available for erb to use when configuring the input html file.
    output = "<h1>Pricing report</h1>" 
	building = model.getBuilding
    output << "Building Name = #{building.name.get}<br>" 
	buildingFloorArea = building.floorArea
    output << "Floor Area = #{buildingFloorArea}<br>" 
    output << "Floor to Floor Height = #{building.nominalFloortoFloorHeight} (m)<br>"
	if @sql_file.netSiteEnergy.is_initialized then site_energy_GJ = @sql_file.netSiteEnergy.to_f else site_energy_GJ = 0.0 end
	site_energy_kWh = 277.7777 * site_energy_GJ/buildingFloorArea
    output << "Net Site Energy = #{site_energy_GJ} (GJ) = #{site_energy_kWh} (kWh)<br>"

    # Get list of thermal zones and spaces for use in generating pricing template csv file.
	zones = model.getThermalZones
	spaces = model.getSpaces
	
	# Lighting - use spaces for this
	csv = "Lighting\n"
	csv << " Space, Area (m2), Fixture type, Ceiling height (m), LPD (W/m2), Fixture count\n"
	totalFloorArea = 0
	spaces.each do |space|
	  if space.partofTotalFloorArea then
	    floorArea = space.floorArea * space.multiplier
	    totalFloorArea = totalFloorArea + floorArea
	    ceilingHeight = 0
	    lpd = space.lightingPowerPerFloorArea
	    csv << "#{space.name}, #{floorArea.to_f.signif}, LED, #{ceilingHeight.to_f.signif}, #{lpd.to_f.signif}\n"
	  end
    end
	if (totalFloorArea - buildingFloorArea).abs > 0.1 then 
	  csv << "Error in total floor area #{totalFloorArea.to_f.signif} compares to building floor area #{buildingFloorArea.to_f.signif}\n"
	end
	
	# Windows + Skylights + Walls
	areasByConstruction = Hash.new(0.0) # Empty hash with default value of 0.0 for entries
	puts "Ext surface area #{building.exteriorSurfaceArea}".green
	puts "Ext wall area #{building.exteriorWallArea}".green
	building.exteriorWalls.each do |surface|
	  construction = surface.construction.get
	  areasByConstruction.update({construction.name.to_s => surface.netArea}) {|key, v1, v2 | v1+v2}
	  surface.subSurfaces.each do |subSurface|
	    construction = subSurface.construction.get
	    areasByConstruction.update({construction.name.to_s => subSurface.netArea}) {|key, v1, v2 | v1+v2}
	  end
	end
	building.roofs.each do |roof|
	  construction = roof.construction.get
	  areasByConstruction.update({construction.name.to_s => roof.netArea}) {|key, v1, v2 | v1+v2}
	  roof.subSurfaces.each do |skylight|
	    construction = skylight.construction.get
	    areasByConstruction.update({construction.name.to_s => skylight.netArea}) {|key, v1, v2 | v1+v2}
	  end
	end
	
	# Generate lists of constructions for csv file.
	wall_csv = ""
	window_csv = ""
	areasByConstruction.each do |key, value|
	  puts "#{key}, #{value}".red
	  construction = model.getModelObjectByName(key).get.to_Construction.get
	  if construction.isOpaque then
	    layers = construction.layers
		layer_description = ""
		layers.each do |material|
		  layer_description << "#{(material.thickness * 1000).signif}mm #{material.name};"
		end
	    wall_csv << "#{key}, #{value.to_f.signif}, #{layer_description}, #{construction.thermalConductance.to_f.signif} \n"
	  elsif construction.isFenestration then
	    layers = construction.layers
		layer_description = ""
		layers.each do |material|
		  layer_description << "#{(material.thickness * 1000).signif}mm #{material.name};"
		end
		shgc = 0.0
		if layers[0].to_SimpleGlazing.is_initialized then
		  shgc = layers[0].to_SimpleGlazing.get.solarHeatGainCoefficient
		end
	    window_csv << "#{key}, #{value.to_f.signif}, #{layer_description}, #{construction.uFactor.to_f.signif}, #{shgc.signif} \n"
	  else
	    csv << "Unknown construction"
	  end
	end
	
	# Write to csv
	csv << "\nWindows and Skylights\n"
	csv << "Name, Area (m2), Construction descripton, Uvalue (W/m2K), SHGC (-)\n"
	csv << window_csv
	csv << "\nWalls and roof\n"
	csv << "Name, Area (m2), Construction descripton, Uvalue (W/m2K)\n"
	csv << wall_csv
	
	# HVAC
	# Keep track of components that we do not check for.
	unresolvedComponents = ""
	
	# Zone Equipment (Looping through the OS data model here. Could maybe just extract what is in the SQL file)
	# See: https://openstudio-sdk-documentation.s3.amazonaws.com/cpp/OpenStudio-3.0.1-doc/model/html/classopenstudio_1_1model_1_1_zone_h_v_a_c_component.html
	# Not sure what equipment will be in the model.
	# Store the equipment in a hash using the equuipment type as the key. This was when producing the output
	# we can loop through the keys in the hash and just dump the strings built up for each equipment type.
	zoneEquipment = Hash.new()
	nItem = 0
	zones.each do |zone|
	  zone.equipment.each do |device|
		#
		# ZoneHVACBaseboardConvectiveWater
		#
	    if device.to_ZoneHVACBaseboardConvectiveWater.is_initialized then
		  current = zoneEquipment[:ZoneHVACBaseboardConvectiveWater]
		  #puts "Current: #{current}".light_blue
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nHydronic baseboards\n"]
		    current += ["Zone, Flow (m3/s), UA (W/K)\n"]
		  end
		  itemName = device.idfObject.name.get
		  component = "ZoneHVAC:Baseboard:Convective:Water"
		  itemFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Maximum Water Flow Rate', 
									  units = 'm3/s')
		  itemUA = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size U-Factor Times Area Value', 
									  units = 'W/K')
		  
		  # Merge the new data into the hash.
		  current += ["#{zone.name}, #{itemFlow.signif}, #{itemUA.signif}\n"]
		  zoneEquipment.merge!({ZoneHVACBaseboardConvectiveWater: current})
		#
		# ZoneHVACBaseboardConvectiveElectric
		#
	    elsif device.to_ZoneHVACBaseboardConvectiveElectric.is_initialized then
		  current = zoneEquipment[:ZoneHVACBaseboardConvectiveElectric]
		  #puts "Current: #{current}".light_blue
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nElectric baseboards\n"]
		    current += ["Zone, Flow (m3/s), UA (W/K)\n"]
		  end
		  itemName = device.idfObject.name.get
		  component = "ZoneHVAC:Baseboard:Convective:Electric"
		  itemPower = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Maximum Water Flow Rate', 
									  units = 'W') # *** This will fail. Need an example sql file.
		  
		  # Merge the new data into the hash.
		  current += ["#{zone.name}, #{itemPower.signif}n"]
		  zoneEquipment.merge!({ZoneHVACBaseboardConvectiveElectric: current})
		#
		# to_AirTerminalSingleDuctConstantVolumeNoReheat
		#
	    elsif device.to_AirTerminalSingleDuctConstantVolumeNoReheat.is_initialized then
		  current = zoneEquipment[:AirTerminalSingleDuctConstantVolumeNoReheat]
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nAir Terminals (Single duct; Constant volume; no reheat)\n"]
		    current += ["Zone, Flow (m3/s)\n"]
		  end
		  itemName = device.idfObject.name.get
		  component = "AirTerminal:SingleDuct:ConstantVolume:NoReheat"
		  itemFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Maximum Air Flow Rate', 
									  units = 'm3/s')					  
		  
		  # Merge the new data into the hash.
		  current += ["#{zone.name}, #{itemFlow.signif}\n"]
		  zoneEquipment.merge!({AirTerminalSingleDuctConstantVolumeNoReheat: current})
		#
		# AirTerminalSingleDuctVAVNoReheat
		#
	    elsif device.to_AirTerminalSingleDuctVAVNoReheat.is_initialized then
		  current = zoneEquipment[:AirTerminalSingleDuctVAVNoReheat]
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nAir Terminals (Single duct; VAV; no reheat)\n"]
		    current += ["Zone, Flow (m3/s)\n"]
		  end
		  itemName = device.idfObject.name.get
		  component = "AirTerminal:SingleDuct:VAV:NoReheat" # Not sure this is right ir required
		  itemFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Maximum Air Flow Rate', 
									  units = 'm3/s')
          #reheat = device.to_AirTerminalSingleDuctVAVNoReheat.reheatCoil
		  #reheat = reheat.to
		  
		  # Merge the new data into the hash.
		  current += ["#{zone.name}, #{itemFlow.signif}\n"]
		  zoneEquipment.merge!({AirTerminalSingleDuctVAVNoReheat: current})
		#
		# AirTerminalSingleDuctVAVReheat
		#
	    elsif device.to_AirTerminalSingleDuctVAVReheat.is_initialized then
		  current = zoneEquipment[:AirTerminalSingleDuctVAVReheat]
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nAir Terminals (Single duct; VAV; with reheat)\n"]
		    current += ["Zone, Flow (m3/s)\n"]
		  end
		  itemName = device.idfObject.name.get
		  component = "AirTerminal:SingleDuct:VAV:Reheat" # Not sure this is right ir required
		  itemFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Maximum Air Flow Rate', 
									  units = 'm3/s')
          #reheat = device.to_AirTerminalSingleDuctVAVReheat.reheatCoil
		  #reheat = reheat.to
		  
		  # Merge the new data into the hash.
		  current += ["#{zone.name}, #{itemFlow.signif}\n"]
		  zoneEquipment.merge!({AirTerminalSingleDuctVAVReheat: current})
		#
		# ZoneHVACFourPipeFanCoil
		#
	    elsif device.to_ZoneHVACFourPipeFanCoil.is_initialized then
		  current = zoneEquipment[:ZoneHVACFourPipeFanCoil]
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nFour Pipe Fan Coil\n"]
		    current += ["Zone, Air Flow (m3/s), Water Flow (m3/s), Heating capacity (W), Cooling capacity (W), Fan efficiency (W/W)\n"]
		  end
		  itemName = device.idfObject.name.get
		  # Need air and water flow (heat and cool); capacilty (heat and cool); fan and motor efficiency
		  component = "Coil:Cooling:Water" 
		  coolingCoilName = device.to_ZoneHVACFourPipeFanCoil.get.coolingCoil.name
		  heatingCoilName = device.to_ZoneHVACFourPipeFanCoil.get.heatingCoil.name
		  fanName = device.to_ZoneHVACFourPipeFanCoil.get.supplyAirFan.name
		  airFlowUser = getComponentSizing(table = component, 
									  row = coolingCoilName.to_s.upcase, 
		                              column = 'User-Specified Design Air Flow Rate', 
									  units = 'm3/s')
		  airFlowDesign = getComponentSizing(table = component, 
									  row = coolingCoilName.to_s.upcase, 
		                              column = 'Design Size Design Air Flow Rate', 
									  units = 'm3/s')
		  airFlow = [airFlowUser, airFlowDesign].max
		  waterFlowCool = getComponentSizing(table = component, 
									  row = coolingCoilName.to_s.upcase, 
		                              column = 'Design Size Design Water Flow Rate', 
									  units = 'm3/s')
									  
		  component = "Coil:Heating:Water" 
		  waterFlowHeat = getComponentSizing(table = component, 
									  row = heatingCoilName.to_s.upcase, 
		                              column = 'Design Size Design Water Flow Rate', 
									  units = 'm3/s')
		  waterFlow = [waterFlowCool, waterFlowHeat].max
									  
		  component = "Cooling Coils" 
		  coolCapacity = getComponentSizing(report = 'EquipmentSummary',
		                              table = component, 
									  row = coolingCoilName.to_s.upcase, 
		                              column = 'Nominal Total Capacity', 
									  units = 'W') 
									  
		  component = "Heating Coils" 
		  heatCapacity = getComponentSizing(report = 'EquipmentSummary',
		                              table = component, 
									  row = heatingCoilName.to_s.upcase, 
		                              column = 'Nominal Total Capacity', 
									  units = 'W')
		  
		  fanEff = getComponentSizing(report = 'EquipmentSummary',
		                              table = 'Fans', 
									  row = fanName.to_s.upcase, 
		                              column = 'Total Efficiency', 
									  units = 'W/W')
									  
		  # Merge the new data into the hash.
		  current += ["#{itemName}, #{airFlow.to_f.signif}, #{waterFlow.to_f.signif}, #{heatCapacity.to_f.signif}, #{coolCapacity.to_f.signif}, #{fanEff.to_f.signif}\n"]
		  zoneEquipment.merge!({ZoneHVACFourPipeFanCoil: current})
		#
		# ZoneHVACPackagedTerminalAirConditioner (PTAC)
		#
	    elsif device.to_ZoneHVACPackagedTerminalAirConditioner.is_initialized then
		  current = zoneEquipment[:ZoneHVACPackagedTerminalAirConditioner]
		  
		  # If the first entry then define the title/column headings
		  if current == nil then
		    current = ["\nAir PTAC\n"]
		    current += ["Zone, Air Flow (m3/s), Cooling Type, Cooling Capacity [W], COP, EER, SEER, IEER, Heating Type, Heating Capacity [W], Fan Type, Fan Efficiency [-], Pressure Rise [Pa] \n"]
		  end
		  itemName = device.idfObject.name.get
		  component = "ZoneHVAC:PackagedTerminalAirConditioner"   
		  
		  # Air flow rate.
		  heatFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Heating Supply Air Flow Rate', 
									  units = 'm3/s')  
		  coolFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size Cooling Supply Air Flow Rate', 
									  units = 'm3/s')
		  noLoadFlow = getComponentSizing(table = component, 
									  row = itemName.to_s.upcase, 
		                              column = 'Design Size No Load Supply Air Flow Rate', 
									  units = 'm3/s')
		  itemFlow = [heatFlow, coolFlow, noLoadFlow].max
		  
		  # Recover heating/cooling coil and fan names.
		  item = device.to_ZoneHVACPackagedTerminalAirConditioner.get
		  heatingName = item.heatingCoil.name
		  coolingName = item.coolingCoil.name
		  fanName = item.supplyAirFan.name
		  
          heatingType = getComponentName(report = 'EquipmentSummary', 
									  table = '',
									  row = heatingName.to_s.upcase, 
		                              column = 'Type', 
									  units = '')
          heatingSize = getComponentSizing(report = 'EquipmentSummary', 
									  table = '',
									  row = heatingName.to_s.upcase, 
		                              column = 'Nominal Total Capacity', 
									  units = 'W')
          coolingType = getComponentName(report = 'EquipmentSummary', 
									  table = '',
									  row = coolingName.to_s.upcase, 
		                              column = 'Type', 
									  units = '')
          coolingSize = getComponentSizing(report = 'EquipmentSummary', 
									  table = '',
									  row = coolingName.to_s.upcase, 
		                              column = 'Nominal Total Capacity', 
									  units = 'W')
          coolingCOP = getComponentSizing(report = 'EquipmentSummary', 
									  table = '',
									  row = coolingName.to_s.upcase, 
		                              column = 'Standard Rated Net COP', 
									  units = 'W/W')
          coolingEER = getComponentSizing(report = 'EquipmentSummary', 
									  table = '',
									  row = coolingName.to_s.upcase, 
		                              column = 'EER', 
									  units = 'Btu/W-h')
          coolingSEER = getComponentSizing(report = 'EquipmentSummary', 
									  table = '',
									  row = coolingName.to_s.upcase, 
		                              column = 'SEER', 
									  units = 'Btu/W-h')
          coolingIEER = getComponentSizing(report = 'EquipmentSummary', 
									  table = '',
									  row = coolingName.to_s.upcase, 
		                              column = 'IEER', 
									  units = 'Btu/W-h')
          fanType = getComponentName(report = 'EquipmentSummary', 
		                              table = 'Fans',
									  row = fanName.to_s.upcase, 
		                              column = 'Type', 
									  units = '')
          fanEff = getComponentSizing(report = 'EquipmentSummary', 
		                              table = 'Fans',
									  row = fanName.to_s.upcase, 
		                              column = 'Total Efficiency', 
									  units = 'W/W')
          fanPRise = getComponentSizing(report = 'EquipmentSummary', 
		                              table = 'Fans',
									  row = fanName.to_s.upcase, 
		                              column = 'Delta Pressure', 
									  units = 'pa')
									  
		  # Merge the new data into the hash.
		  current += ["#{zone.name}, #{itemFlow.signif}, #{coolingType}, #{coolingSize.signif}, #{coolingCOP.signif}, #{coolingEER.signif}, #{coolingSEER.signif}, #{coolingIEER.signif}, #{heatingType}, #{heatingSize.signif}, #{fanType}, #{fanEff.signif(2)}, #{fanPRise.signif}\n"]
		  zoneEquipment.merge!({ZoneHVACPackagedTerminalAirConditioner: current})
		else
	      warn =  "Warning: Did not recover sizing info for: #{device.name}"
	      puts warn.yellow
		  unresolvedComponents << "Zone HVAC: #{warn}\n"
		end
	  end
    end
		
	# Loop through the zoneEquipment hash to produce tables for pricing
	zoneEquipment.each do |key, value|
	  value.each do |text|
	    csv << text
	  end
	end
	
	
	# Air loops. Define table headings
	ahu = "\nAir Handling Units\n"
	ahu << "AHU, Cooling Coil, Standard Rating Cooling Capacity, Standard Rated Net COP [W/W], "
	ahu << "Heating Type, Nominal Total Capacity, "
	ahu << "Fan Type, Total Efficiency [W/W], Delta Pressure [pa], Max Air Flow Rate [m3/s], Rated Electric Power [W], "
	ahu << "Economizer Control, ERV Design Flow Rate (m3/s), Efficiency (Sensible 100% air flow; Latent 100%; Sensible 75%; Latent 75%)\n"
	ahuFans = "\nAir Handling Unit Fans\n"
	ahuCoils = "\nAir Handling Unit Water Coils\n"
	airLoops = model.getAirLoopHVACs
	airLoops.each do |loop|
	  ahuName = "AHU: #{loop.name}"
	  	  
	  # Define empty entries for the supply components
	  cooling = ",,"
	  heating = ","
	  fan = ",,,,"
	  fan2 = ""
	  nFans = 0
	  economizer = ",,"
	  coilCooling = ""
	  coilHeating = ""
	  components = loop.supplyComponents
	  components.each do |component|
		if !component.to_Node.is_initialized then
		  #
		  # Fan - Constant volume
		  #
		  if component.to_FanConstantVolume.is_initialized then
		    totalEff = component.to_FanConstantVolume.get.fanTotalEfficiency
		    motorEff = component.to_FanConstantVolume.get.motorEfficiency
		    pressureRise = component.to_FanConstantVolume.get.pressureRise
		    itemFlow = getComponentSizing(table = 'Fan:ConstantVolume', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Maximum Flow Rate', 
									  units = 'm3/s')
		    itemPower = getComponentSizing(report = 'EquipmentSummary',
			                          table = 'Fans', 
									  row = component.name.to_s.upcase, 
		                              column = 'Rated Electric Power', 
									  units = 'W')
			if nFans == 0 then
			  nFans+= 1
			  fan = "Constant Volume Fan, #{totalEff.signif}, #{pressureRise.signif}, #{itemFlow.signif}, #{itemPower.signif}"
			else
			  fan2 = "Constant Volume Fan, #{totalEff.signif}, #{pressureRise.signif}, #{itemFlow.signif}, #{itemPower.signif}"
			end
		  #
		  # Fan - Variable volume
		  #
		  elsif component.to_FanVariableVolume.is_initialized then
		    totalEff = component.to_FanVariableVolume.get.fanTotalEfficiency
		    motorEff = component.to_FanVariableVolume.get.motorEfficiency
		    pressureRise = component.to_FanVariableVolume.get.pressureRise
		    itemFlow = getComponentSizing(table = 'Fan:VariableVolume', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Maximum Flow Rate', 
									  units = 'm3/s')
		    itemPower = getComponentSizing(report = 'EquipmentSummary',
			                          table = 'Fans', 
									  row = component.name.to_s.upcase, 
		                              column = 'Rated Electric Power', 
									  units = 'W')
			if nFans == 0 then
			  nFans+= 1
			  fan = "Variable Volume Fan, #{totalEff.signif}, #{pressureRise.signif}, #{itemFlow.signif}, #{itemPower.signif}"
			else
			  fan2 = "Variable Volume Fan, #{totalEff.signif}, #{pressureRise.signif}, #{itemFlow.signif}, #{itemPower.signif}"
			end
		  #
		  # DX Cooling Coil
		  #
		  elsif component.to_CoilCoolingDXSingleSpeed.is_initialized then
		    itemCapacity = getComponentSizing(table = 'Coil:Cooling:DX:SingleSpeed', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Gross Rated Total Cooling Capacity', 
									  units = 'W')
			itemCapacity = itemCapacity * 0.000284345 # Convert to tons
			copOptional = component.to_CoilCoolingDXSingleSpeed.get.ratedCOP
			cop = 0
			if copOptional.is_initialized || !copOptional.empty? then
			  cop = copOptional.get
			end
			cooling = "Single Stage DX, #{itemCapacity.signif} ton, #{cop.signif}"
		  #
		  # Water Cooling Coil
		  #
		  elsif component.to_CoilCoolingWater.is_initialized then
		    itemFlow = getComponentSizing(report = 'HVACSizingSummary', 
			                          table = 'Coil Sizing Summary', 
									  row = component.name.to_s.upcase, 
		                              column = 'Coil Final Reference Plant Fluid Volume Flow Rate', 
									  units = 'm3/s')
			cooling = "Water, #{itemFlow.signif} m3/s, "
		  #
		  # Fan - Heating Coil Gas
		  #
		  elsif component.to_CoilHeatingGas.is_initialized then
		    itemCapacity = getComponentSizing(table = 'Coil:Heating:Fuel', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Nominal Capacity', 
									  units = 'W')
			itemCapacity = itemCapacity * 3.41 # To BTU/hr
		    heating = "Gas Heating, #{itemCapacity.signif} BTU/hr"
		  #
		  # OA System
		  #
		  elsif component.to_AirLoopHVACOutdoorAirSystem.is_initialized then
		    #Need to do an extra jump here to get the heat recovery and economiser data.
			oaSystem = component.to_AirLoopHVACOutdoorAirSystem.get
			oaController = oaSystem.getControllerOutdoorAir
			crtl = "#{oaController.getEconomizerControlType}"
			oaObjects = oaSystem.oaComponents
			oaObjects.each do |oaComponent|
			  # Find the HRV/ERV
		      if !oaComponent.to_Node.is_initialized then
			    if oaComponent.to_HeatExchangerAirToAirSensibleAndLatent.is_initialized then
                  comp = oaComponent.to_HeatExchangerAirToAirSensibleAndLatent.get
                  sc100 = comp.sensibleEffectivenessat100CoolingAirFlow
                  sh100 = comp.sensibleEffectivenessat100HeatingAirFlow
                  sc75 = comp.sensibleEffectivenessat75CoolingAirFlow
                  sh75 = comp.sensibleEffectivenessat75HeatingAirFlow
                  puts comp.latentEffectivenessat100CoolingAirFlow
                  puts comp.latentEffectivenessat100HeatingAirFlow
                  puts comp.latentEffectivenessat75CoolingAirFlow
                  puts comp.latentEffectivenessat75HeatingAirFlow
		          itemFlow = getComponentSizing(table = 'HeatExchanger:AirToAir:SensibleAndLatent', 
									  row = oaComponent.name.to_s.upcase, 
		                              column = 'Design Size Nominal Supply Air Flow Rate', 
									  units = 'm3/s')
				  economizer = "#{crtl}, #{itemFlow.signif}, #{sc100}, #{sh100}, #{sc75}, #{sh75}"
                else
                  warn = "Unresolved OA component #{oaComponent.name}"
                  puts warn.yellow
                  unresolvedComponents << "OA Component: #{warn}\n"
			    end
			  end
			end
		  #
		  # Coil - Cooling Water
		  #
		  elsif component.to_CoilCoolingWater.is_initialized then
		    itemCapacity = getComponentSizing(table = 'Coil:Cooling:Water', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Design Coil Load', 
									  units = 'W')
		    itemWaterFlow = getComponentSizing(table = 'Coil:Cooling:Water', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Design Water Flow Rate', 
									  units = 'm3/s')
		    coilCooling = "Coil - Cooling Water, #{itemCapacity.signif}, #{itemWaterFlow.signif}"
		  #
		  # Coil - Heating Water
		  #
		  elsif component.to_CoilHeatingWater.is_initialized then
		    itemCapacity = getComponentSizing(table = 'Coil:Heating:Water', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Rated Capacity', 
									  units = 'W')
		    itemWaterFlow = getComponentSizing(table = 'Coil:Heating:Water', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Maximum Water Flow Rate', 
									  units = 'm3/s')
		    itemUA = getComponentSizing(table = 'Coil:Heating:Water', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size U-Factor Times Area Value', 
									  units = 'W/K')
		    coilHeating = "Coil - Heating Water, #{itemCapacity.signif}, #{itemWaterFlow.signif}, #{itemUA.signif}"
		  else
		    warn = "Unresolved AHU component #{component.name}"
	        puts warn.yellow
		    unresolvedComponents << "AHU Component: #{warn}\n"
		  end
		end
	  end
	  ahu << "#{ahuName}, #{cooling}, #{heating}, #{fan}, #{economizer}\n"
	  if !fan2.empty? then 
	    ahu << ",,,,,, #{fan2}\n"
	  end
	  #ahuFans << "#{fan}\n"
	  #ahuFans << "#{fan2}\n"
	  #ahuCoils << "#{coilCooling}\n#{coilHeating}\n"
	end
	
	# Finally add the ahu data to the csv data.
	csv << ahu
	csv << ahuFans
	
	# Now loop through the plant loops. Will need to store items in a hash.
	plantEquipment = Hash.new()
	plant = "Water loops\n"
	plant << "Loop\n"
	plantLoops = model.getPlantLoops
	plantLoops.each do |loop|
	  puts "Plant loop: #{loop.name}".yellow
	  components = loop.supplyComponents
	  components.each do |component|
	     # Skip the nodes and deal with the other components explicitly
		if !component.to_Node.is_initialized then
		  puts "#{component.name}".light_blue
		  # First deal with the ones we ignore.
		  if component.to_ConnectorSplitter.is_initialized then
		    next
		  elsif component.to_ConnectorMixer.is_initialized then
		    next
		  elsif component.to_PipeAdiabatic.is_initialized then
		    next
		  elsif component.to_PumpConstantSpeed.is_initialized then
		    comp = component.to_PumpConstantSpeed.get
			compType = "Constant Speed Pumps"
		    current = plantEquipment[:PumpConstantSpeed]
			
		    # If the first entry then define the title/column headings
		    if current == nil then
		      current = ["\n#{compType}\n"]
		      current += ["Pump, Head (Pa), Water Flow (m3/s), Electric Power (W), Power per Flow (Ws/m3), Motor Efficiency (-)\n"]
		    end
			head = comp.ratedPumpHead
			flow = getComponentSizing(table = 'Pump:ConstantSpeed', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Design Flow Rate', 
									  units = 'm3/s')
			power = getComponentSizing(table = 'Pump:ConstantSpeed', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Design Power Consumption', 
									  units = 'W')
			powerPerFlow = power/flow
			efficiency = comp.motorEfficiency
		    current += ["#{comp.name}, #{head.signif}, #{flow.signif}, #{power.signif}, #{powerPerFlow.signif}, #{efficiency.signif(2)}\n"]
		    plantEquipment.merge!({PumpConstantSpeed: current})
		  elsif component.to_PumpVariableSpeed.is_initialized then
		    comp = component.to_PumpVariableSpeed.get
			compType = "Variable Speed Pumps"
		    current = plantEquipment[:PumpVariableSpeed]
			
		    # If the first entry then define the title/column headings
		    if current == nil then
		      current = ["\n#{compType}\n"]
		      current += ["Pump, Head (Pa), Water Flow (m3/s), Electric Power (W), Power per Flow (Ws/m3), Motor Efficiency (-)\n"]
		    end
			head = comp.ratedPumpHead
			flow = getComponentSizing(table = 'Pump:VariableSpeed', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Design Flow Rate', 
									  units = 'm3/s')
			power = getComponentSizing(table = 'Pump:VariableSpeed', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Design Power Consumption', 
									  units = 'W')
			powerPerFlow = power/flow
			efficiency = comp.motorEfficiency
		    current += ["#{comp.name}, #{head.signif}, #{flow.signif}, #{power.signif}, #{powerPerFlow.signif}, #{efficiency.signif(2)}\n"]
		    plantEquipment.merge!({PumpVariableSpeed: current})
		  elsif component.to_BoilerHotWater.is_initialized then
		    comp = component.to_BoilerHotWater.get
			compType = "Hot Water Boilers"
		    current = plantEquipment[:BoilerHotWater]
			
		    # If the first entry then define the title/column headings
		    if current == nil then
		      current = ["\n#{compType}\n"]
		      current += ["Boiler, Capacity [W], Efficiency [-]\n"]
		    end
			heaterCapacity = getComponentSizing(report = 'EquipmentSummary',
			                          table = 'Central Plant', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Nominal Capacity', 
									  units = 'W')
			if heaterCapacity.to_f > 0 then
			  eff = getComponentSizing(report = 'EquipmentSummary',
			                          table = 'Central Plant', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Nominal Efficiency', 
									  units = 'W/W')
		      current += ["#{comp.name}, #{heaterCapacity.signif}, #{eff.signif}\n"]
		      plantEquipment.merge!({BoilerHotWater: current})
			end
		  elsif component.to_WaterHeaterMixed.is_initialized then
		    comp = component.to_WaterHeaterMixed.get
			compType = "Water Heaters - Mixed"
		    current = plantEquipment[:WaterHeaterMixed]
			
		    # If the first entry then define the title/column headings
		    if current == nil then
		      current = ["\n#{compType}\n"]
		      current += ["Water Heater - Mixed, Volume (m3), Capacity (W), Standard Rated Recovery Efficiency (-), Standard Rated Energy Factor (-), Use Side Design Flow Rate (m3/s)\n"]
		    end
			volume = comp.tankVolume.get # Returns an optional but I think it will always be set.
			heaterCapacity = comp.heaterMaximumCapacity.get
			ratedRecovery = comp.indirectWaterHeatingRecoveryTime
			ratedEnergyFactor = "EnergyFactor"
			useSideFlow = getComponentSizing(table = 'WaterHeater:Mixed', 
									  row = comp.name.to_s.upcase, 
		                              column = 'Use Side Design Flow Rate', 
									  units = 'm3/s')
		    current += ["#{comp.name}, #{volume.signif}, #{heaterCapacity.signif}, #{ratedRecovery.signif}, #{ratedEnergyFactor}, #{useSideFlow.signif}\n"]
		    plantEquipment.merge!({WaterHeaterMixed: current})
		  #
		  # Chiller - EIR
		  #
		  elsif component.to_ChillerElectricEIR.is_initialized then 
		    comp = component.to_ChillerElectricEIR.get
			compType = "Chiller - EIR"
		    current = plantEquipment[:ChillerEIR]
			
		    # If the first entry then define the title/column headings
		    if current == nil then
		      current = ["\n#{compType}\n"]
		      current += ["Chiller, Type, Cooling capacity, COP"]
		    end
		    itemCapacity = getComponentSizing(table = 'Coil:Heating:Water', 
									  row = component.name.to_s.upcase, 
		                              column = 'Design Size Nominal Capacity', 
									  units = 'W')
		    itemCapacity = itemCapacity * 0.000284345 # Convert to tons
			cop = comp.referenceCOP
			current += ["#{comp.name}, EIR, #{itemCapacity.signif} tons, #{cop.signif}\n"]
		    plantEquipment.merge!({ChillerEIR: current})
		  #
		  # Cooling tower
		  #
		  elsif component.to_CoolingTowerSingleSpeed.is_initialized then 
		    comp = component.to_CoolingTowerSingleSpeed.get
			compType = "Cooling Tower - Single Speed"
		    current = plantEquipment[:CoolingTowerSS]
			
		    # If the first entry then define the title/column headings
		    if current == nil then
		      current = ["\n#{compType}\n"]
		      current += ["Cooling Tower, Air Flow (cfm), Water Flow (gal/min)"]
		    end
		    #itemCapacity = getComponentSizing(table = 'Coil:Heating:Water', 
			#						  row = component.name.to_s.upcase, 
		    #                          column = 'Design Size Nominal Capacity', 
			#						  units = 'W')
		    #itemCapacity = itemCapacity * 0.000284345 # Convert to tons
			#cop = comp.referenceCOP
			current += ["#{comp.name}, air flow, water flow\n"]
		    plantEquipment.merge!({CoolingTowerSS: current})
		  else
            warn = "Unresolved plant loop component #{component.name}"
            puts warn.yellow
            unresolvedComponents << "Plant loop: #{warn}\n"
		  end
		end
	  end
	end
	
	# Loop through the plantEquipment hash to produce tables for pricing
	plantEquipment.each do |key, value|
	  value.each do |text|
	    csv << text
	  end
	end
	
	
    # Write csv file.
    csv_out_path = './pricing_template.csv'
    File.open(csv_out_path, 'w') do |file|
      file << csv
      # make sure data is written to the disk one way or the other.
      begin
        file.fsync
      rescue StandardError
        file.flush
      end
    end

    # Write txt file for unresolved components.
    txt_out_path = './pricing_warnings.txt'
    File.open(txt_out_path, 'w') do |file|
      file << unresolvedComponents
      # make sure data is written to the disk one way or the other.
      begin
        file.fsync
      rescue StandardError
        file.flush
      end
    end



    # Read in template
    #html_in_path = "#{File.dirname(__FILE__)}/resources/report.html.in"
    #html_in = ''
    #File.open(html_in_path, 'r') do |file|
    #  html_in = file.read
    #end

    # Configure template with variable values
    #renderer = ERB.new(html_in)
    #html_out = renderer.result(binding)

    # Write html file
    #html_out_path = './report.html'
    #File.open(html_out_path, 'w') do |file|
    #  file << html_out
      # make sure data is written to the disk one way or the other
    #  begin
    #    file.fsync
    #  rescue StandardError
    #    file.flush
    #  end
    #end

    # Close the sql file
    @sql_file.close
	
    return true
  end
  
  # SQL queries
  # Recover data from table "tabulardatawithstrings
  def getComponentSizing(report = 'ComponentSizingSummary', 
                         scope = 'Entire Facility', 
						 table, row, column, units)

	# Generate the SQL query
	query = "SELECT Value 
          FROM tabulardatawithstrings
          WHERE ReportName='#{report}'
          AND ReportForString='#{scope}'\n"
    if !table.empty? then 
      query << "AND TableName='#{table}'\n"
	end
	query << "AND RowName='#{row}'
          AND ColumnName='#{column}'
          AND Units='#{units}'" 
		  
    # Execute the query and check the return value.
	val = @sql_file.execAndReturnFirstDouble(query)
	if val.is_initialized then 
	  val = val.get 
	else 
	  puts "ERROR: SQL read failed to find a value with query\n#{query}".red		 
	  val = 0.0 
	end
	return val
  end
  def getComponentName(report = 'ComponentSizingSummary', 
                         scope = 'Entire Facility', 
						 table, row, column, units)

	# Generate the SQL query
	query = "SELECT Value 
          FROM tabulardatawithstrings
          WHERE ReportName='#{report}'
          AND ReportForString='#{scope}'\n"
    if !table.empty? then 
      query << "AND TableName='#{table}'\n"
	end
	query << "AND RowName='#{row}'
          AND ColumnName='#{column}'
          AND Units='#{units}'" 
		  
    # Execute the query and check the return value.
	val = @sql_file.execAndReturnFirstString(query)
	if val.is_initialized then 
	  val = val.get 
	else 
	  puts "ERROR: SQL read failed to find a value with query\n#{query}".red		 
	  val = ""
	end
	return val
  end
end

# register the measure to be used by the application
NrcPricingMeasure.new.registerWithApplication
