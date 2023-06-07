require 'json'
require_relative '../measure.rb'

module OsLib_Reporting
  # setup - get model, sql, and setup web assets path
  def self.setup(runner)
    results = {}

    # get the last model
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    # get the last idf
    workspace = runner.lastEnergyPlusWorkspace
    if workspace.empty?
      runner.registerError('Cannot find last idf file.')
      return false
    end
    workspace = workspace.get

    # get the last sql file
    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

    # populate hash to pass to measure
    results[:model] = model
    # results[:workspace] = workspace
    results[:sqlFile] = sqlFile
    results[:web_asset_path] = OpenStudio.getSharedResourcesPath / OpenStudio::Path.new('web_assets')
    return results
  end

  def self.ann_env_pd(sqlFile)
    # get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      env_type = sqlFile.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new('WeatherRunPeriod')
          ann_env_pd = env_pd
        end
      end
    end
    return ann_env_pd
  end

  # hard code fuel types (for E+ 9.4 shouldn't have it twice, should eventually come form OS)
  def self.fuel_type_names(extended = false)
    # get short or extended list (not using now)
    fuel_types = []
    OpenStudio::EndUseFuelType.getValues.each do |fuel_type|
      # convert integer to string
      fuel_name = OpenStudio::EndUseFuelType.new(fuel_type).valueDescription
      next if fuel_name == 'Water'
      fuel_types << fuel_name
    end
    return fuel_types
  end

  # cleanup - prep html and close sql
  def self.cleanup(html_in_path)
    return html_out_path
  end

  # clean up unkown strings used for runner.registerValue names
  def self.reg_val_string_prep(string)
    # replace non alpha-numberic characters with an underscore
    string = string.gsub(/[^0-9a-z]/i, '_')
    # snake case string
    string = OpenStudio.toUnderscoreCase(string)
    return string
  end

  # create model summary section
  def self.model_summary_section(model, sqlFile, runner, name_only = false)
    model_summary_data_table = {}
    model_summary_data_table[:title] = ''
    model_summary_data_table[:header] = ["Parameter", "Value"]
    model_summary_data_table[:units] = ['', '']
    model_summary_data_table[:data] = []

    # gather data for section
    @model_summary_table_section = {}
    @model_summary_table_section[:title] = 'Model Summary'
    @model_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @model_summary_table_section
    end

    # wwr = window_area_total/(model.getBuilding.exteriorWallArea)
    #srr = skylight_area_total/(model.getBuilding.exteriorSurfaceArea-model.getBuilding.exteriorWallArea)

    version = OpenStudio.openStudioVersion

    model_summary_data_table[:data] << ["Location", model.getWeatherFile.city]
    model_summary_data_table[:data] << ["Standard building type", model.getBuilding.standardsBuildingType]
    model_summary_data_table[:data] << ["Reference code", model.getBuilding.standardsTemplate]
    model_summary_data_table[:data] << ["Total floor area {m2}", model.getBuilding.floorArea.to_f.signif(3)]
    model_summary_data_table[:data] << ["Conditioned floor area {m2}", model.getBuilding.conditionedFloorArea.to_f.signif(3)]
    model_summary_data_table[:data] << ["Number of floors", model.getBuilding.standardsNumberOfStories]
    model_summary_data_table[:data] << ["Number of thermal zones", model.getBuilding.thermalZones.count]
    model_summary_data_table[:data] << ["Number of spaces", model.getBuilding.spaces.count]
    model_summary_data_table[:data] << ["Number of HVAC air loops", model.getAirLoopHVACs.count]

    # Report the infiltration as a flow rate per exterior surface area at 75 Pa
    sum_infiltration_rate = 0
    model.getSpaceInfiltrationDesignFlowRates.each do |spaceInfiltrationDesignFlowRate|
      sum_infiltration_rate = sum_infiltration_rate + spaceInfiltrationDesignFlowRate.flowperExteriorWallArea.get
    end
    puts "model.getSpaceInfiltrationDesignFlowRates.length #{model.getSpaceInfiltrationDesignFlowRates.length}"
    building_average_infiltration_rate_per_ext_wall_area_5Pa = sum_infiltration_rate/(model.getSpaceInfiltrationDesignFlowRates.length)
    puts "building_average_infiltration_rate_per_ext_wall_area_5Pa #{building_average_infiltration_rate_per_ext_wall_area_5Pa}"

    # Calculate total area of above and below grade envelope area.
    ext_surf_area = 0.0 #  Walls, roofs, floors, above and below grade
    ext_surf_above_grade_area = 0.0 #  Walls, roofs, floors, above grade
    ext_wall_above_grade_area = 0.0 # Walls above grade
    model.getSpaces.each do |space|
      multiplier = space.multiplier
      space.surfaces.each do |surface|
        if surface.outsideBoundaryCondition == "Outdoors" then
          area = surface.grossArea * multiplier
          ext_surf_area += area
          ext_surf_above_grade_area += area
          if surface.surfaceType == 'Wall'
            ext_wall_above_grade_area += area
          end
        elsif surface.outsideBoundaryCondition == "Ground" then
          area = surface.grossArea * multiplier
          ext_surf_area += area
        end
      end
    end

    puts "ext_wall_above_grade_area #{ext_wall_above_grade_area}"
    puts "ext_surf_area #{ext_surf_area}"
    # Calculate infiltration per exterior envelope area at 75pa
    building_average_infiltration_rate_per_ext_surface_area_75Pa = building_average_infiltration_rate_per_ext_wall_area_5Pa*ext_wall_above_grade_area/ext_surf_area/((5.0/75.0)**0.6) 
    puts "building_average_infiltration_rate_per_ext_surface_area_75Pa #{building_average_infiltration_rate_per_ext_surface_area_75Pa}"
    model_summary_data_table[:data] << ["Average Infiltration_per_ext_envelope_area_75Pa_(m3/s/m2)", building_average_infiltration_rate_per_ext_surface_area_75Pa]

    if model_summary_data_table[:data].size > 0
      @model_summary_table_section[:tables] = [model_summary_data_table] # only one table for this section
    else
      @model_summary_table_section[:tables] = []
    end

    return @model_summary_table_section
  end

  # create Server summary section
  def self.server_summary_section(model, sqlFile, runner, name_only = false)
    server_summary_data_table = {}
    server_summary_data_table[:title] = ''
    server_summary_data_table[:header] = ["Parameter", "Value"]
    server_summary_data_table[:units] = ['', '']
    server_summary_data_table[:data] = []

    # gather data for section
    @server_summary_table_section = {}
    @server_summary_table_section[:title] = 'Server summary'
    @server_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @server_summary_table_section
    end

    # wwr = window_area_total/(model.getBuilding.exteriorWallArea)
    #srr = skylight_area_total/(model.getBuilding.exteriorSurfaceArea-model.getBuilding.exteriorWallArea)

    version = OpenStudio.openStudioVersion
    dir = Gem.dir # "D:/gems/openstudio/bundle/ruby/2.5.0"
    path = Gem.path #	["D:/gems/openstudio/bundle/ruby/2.5.0"]

    server_summary_data_table[:data] << ["Open Studio Version", version]
    server_summary_data_table[:data] << ["Gem Path", dir]
    # Gems version and path
    gems = Gem::Specification.group_by(&:name)
    gems.each do |name, specs|
      versions = []
      specs.sort.each do |spec|
        server_summary_data_table[:data] << ["#{name}_#{spec.version}", spec.spec_dir]
      end
    end

    # gather data for section
    @server_summary_table_section = {}
    @server_summary_table_section[:title] = 'Server summary'
    @server_summary_table_section[:data] = []

    if server_summary_data_table[:data].size > 0
      @server_summary_table_section[:tables] = [server_summary_data_table] # only one table for this section
    else
      @server_summary_table_section[:tables] = []
    end

    return @server_summary_table_section
  end

  # create model summary section
  def self.serviceHotWater_summary_section(model, sqlFile, runner, name_only = false)
    serviceHotWater_summary_data_table = {}
    serviceHotWater_summary_data_table[:title] = ''
    serviceHotWater_summary_data_table[:header] = ["Parameter", "Value"]
    serviceHotWater_summary_data_table[:units] = ['', '']
    serviceHotWater_summary_data_table[:data] = []

    # gather data for section
    @serviceHotWater_summary_table_section = {}
    @serviceHotWater_summary_table_section[:title] = 'Service Hot Water'
    @serviceHotWater_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @serviceHotWater_summary_table_section
    end

    model.getPlantLoops.each do |plantloop|
      plantloop_name = plantloop.name.to_s
      if plantloop.name.to_s.include?("Service Water")
        plantloop.supplyComponents.each do |comp|
          if comp.iddObject.name.include? "OS:WaterHeater:Mixed"
            serviceWaterheater_component = comp.to_WaterHeaterMixed.get
            serviceWaterheater_capacity_W = serviceWaterheater_component.heaterMaximumCapacity.get
            serviceWaterheater_volume_m3 = serviceWaterheater_component.tankVolume.get
            setpoint_schedule = serviceWaterheater_component.setpointTemperatureSchedule.get
            ambient_T_schedule = serviceWaterheater_component.ambientTemperatureSchedule.get
            heaterFuelType = serviceWaterheater_component.heaterFuelType
            heaterThermalEfficiency = serviceWaterheater_component.heaterThermalEfficiency.get
            deadbandTemperatureDifference = serviceWaterheater_component.deadbandTemperatureDifference
            maximumTemperatureLimit = serviceWaterheater_component.maximumTemperatureLimit
            serviceHotWater_summary_data_table[:data] << ["Plant Loop", plantloop_name]
            serviceHotWater_summary_data_table[:data] << ["Service Water Heater Capacity {kW}", (serviceWaterheater_capacity_W / 1000).round(2)]
            serviceHotWater_summary_data_table[:data] << ["Service Water Heater Volume {m3}", serviceWaterheater_volume_m3.round(2)]
            serviceHotWater_summary_data_table[:data] << ["Setpoint Schedule Name", setpoint_schedule.name.to_s]
            serviceHotWater_summary_data_table[:data] << ["Ambient Schedule Name", ambient_T_schedule.name.to_s]
            serviceHotWater_summary_data_table[:data] << ["Heater Thermal Efficiency", heaterThermalEfficiency]
            serviceHotWater_summary_data_table[:data] << ["Heater Fuel Type", heaterFuelType]
            serviceHotWater_summary_data_table[:data] << ["Deadband Temperature Difference {deltaC}", deadbandTemperatureDifference]
            serviceHotWater_summary_data_table[:data] << ["Maximum Temperature Limit {C}", maximumTemperatureLimit]
          end
        end
      end
    end

    if serviceHotWater_summary_data_table[:data].size > 0
      @serviceHotWater_summary_table_section[:tables] = [serviceHotWater_summary_data_table] # only one table for this section
    else
      @serviceHotWater_summary_table_section[:tables] = []
    end

    return @serviceHotWater_summary_table_section
  end

  # create interior_lighting section from BCL Openstudio measure
  def self.interior_lighting_summary_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    interior_lighting_tables = []

    # gather data for section
    @interior_lighting_section = {}
    @interior_lighting_section[:title] = 'Interior Lighting Summary'
    @interior_lighting_section[:tables] = interior_lighting_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @interior_lighting_section
    end

    # data for query
    report_name = 'LightingSummary'
    table_name = 'Interior Lighting'
    columns = ['Lights ', 'Zone', 'Lighting Power Density', 'Total Power', 'Schedule Name', 'Scheduled Hours/Week', 'Actual Load Hours/Week', 'Return Air Fraction', 'Annual Consumption']
    columns_query = ['', 'Zone', 'Lighting Power Density', 'Total Power', 'Schedule Name', 'Scheduled Hours/Week', 'Full Load Hours/Week', 'Return Air Fraction', 'Consumption']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    rows = []
    row_names.each do |row_name|
      next if row_name == 'Interior Lighting Total' # skipping this on purpose, may give odd results in some instances
      rows << row_name
    end

    # Zone-level Lighting Summary
    table = {}
    table[:title] = 'Zone Lighting'
    table[:header] = columns
    source_units_area = "m^2"
    source_units_lpd = 'W/m^2'
    source_units_energy = 'GJ'

    target_units_area = "m^2"
    target_units_lpd = 'W/m^2'
    target_units_energy = 'kWh'

    table[:source_units] = ['', '', source_units_lpd, 'W', '', 'hr', 'hr', '', source_units_energy] # used for conversion, not needed for rendering.
    table[:units] = ['', '', target_units_lpd, 'W', '', 'hr', 'hr', '', target_units_energy]
    table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if table[:source_units][column_counter] != ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, table[:source_units][column_counter], table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      table[:data] << row_data
    end

    # add tables to report
    interior_lighting_tables << table
    return @interior_lighting_section
  end

  # create interior_lighting detail section (from BCL Openstudio measure)
  def self.interior_lighting_detail_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    interiorDetail_lighting_tables = []

    # gather data for section
    @interior_lightingDetail_section = {}
    @interior_lightingDetail_section[:title] = 'Interior Lighting Detail'
    @interior_lightingDetail_section[:tables] = interiorDetail_lighting_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @interior_lightingDetail_section
    end

    # Space-level lighting loads table(s)
    space_lighting_table = {}
    space_lighting_table[:title] = 'Space Lighting Details'
    space_lighting_table[:header] = ['Load Name', 'Definition Name', 'Load Type', 'Load (units)', 'Multiplier', 'Total Load (W)']
    space_lighting_table[:data] = []

    source_units_area = "m^2"
    source_units_lpd = 'W/m^2'
    source_units_energy = 'GJ'

    target_units_area = "m^2"
    target_units_lpd = 'W/m^2'
    target_units_energy = 'kWh'

    spaces = model.getSpaces
    spaces.each do |space|
      table_row = []
      area = OpenStudio.convert(space.floorArea, source_units_area, target_units_area).get
      lp = OpenStudio.convert(space.lightingPowerPerFloorArea, source_units_lpd, target_units_lpd).get

      space_lighting_table[:data] << [{ sub_header: "Space Name: '#{space.name}', Area: #{area.round(0)} #{target_units_area},
                                        Total LPD: #{lp.round(2)} #{target_units_lpd}" }, '', '', '', '', '']

      lights_found = 0

      if space.spaceType.is_initialized

        space.spaceType.get.lights.each do |lights_object|
          tlp = ''
          def_name = lights_object.lightsDefinition.name

          lights_found += 1

          if lights_object.lightsDefinition.designLevelCalculationMethod == 'LightingLevel'

            val = "#{lights_object.lightsDefinition.lightingLevel.to_f.round(0)} (W)"
            tlp = lights_object.lightsDefinition.lightingLevel.to_f * lights_object.multiplier

          end

          if lights_object.lightsDefinition.designLevelCalculationMethod == 'Watts/Area'

            val_conv = OpenStudio::convert(lights_object.lightsDefinition.wattsperSpaceFloorArea.to_f, source_units_lpd, target_units_lpd).get
            val = "#{val_conv.to_f.round(2)} (#{target_units_lpd})"
            tlp = (lights_object.lightsDefinition.wattsperSpaceFloorArea.to_f * space.floorArea) * lights_object.multiplier

          end

          if lights_object.lightsDefinition.designLevelCalculationMethod == 'Watts/Person'

            val = "#{lights_object.lightsDefinition.wattsperPerson.to_f.round(2)} (W/Person)"
            tlp = (lights_object.lightsDefinition.wattsperPerson.to_f * space.numberOfPeople) * lights_object.multiplier

          end

          space_lighting_table[:data] << [lights_object.name.to_s, def_name, 'Spacetype', val, lights_object.multiplier.round(0), tlp.round(0)]
        end
      end

      space.lights.each do |sl|
        tlp = ''
        def_name = sl.lightsDefinition.name

        lights_found += 1

        if sl.lightsDefinition.designLevelCalculationMethod == 'LightingLevel'

          val = "#{sl.lightsDefinition.lightingLevel.to_f.round(0)} (W)"
          tlp = sl.lightsDefinition.lightingLevel.to_f * sl.multiplier

        end

        if sl.lightsDefinition.designLevelCalculationMethod == 'Watts/Area'

          val_conv = OpenStudio::convert(sl.lightsDefinition.wattsperSpaceFloorArea.to_f, source_units_lpd, target_units_lpd).get
          val = "#{val_conv.to_f.round(2)} (#{target_units_lpd})"
          tlp = (sl.lightsDefinition.wattsperSpaceFloorArea.to_f * space.floorArea) * sl.multiplier

        end

        if sl.lightsDefinition.designLevelCalculationMethod == 'Watts/Person'

          val = "#{sl.lightsDefinition.wattsperPerson.to_f.round(2)} (W/Person)"
          tlp = (sl.lightsDefinition.wattsperPerson.to_f * space.numberOfPeople) * sl.multiplier

        end

        space_lighting_table[:data] << [sl.name.to_s, def_name, 'Space', val, sl.multiplier.round(0), tlp.round(0)]
      end

      space_lighting_table[:data] << ['-', '-', '-', '-', '-', '-'] if lights_found == 0
    end

    # add tables to report
    interiorDetail_lighting_tables << space_lighting_table
    return @interior_lightingDetail_section
  end

  # Create daylighting section from BCL Openstudio measure.
  def self.daylighting_summary_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    daylighting_tables = []

    # gather data for section
    @daylighting_section = {}
    @daylighting_section[:title] = 'Day Lighting Control Summary'
    @daylighting_section[:tables] = daylighting_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @daylighting_section
    end

    source_units_illuminance = 'lux'
    target_units_illuminance = source_units_illuminance

    lighting_controls_table = {}
    lighting_controls_table[:title] = 'Lighting Controls Details'
    lighting_controls_table[:header] = ['Space Name', 'Control Name', 'Zone Controlled (type, fraction)', "Illuminance Setpoint (#{target_units_illuminance})"]
    lighting_controls_table[:data] = []
    model.getSpaces.sort.each do |space|
      thermal_zone = space.thermalZone.get

      zone_control = 'n/a'

      space.daylightingControls.each do |dc|
        if thermal_zone.primaryDaylightingControl.is_initialized && dc.isPrimaryDaylightingControl
          zone_control = "#{thermal_zone.name} (primary, #{thermal_zone.fractionofZoneControlledbyPrimaryDaylightingControl.round(1)})"
        end
        if thermal_zone.secondaryDaylightingControl.is_initialized && dc.isSecondaryDaylightingControl
          zone_control = "#{thermal_zone.name} (secondary, #{thermal_zone.fractionofZoneControlledbySecondaryDaylightingControl.round(1)})"
        end
        illuminance_conv = OpenStudio.convert(dc.illuminanceSetpoint, source_units_illuminance, target_units_illuminance).get
        lighting_controls_table[:data] << [space.name, dc.name, zone_control, illuminance_conv.round(0)]
      end
    end

    # add tables to report
    daylighting_tables << lighting_controls_table

    return @daylighting_section
  end

  # Create table for exterior lights from BCL Openstudio measure
  def self.exterior_light_section(model, sqlFile, runner, name_only = false)
    # Exterior Lighting from output

    # gather data for section
    @ext_light_data_section = {}
    @ext_light_data_section[:title] = 'Exterior Lighting'

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @ext_light_data_section
    end

    # data for query
    report_name = 'LightingSummary'
    table_name = 'Exterior Lighting'
    columns = ['Description', 'Total Power', 'Astronomical', 'Schedule Name', 'Annual Consumption']
    columns_query = ['', 'Total Watts', 'Astronomical Clock/Schedule', 'Schedule Name', 'Consumption']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    rows = []
    row_names.each do |row_name|
      rows << row_name
    end

    # Zone-level Lighting Summary
    table = {}
    table[:title] = 'Exterior Lighting'
    table[:header] = columns
    table[:source_units] = ['', 'W', '', '', 'GJ'] # used for conversion, not needed for rendering.
    table[:units] = ['', 'W', '', '', 'kWh']
    table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if table[:source_units][column_counter] != ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, table[:source_units][column_counter], table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end

      table[:data] << row_data
    end

    # don't create empty table
    if table[:data].size > 0
      @ext_light_data_section[:tables] = [table] # only one table for this section
    else
      @ext_light_data_section[:tables] = []
    end

    return @ext_light_data_section
  end

  # Create table for Shading Summary
  def self.shading_summary_section(model, sqlFile, runner, name_only = false)

    # array to hold tables
    shading_tables = []

    # gather data for shading Summary section
    @shading_summary_section = {}
    @shading_summary_section[:title] = 'Shading Summary'
    @shading_summary_section[:tables] = shading_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @shading_summary_section
    end
    # data for Shading Summary query
    report_name = 'ShadingSummary'
    table_name = 'Sunlit Fraction'
    columns = ['Description', 'March 21 9am', 'March 21 noon', 'March 21 3pm', 'June 21 9am', 'June 21 noon', 'June 21 3pm', 'December 21 9am', 'December 21 noon', 'December 21 3pm']
    columns_query = ['', 'March 21 9am', 'March 21 noon', 'March 21 3pm', 'June 21 9am', 'June 21 noon', 'June 21 3pm', 'December 21 9am', 'December 21 noon', 'December 21 3pm']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    rows = []
    row_names.each do |row_name|
      rows << row_name
    end

    # Zone-level Lighting Summary
    table = {}
    table[:title] = 'Sunlit Fraction'
    table[:header] = columns
    table[:source_units] = ['', '', '', '', '', '', '', '', '', '']
    table[:units] = ['', '', '', '', '', '', '', '', '', '']
    table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name} and RowName= '#{row}' and ColumnName= '#{header}'"
        if table[:source_units][column_counter] != ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, table[:source_units][column_counter], table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end

      table[:data] << row_data
    end

    ###############################################
    # data for Window Control query
    report_name = 'ShadingSummary'
    reportForString = 'Entire Facility'
    table_name = 'Window Control'
    columns = ['Description', 'Name', 'Type', 'Shaded Construction', 'Control', 'Glare Control']
    columns_query = ['', 'Name', 'Type', 'Shaded Construction', 'Control', 'Glare Control']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and ReportForString='#{reportForString}' and TableName='#{table_name}'"
    w_row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    w_rows = []
    w_row_names.each do |row_name|
      w_rows << row_name
    end

    # Window Control Summary
    windowControlTable = {}
    windowControlTable[:title] = 'Window Control'
    windowControlTable[:header] = columns
    windowControlTable[:source_units] = ['', '', '', '', '', '']
    windowControlTable[:units] = ['', '', '', '', '', '']
    windowControlTable[:data] = []

    # run query and populate table
    w_rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and ReportForString='#{reportForString}' and TableName='#{table_name} and RowName= '#{row}' and ColumnName= '#{header}'"
        if windowControlTable[:source_units][column_counter] != ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, windowControlTable[:source_units][column_counter], windowControlTable[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end

      windowControlTable[:data] << row_data
    end
    # add tables to report
    shading_tables << table
    shading_tables << windowControlTable

    return @shading_summary_section
  end

  def self.output_data_end_use_table(model, sqlFile, runner, name_only = false)
    output_data_end_use = {}
    output_data_end_use[:title] = 'End Use'
    output_data_end_use[:header] = ['End Use', 'Consumption', 'Percentage']
    output_data_end_use[:units] = ['', 'kWh', '%']
    output_data_end_use[:data] = []
    totalEndUse = 0.0
    # gather data for section
    @output_data_end_use_table_section = {}
    @output_data_end_use_table_section[:title] = 'End Use summary'
    @output_data_end_use_table_section[:data] = []
    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @output_data_end_use_table_section
    end

    # loop through fuels for consumption tables
    counter = 0
    totalEndUse = 0.0

    OpenStudio::EndUseCategoryType.getValues.each do |end_use|
      # get end uses
      end_use = OpenStudio::EndUseCategoryType.new(end_use).valueDescription
      # loop through fuels
      total_end_use = 0.0
      fuel_type_names.each do |fuel_type|
        query_fuel = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='AnnualBuildingUtilityPerformanceSummary' and TableName='End Uses' and RowName= '#{end_use}' and ColumnName= '#{fuel_type}'"
        if query_fuel.empty?
          runner.registerWarning('Did not find value for #{fuel_type} .')
          return false
        else
          results_fuel = sqlFile.execAndReturnFirstDouble(query_fuel).get
          total_end_use += results_fuel
        end
      end

      # convert value and populate table
      value = OpenStudio.convert(total_end_use, 'GJ', 'kWh').get
      # value_neat = OpenStudio.toNeatString(value, 0, true)
      output_data_end_use[:data] << [end_use, value.round(2)]
      runner.registerValue("end_use_#{end_use.downcase.tr(' ', '_')}", value, 'kWh')
      totalEndUse += value
      counter += 1
    end
    output_data_end_use[:data].each do |row|
      percent = (row[1].to_f / totalEndUse) * 100
      row[1] = OpenStudio.toNeatString(row[1], 0, true)
      row << percent.round(2)
    end

    if output_data_end_use[:data].size > 0
      @output_data_end_use_table_section[:tables] = [output_data_end_use] # only one table for this section
    else
      @output_data_end_use_table_section[:tables] = []
    end

    return @output_data_end_use_table_section
  end

  # building_construction section
  def self.building_construction_detailed_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    general_construction_tables = []

    # gather data for section
    @building_construction_section = {}
    @building_construction_section[:title] = 'Construction Detailed'
    @building_construction_section[:tables] = general_construction_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @building_construction_section
    end

    # Envelope constructions and total areas######################
    @constructions = Hash.new
    areaT = 0
    areaW = 0
    areaS = 0
    area = 0
    areaT += area
    @window_count = 0
    @window_area_total = 0
    @wall_table = []
    adj_space = ""
    adjSurface = ""
    model.getSurfaces.each do |surface|
      sp_name = surface.space.get.name.to_s
      outsideBoundaryCondition = surface.outsideBoundaryCondition
      if (outsideBoundaryCondition == "Surface")
        next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
        adjSurface = surface.adjacentSurface.get.name.to_s
        adj_space = surface.adjacentSurface.get.space.get.name.to_s
        outsideBoundaryCondition = adj_space + ":" + adjSurface
      end
      #Find orientation
      if (surface.name.to_s.include? "Ceiling")
        facade = "Ceiling"
      elsif (surface.name.to_s.include? "Floor")
        facade = "Floor"
      elsif (surface.name.to_s.include? "roof")
        facade = "Roof"
      else
        absoluteAzimuth = OpenStudio::convert(surface.azimuth, "rad", "deg").get + surface.space.get.directionofRelativeNorth + model.getBuilding.northAxis
        until absoluteAzimuth < 360.0
          absoluteAzimuth = absoluteAzimuth - 360.0
        end
        if (absoluteAzimuth >= 315.0 || absoluteAzimuth < 45.0)
          facade = "North"
        elsif (absoluteAzimuth >= 45.0 && absoluteAzimuth < 135.0)
          facade = "East"
        elsif (absoluteAzimuth >= 135.0 && absoluteAzimuth < 225.0)
          facade = "South"
        elsif (absoluteAzimuth >= 225.0 && absoluteAzimuth < 315.0)
          facade = "West"
        end
      end
      const_arr = []
      cName = surface.construction.get.name.to_s
      area = surface.netArea

      uValue = surface.construction.get.thermalConductance.to_f
      uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)

      if @constructions.key?(cName)
        areaT = @constructions[cName][0] + area
        const_arr.push(areaT)
        const_arr.push(uValue)
        const_arr.push(rValue)
      else
        const_arr.push(area)
        const_arr.push(uValue)
        const_arr.push(rValue)
      end
      @constructions[cName] = const_arr
      @wall_table.push([sp_name, surface.name.to_s, outsideBoundaryCondition, facade, cName, area.to_f.signif(3)])

      surface.subSurfaces.each do |subsurf|
        const_arr = []
        cName = subsurf.construction.get.name.to_s
        area = subsurf.netArea
        @window_area_total += area
        #@constructions.key?(cName) ? @constructions[cName] += area : @constructions[cName] = area
        @window_count += 1
        uValue = subsurf.construction.get.uFactor.to_f
        uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)

        if @constructions.key?(cName)
          areaW = @constructions[cName][0] + area
          # areaW += area
          const_arr.push(areaW)
          const_arr.push(uValue)
          const_arr.push(rValue)
        else
          const_arr.push(area)
          const_arr.push(uValue)
          const_arr.push(rValue)
        end
        @constructions[cName] = const_arr
        @wall_table.push([sp_name, subsurf.name.to_s, outsideBoundaryCondition, facade, cName, area.to_f.signif(3)])
      end
    end
    @skylight_count = 0
    skylight_area_total = 0
    @roof_table = []
    @roof_table.push(["Roof/skylight surface name", "Space Name", "Outside Boundary Condition", "Orientation", "Construction", "Total area {m2}"])

    @wall_table = @wall_table.sort_by(&:first)
    @wall_table.unshift(["Space Name", "Surface name", "Outside Boundary Condition", "Orientation", "Construction", "Total area {m2}"])
    # For each construction in the construction hash get the layer by layer descrption
    used_constructions = @constructions
    used_constructions.delete("Name")
    @win_name = ""
    @wall_int_name = ""
    @wall_ext_name = ""
    @wall_int_ceil_name = ""
    @roofname = ""
    @int_floor_name = ""
    @grnd_floor_name = ""
    @window_construction_detail = []
    @roof_construction_detail = []
    @wall_int_construction_detail = []
    @wall_int_ceil_construction_detail = []
    @wall_ext_construction_detail = []
    @wall_int_ceil_construction_detail = []
    @int_floor_construction_detail = []
    @ground_floor_construction_detail = []
    @window_construction_detail.push(["Name", "U-Factor {W/m2.K}", "SHGC"])
    @roof_construction_detail.push(["Name", "Thickness {mm}", "Conductivity {W/m.K}", "Density {kg/m3}", "Specific Heat {J/kg.K}", "Thermal Resistance {m2.K/W}", " Thermal Absorbtance {-}", "Solar Absorptance {-}", "Visible Absorptance {-}"])
    @wall_int_construction_detail.push(["Name", "Thickness {mm}", "Conductivity {W/m.K}", "Density {kg/m3}", "Specific Heat {J/kg.K}", "Thermal Resistance {m2.K/W}", " Thermal Absorbtance {-}", "Solar Absorptance {-}", "Visible Absorptance {-}"])
    @wall_int_ceil_construction_detail.push(["Name", "Thickness {mm}", "Conductivity {W/m.K}", "Density {kg/m3}", "Specific Heat {J/kg.K}", "Thermal Resistance {m2.K/W}", " Thermal Absorbtance {-}", "Solar Absorptance {-}", "Visible Absorptance {-}"])
    @wall_ext_construction_detail.push(["Name", "Thickness {mm}", "Conductivity {W/m.K}", "Density {kg/m3}", "Specific Heat {J/kg.K}", "Thermal Resistance {m2.K/W}", " Thermal Absorbtance {-}", "Solar Absorptance {-}", "Visible Absorptance {-}"])
    @int_floor_construction_detail.push(["Name", "Thickness {mm}", "Conductivity {W/m.K}", "Density {kg/m3}", "Specific Heat {J/kg.K}", "Thermal Resistance {m2.K/W}", " Thermal Absorbtance {-}", "Solar Absorptance {-}", "Visible Absorptance {-}"])
    @ground_floor_construction_detail.push(["Name", "Thickness {mm}", "Conductivity {W/m.K}", "Density {kg/m3}", "Specific Heat {J/kg.K}", "Thermal Resistance {m2.K/W}", " Thermal Absorbtance {-}", "Solar Absorptance {-}", "Visible Absorptance {-}"])

    # 'Construction details'
    model.getConstructions.each do |model_construction|
      if used_constructions.has_key?(model_construction.name.to_s) then
        const_name = model_construction.name.to_s
        layers = model_construction.layers
        layers.each do |material|
          if const_name.include? "Window"
            @win_name = model_construction.name.to_s
            if material.name.to_s.include? "Glazing"
              name_m = material.name.to_s
              glazing = material.to_SimpleGlazing.get.uFactor unless material.to_SimpleGlazing.empty?
              shgc = material.to_SimpleGlazing.get.solarHeatGainCoefficient unless material.to_SimpleGlazing.empty?
              visibleTransmittance = material.to_SimpleGlazing.get.visibleTransmittance unless material.to_SimpleGlazing.empty?
              @window_construction_detail.push([name_m, glazing, shgc])
            end
          elsif const_name.include? "Int-Wall"
            @wall_int_name = model_construction.name.to_s
            w_thick1 = ((material.thickness) * 1000).round(2) unless material.to_OpaqueMaterial.empty?
            w_thick2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            w_thick = w_thick1 || w_thick2
            w_thick == 0.0 ? w_thick = w_thick2 : w_thick = w_thick1
            w_name = material.name.to_s
            therm_resis = material.to_OpaqueMaterial.get.thermalResistance unless material.to_OpaqueMaterial.empty?
            therm_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            density1 = (material.to_StandardOpaqueMaterial.get.density).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity1 = (material.to_StandardOpaqueMaterial.get.conductivity).round(2) unless material.to_StandardOpaqueMaterial.empty?
            specificHeat1 = (material.to_StandardOpaqueMaterial.get.specificHeat).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            specificHeat2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            solar_abs = material.to_OpaqueMaterial.get.solarAbsorptance unless material.to_OpaqueMaterial.empty?
            ther_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            visible_abs = material.to_OpaqueMaterial.get.visibleAbsorptance unless material.to_OpaqueMaterial.empty?
            density2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            density = density1 || density2
            specificHeat = specificHeat1 || specificHeat2
            conductivity = conductivity1 || conductivity2
            conductance = material.to_MasslessOpaqueMaterial.get.thermalConductance unless material.to_MasslessOpaqueMaterial.empty?
            @wall_int_construction_detail.push([w_name, w_thick, conductivity, density, specificHeat, therm_resis.round(2), therm_abs, solar_abs, visible_abs])
          elsif const_name.include? "Int-Ceil"
            @wall_int_ceil_name = model_construction.name.to_s
            w_thick1 = ((material.thickness) * 1000).round(2) unless material.to_OpaqueMaterial.empty?
            w_thick2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            w_thick = w_thick1 || w_thick2
            w_thick == 0.0 ? w_thick = w_thick2 : w_thick = w_thick1
            w_name = material.name.to_s
            therm_resis = material.to_OpaqueMaterial.get.thermalResistance unless material.to_OpaqueMaterial.empty?
            therm_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            density1 = (material.to_StandardOpaqueMaterial.get.density).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity1 = (material.to_StandardOpaqueMaterial.get.conductivity).round(2) unless material.to_StandardOpaqueMaterial.empty?
            specificHeat1 = (material.to_StandardOpaqueMaterial.get.specificHeat).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            specificHeat2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            solar_abs = material.to_OpaqueMaterial.get.solarAbsorptance unless material.to_OpaqueMaterial.empty?
            ther_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            visible_abs = material.to_OpaqueMaterial.get.visibleAbsorptance unless material.to_OpaqueMaterial.empty?
            density2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            density = density1 || density2
            specificHeat = specificHeat1 || specificHeat2
            conductivity = conductivity1 || conductivity2
            conductance = material.to_MasslessOpaqueMaterial.get.thermalConductance unless material.to_MasslessOpaqueMaterial.empty?
            @wall_int_ceil_construction_detail.push([w_name, w_thick, conductivity, density, specificHeat, therm_resis.round(2), therm_abs, solar_abs, visible_abs])

          elsif const_name.include? "Ext-Wall"
            @wall_ext_name = model_construction.name.to_s
            w_thick1 = ((material.thickness) * 1000).round(2) unless material.to_OpaqueMaterial.empty?
            w_thick2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            w_thick = w_thick1 || w_thick2
            w_thick == 0.0 ? w_thick = w_thick2 : w_thick = w_thick1
            w_name = material.name.to_s
            therm_resis = material.to_OpaqueMaterial.get.thermalResistance unless material.to_OpaqueMaterial.empty?
            therm_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            density1 = (material.to_StandardOpaqueMaterial.get.density).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity1 = (material.to_StandardOpaqueMaterial.get.conductivity).round(2) unless material.to_StandardOpaqueMaterial.empty?
            specificHeat1 = (material.to_StandardOpaqueMaterial.get.specificHeat).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            specificHeat2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            solar_abs = material.to_OpaqueMaterial.get.solarAbsorptance unless material.to_OpaqueMaterial.empty?
            ther_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            visible_abs = material.to_OpaqueMaterial.get.visibleAbsorptance unless material.to_OpaqueMaterial.empty?
            density2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            density = density1 || density2
            specificHeat = specificHeat1 || specificHeat2
            conductivity = conductivity1 || conductivity2
            conductance = material.to_MasslessOpaqueMaterial.get.thermalConductance unless material.to_MasslessOpaqueMaterial.empty?
            @wall_ext_construction_detail.push([w_name, w_thick, conductivity, density, specificHeat, therm_resis.round(2), therm_abs, solar_abs, visible_abs])

          elsif const_name.include? "Int-Floor"
            @int_floor_name = model_construction.name.to_s
            w_thick1 = ((material.thickness) * 1000).round(2) unless material.to_OpaqueMaterial.empty?
            w_thick2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            w_thick = w_thick1 || w_thick2
            w_thick == 0.0 ? w_thick = w_thick2 : w_thick = w_thick1
            w_name = material.name.to_s
            therm_resis = material.to_OpaqueMaterial.get.thermalResistance unless material.to_OpaqueMaterial.empty?
            therm_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            density1 = (material.to_StandardOpaqueMaterial.get.density).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity1 = (material.to_StandardOpaqueMaterial.get.conductivity).round(2) unless material.to_StandardOpaqueMaterial.empty?
            specificHeat1 = (material.to_StandardOpaqueMaterial.get.specificHeat).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            specificHeat2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            solar_abs = material.to_OpaqueMaterial.get.solarAbsorptance unless material.to_OpaqueMaterial.empty?
            ther_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            visible_abs = material.to_OpaqueMaterial.get.visibleAbsorptance unless material.to_OpaqueMaterial.empty?
            density2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            density = density1 || density2
            specificHeat = specificHeat1 || specificHeat2
            conductivity = conductivity1 || conductivity2
            conductance = material.to_MasslessOpaqueMaterial.get.thermalConductance unless material.to_MasslessOpaqueMaterial.empty?
            @int_floor_construction_detail.push([w_name, w_thick, conductivity, density, specificHeat, therm_resis.round(2), therm_abs, solar_abs, visible_abs])
          elsif const_name.include? "Grnd-Floor"
            @grnd_floor_name = model_construction.name.to_s
            w_thick1 = ((material.thickness) * 1000).round(2) unless material.to_OpaqueMaterial.empty?
            w_thick2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            w_thick = w_thick1 || w_thick2
            w_thick == 0.0 ? w_thick = w_thick2 : w_thick = w_thick1
            w_name = material.name.to_s
            therm_resis = material.to_OpaqueMaterial.get.thermalResistance unless material.to_OpaqueMaterial.empty?
            therm_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            density1 = (material.to_StandardOpaqueMaterial.get.density).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity1 = (material.to_StandardOpaqueMaterial.get.conductivity).round(2) unless material.to_StandardOpaqueMaterial.empty?
            specificHeat1 = (material.to_StandardOpaqueMaterial.get.specificHeat).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            specificHeat2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            solar_abs = material.to_OpaqueMaterial.get.solarAbsorptance unless material.to_OpaqueMaterial.empty?
            ther_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            visible_abs = material.to_OpaqueMaterial.get.visibleAbsorptance unless material.to_OpaqueMaterial.empty?
            density2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            density = density1 || density2
            specificHeat = specificHeat1 || specificHeat2
            conductivity = conductivity1 || conductivity2
            conductance = material.to_MasslessOpaqueMaterial.get.thermalConductance unless material.to_MasslessOpaqueMaterial.empty?
            @ground_floor_construction_detail.push([w_name, w_thick, conductivity, density, specificHeat, therm_resis.round(2), therm_abs, solar_abs, visible_abs])

          elsif const_name.include? "Roof"
            @roof_name = model_construction.name.to_s
            r_name = material.name.to_s
            r_thick1 = ((material.thickness) * 1000).round(2) unless material.to_OpaqueMaterial.empty?
            r_thick2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            r_thick = r_thick1 || r_thick2
            r_thick == 0.0 ? r_thick = r_thick2 : r_thick = r_thick1
            w_name = material.name.to_s
            w_name = material.name.to_s
            therm_resis = material.to_OpaqueMaterial.get.thermalResistance unless material.to_OpaqueMaterial.empty?
            therm_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            density1 = (material.to_StandardOpaqueMaterial.get.density).round(2) unless material.to_StandardOpaqueMaterial.empty?
            conductivity1 = (material.to_StandardOpaqueMaterial.get.conductivity).round(2) unless material.to_StandardOpaqueMaterial.empty?
            solar_abs = material.to_OpaqueMaterial.get.solarAbsorptance unless material.to_OpaqueMaterial.empty?
            ther_abs = material.to_OpaqueMaterial.get.thermalAbsorptance unless material.to_OpaqueMaterial.empty?
            visible_abs = material.to_OpaqueMaterial.get.visibleAbsorptance unless material.to_OpaqueMaterial.empty?
            specificHeat1 = (material.to_StandardOpaqueMaterial.get.specificHeat).round(2) unless material.to_StandardOpaqueMaterial.empty?
            density2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            conductivity2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            specificHeat2 = '-' unless material.to_MasslessOpaqueMaterial.empty?
            density = density1 || density2
            specificHeat = specificHeat1 || specificHeat2
            conductivity = conductivity1 || conductivity2
            @roof_construction_detail.push([r_name, r_thick, conductivity, density, specificHeat, therm_resis.round(2), therm_abs, solar_abs, visible_abs])
          end
        end
      end
    end

    @exteriorWalls_count = model.getBuilding.exteriorWalls.count
    @roofs_count = model.getBuilding.roofs.count
    @exteriorWallArea = model.getBuilding.exteriorWallArea
    exteriorSurfaceArea = model.getBuilding.exteriorSurfaceArea
    @roof_area = exteriorSurfaceArea - @exteriorWallArea
    @roof_area = @roof_area.round(2)
    @exteriorWallArea = @exteriorWallArea.round(2)
    @wwr = @window_area_total / (model.getBuilding.exteriorWallArea)
    @window_area_total = @window_area_total.round(2)
    @wwr = @wwr.round(2)
    @srr = skylight_area_total / (model.getBuilding.exteriorSurfaceArea - model.getBuilding.exteriorWallArea)
    @srr = @srr.round(2)
    @const_totalArea = []
    const_layerDetail = []

    # add in general information from method
    general_construction_tables << OsLib_Reporting.construction_ceiling_detailed_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_ext_walls_detailed_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_int_walls_detailed_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_int_floors_detailed_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_gnd_floors_detailed_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_roofs_detailed_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_spaces_section(model, sqlFile, runner)
    return @building_construction_section
  end

  # create construction summary section
  def self.construction_summary_section(model, sqlFile, runner, name_only = false)

    # array to hold tables
    general_construction_tables = []

    # gather data for section
    @construction_summary_table_section = {}
    @construction_summary_table_section[:title] = 'Construction Summary'
    @construction_summary_table_section[:tables] = general_construction_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @construction_summary_table_section
    end
    general_construction_tables << OsLib_Reporting.general_construction_summary_section(model, sqlFile, runner)
    general_construction_tables << OsLib_Reporting.construction_surface_summary_section(model, sqlFile, runner)
    return @construction_summary_table_section
  end

  # create general construction summary section
  def self.general_construction_summary_section(model, sqlFile, runner)
    construction_general_summary_data_table = {}
    construction_general_summary_data_table[:title] = 'General Construction Summary'
    construction_general_summary_data_table[:header] = ["Parameter", "Value"]
    construction_general_summary_data_table[:units] = ['', '']
    construction_general_summary_data_table[:data] = []

    constructions = Hash.new
    constructions['Name'] = 'Total area (m2)'
    window_count = 0
    window_area_total = 0
    wall_table = []
    wall_table.push(["Wall/window surface name", "Construction", "Total area (m2)", "U-value (W/m2K)", "R-value (ft2.degF/BTU)"])
    model.getBuilding.exteriorWalls.each do |surface|
      cName = surface.construction.get.name.to_s
      area = surface.netArea
      constructions.key?(cName) ? constructions[cName] += area : constructions[cName] = area
      uValue = surface.construction.get.thermalConductance.to_f
      uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)
      wall_table.push([surface.name.to_s, cName, area.to_f.signif(3), uValue.to_f.round(3), rValue.to_f.round(1)])
      surface.subSurfaces.each do |subsurf|
        cName = subsurf.construction.get.name.to_s
        area = subsurf.netArea
        window_area_total += area
        constructions.key?(cName) ? constructions[cName] += area : constructions[cName] = area
        window_count += 1
        uValue = subsurf.construction.get.uFactor.to_f
        uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)
        wall_table.push([subsurf.name.to_s, cName, area.to_f.signif(3), uValue.to_f.round(3), rValue.to_f.round(1)])
      end
    end
    skylight_count = 0
    skylight_area_total = 0
    roof_table = []
    roof_table.push(["Roof/skylight surface name", "Construction", "Total area (m2)", "U-value (W/m2K)", "R-value (ft2.degF/BTU)"])
    model.getBuilding.roofs.each do |surface|
      cName = surface.construction.get.name.to_s
      area = surface.netArea
      constructions.key?(cName) ? constructions[cName] += area : constructions[cName] = area
      uValue = surface.construction.get.thermalConductance.to_f
      uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)
      roof_table.push([surface.name.to_s, cName, area.to_f.signif(3), uValue.to_f.round(3), rValue.to_f.round(1)])
      surface.subSurfaces.each do |subsurf|
        cName = subsurf.construction.get.name.to_s
        area = subsurf.netArea
        skylight_area_total += area
        constructions.key?(cName) ? constructions[cName] += area : constructions[cName] = area
        skylight_count += 1
        uValue = subsurf.construction.get.uFactor.to_f
        uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)
        roof_table.push([subsurf.name.to_s, cName, area.to_f.signif(3), uValue.to_f.round(3), rValue.to_f.round(1)])
      end
    end

    wwr = window_area_total / (model.getBuilding.exteriorWallArea)
    srr = skylight_area_total / (model.getBuilding.exteriorSurfaceArea - model.getBuilding.exteriorWallArea)
    roof_area = model.getBuilding.exteriorSurfaceArea - model.getBuilding.exteriorWallArea

    construction_general_summary_data_table[:data] << ["Number of exterior wall surfaces", model.getBuilding.exteriorWalls.count]
    construction_general_summary_data_table[:data] << ["Number of windows in the model", window_count]
    construction_general_summary_data_table[:data] << ["Number of roofs", model.getBuilding.roofs.count]
    construction_general_summary_data_table[:data] << ["Number of skylights in the model", skylight_count]
    construction_general_summary_data_table[:data] << ["Window-Wall Ratio {%}", wwr * 100.round(2)]
    construction_general_summary_data_table[:data] << ["Skylight-Roof Ratio {%}", srr * 100.round(2)]
    return construction_general_summary_data_table
  end

  # create construction summary section
  def self.construction_surface_summary_section(model, sqlFile, runner)
    construction_summary_data_table = {}
    construction_summary_data_table[:title] = 'Construction Surfaces Summary'
    construction_summary_data_table[:header] = ['Name', 'Total area', 'U-value', 'R-value']
    construction_summary_data_table[:units] = ["", "m2", "W/m2.K", "ft2·°F·h/BTU"]
    construction_summary_data_table[:data] = []

    @const_totalArea = []
    const_layerDetail = []
    @constructions.each do |key, value|
      @const_totalArea.push([key, value[0].to_f.signif(3), value[1].to_f.round(3), value[2].to_f.round(1)])
      construction_summary_data_table[:data].push([key, value[0].to_f.signif(3), value[1].to_f.round(3), value[2].to_f.round(1)])
    end
    return construction_summary_data_table
  end

  def self.construction_ceiling_detailed_section(model, sqlFile, runner)
    ceiling_construction_information = {}
    ceiling_construction_information[:title] = 'Layer by layer Construction of interior ceilings' # name will be with section
    ceiling_construction_information[:header] = ["Name", "Thickness", "Conductivity", "Density", "Specific Heat", "Thermal Resistance", " Thermal Absorbtance", "Solar Absorptance", "Visible Absorptance"]
    ceiling_construction_information[:units] = ["", "mm", "W/m.K", "kg/m3", "J/kg.K", "m2.K/W", "", "", ""] # won't populate for this table since each row has different units
    ceiling_construction_information[:data] = []
    ceiling_construction_information[:data] = @wall_int_ceil_construction_detail[1..@wall_int_ceil_construction_detail.length]
    return ceiling_construction_information
  end

  def self.construction_ext_walls_detailed_section(model, sqlFile, runner)
    ext_walls_construction_information = {}
    ext_walls_construction_information[:title] = 'Layer by layer Construction of exterior walls' # name will be with section
    ext_walls_construction_information[:header] = ["Name", "Thickness", "Conductivity", "Density", "Specific Heat", "Thermal Resistance", " Thermal Absorbtance", "Solar Absorptance", "Visible Absorptance"]
    ext_walls_construction_information[:units] = ["", "mm", "W/m.K", "kg/m3", "J/kg.K", "m2.K/W", "", "", ""] # won't populate for this table since each row has different units
    ext_walls_construction_information[:data] = []

    ext_walls_construction_information[:data] = @wall_ext_construction_detail[1..@wall_ext_construction_detail.length]
    return ext_walls_construction_information
  end

  def self.construction_int_walls_detailed_section(model, sqlFile, runner)
    int_walls_construction_information = {}
    int_walls_construction_information[:title] = 'Layer by layer Construction of interior walls' # name will be with section
    int_walls_construction_information[:header] = ["Name", "Thickness", "Conductivity", "Density", "Specific Heat", "Thermal Resistance", " Thermal Absorbtance", "Solar Absorptance", "Visible Absorptance"]
    int_walls_construction_information[:units] = ["", "mm", "W/m.K", "kg/m3", "J/kg.K", "m2.K/W", "", "", ""] # won't populate for this table since each row has different units
    int_walls_construction_information[:data] = []

    int_walls_construction_information[:data] = @wall_int_construction_detail[1..@wall_int_construction_detail.length]
    return int_walls_construction_information
  end

  def self.construction_int_floors_detailed_section(model, sqlFile, runner)
    int_floor_construction_information = {}
    int_floor_construction_information[:title] = 'Layer by layer Construction of interior floors' # name will be with section
    int_floor_construction_information[:header] = ["Name", "Thickness", "Conductivity", "Density", "Specific Heat", "Thermal Resistance", " Thermal Absorbtance", "Solar Absorptance", "Visible Absorptance"]
    int_floor_construction_information[:units] = ["", "mm", "W/m.K", "kg/m3", "J/kg.K", "m2.K/W", "", "", ""] # won't populate for this table since each row has different units
    int_floor_construction_information[:data] = []

    int_floor_construction_information[:data] = @int_floor_construction_detail[1..@int_floor_construction_detail.length]
    return int_floor_construction_information
  end

  def self.construction_gnd_floors_detailed_section(model, sqlFile, runner)
    gnd_floor_construction_information = {}
    gnd_floor_construction_information[:title] = 'Layer by layer Construction of ground floors' # name will be with section
    gnd_floor_construction_information[:header] = ["Name", "Thickness", "Conductivity", "Density", "Specific Heat", "Thermal Resistance", " Thermal Absorbtance", "Solar Absorptance", "Visible Absorptance"]
    gnd_floor_construction_information[:units] = ["", "mm", "W/m.K", "kg/m3", "J/kg.K", "m2.K/W", "", "", ""] # won't populate for this table since each row has different units
    gnd_floor_construction_information[:data] = []

    gnd_floor_construction_information[:data] = @ground_floor_construction_detail[1..@ground_floor_construction_detail.length]
    return gnd_floor_construction_information
  end

  def self.construction_windows_detailed_section(model, sqlFile, runner)
    windows_construction_information = {}
    windows_construction_information[:title] = 'Detailed construction of windows' # name will be with section
    # windows_construction_information[:header] = ["Name", "U-Factor", "SHGC", "Visible Transmittance"]
    windows_construction_information[:header] = ["Name", "U-Factor", "SHGC"]
    windows_construction_information[:units] = ["", "W/m2.K", "", ""] # won't populate for this table since each row has different units
    windows_construction_information[:data] = []

    windows_construction_information[:data] = @window_construction_detail[1..@window_construction_detail.length]
    return windows_construction_information
  end

  def self.construction_roofs_detailed_section(model, sqlFile, runner)
    roof_construction_information = {}
    roof_construction_information[:title] = 'Layer by layer Construction of roof' # name will be with section
    roof_construction_information[:header] = ["Name", "Thickness", "Conductivity", "Density", "Specific Heat", "Thermal Resistance", " Thermal Absorbtance", "Solar Absorptance", "Visible Absorptance"]
    roof_construction_information[:units] = ["", "mm", "W/m.K", "kg/m3", "J/kg.K", "m2.K/W", "", "", ""] # won't populate for this table since each row has different units
    roof_construction_information[:data] = []

    roof_construction_information[:data] = @roof_construction_detail[1..@roof_construction_detail.length]
    return roof_construction_information
  end

  def self.construction_spaces_section(model, sqlFile, runner)
    space_construction_information = {}
    space_construction_information[:title] = 'Spaces defined by exterior/interior surfaces and subsurfaces' # name will be with section
    space_construction_information[:header] = ["Space Name", "Surface name", "Outside Boundary Condition", "Orientation", "Construction", "Total area"]
    space_construction_information[:units] = ["", "", "", "", "", "m2"] # won't populate for this table since each row has different units
    space_construction_information[:data] = []

    space_construction_information[:data] = @wall_table[1..@wall_table.length]
    return space_construction_information
  end

  ######################heat gain and loss section is copied from bcl, but modified to use si units###################################
  # create heat_gains_summary_section
  def self.heat_gains_summary_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    summary_tables = []

    # gather data for section
    @template_section = {}
    @template_section[:title] = 'Heat Gains Summary'
    @template_section[:tables] = summary_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @template_section
    end

    # gather data from previous section
    source_tables = []
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Electric Equipment Total Heating Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Gas Equipment Total Heating Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone Lights Total Heating Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone People Sensible Heating Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone Infiltration Sensible Heat Gain Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Surface Window Heat Gain Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_surface_heat_gains_table(model, sqlFile, runner)

    # create monthly table
    summary_table_02 = {}
    summary_table_02[:title] = "Heat Gains Monthly Breakdown Summary (GJ)"
    summary_table_02[:header] = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total']
    summary_table_02[:units] = []
    summary_table_02[:data] = []

    # loop through tables to get annual information
    source_tables.each do |table|

      title = table[:title].gsub(" (GJ)", "")
      if title == "Surface Average Face Conduction Heat Gain"
        # exterior walls subtotal
        row_data = []
        sub_title = "Exterior Wall Surfaces Heat Gain"
        target_row = table[:data][table[:data].size - 4]
        row_data << sub_title
        target_row.each_with_index do |value, i|
          ""
          next if value == "Monthly Totals"
          next if i < 3
          #next if i == target_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

        # exterior roofs subtotal
        row_data = []
        sub_title = "Roof Surfaces Heat Gain"
        target_row = table[:data][table[:data].size - 3]
        row_data << sub_title
        target_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if i < 3
          # next if i == target_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

        # ground subtotal
        row_data = []
        sub_title = "Ground Exposed Surfaces Heat Gain"
        target_row = table[:data][table[:data].size - 2]
        row_data << sub_title
        target_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if i < 3
          #next if i == target_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

      else

        row_data = []
        last_row = table[:data].last
        row_data << title
        last_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if value == ""
          #next if i == last_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data
      end
    end

    # add table to array of tables
    summary_tables << summary_table_02
    return @template_section
  end

  # create heat_loss_summary_section
  def self.heat_loss_summary_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    summary_tables = []

    # gather data for section
    @template_section = {}
    @template_section[:title] = 'Heat Loss Summary'
    @template_section[:tables] = summary_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @template_section
    end

    # gather data from previous section
    source_tables = []
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone Infiltration Sensible Heat Loss Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Surface Window Heat Loss Energy', 'J', 'GJ')
    source_tables << OsLib_Reporting.monthly_surface_heat_losses_table(model, sqlFile, runner)

    # create monthly table
    summary_table_02 = {}
    summary_table_02[:title] = "Heat Loss Monthly Breakdown Summary(GJ)"
    summary_table_02[:header] = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total']
    summary_table_02[:units] = []
    summary_table_02[:data] = []

    # loop through tables to get annual information
    source_tables.each do |table|

      title = table[:title].gsub(" (GJ)", "")
      if title == "Surface Inside Face Conduction Heat Loss"

        # exterior walls subtotal
        row_data = []
        sub_title = "Exterior Wall Surfaces Heat Loss"
        target_row = table[:data][table[:data].size - 4]
        row_data << sub_title
        target_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if i < 3
          #next if i == target_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

        # exterior roofs subtotal
        row_data = []
        sub_title = "Roof Surfaces Heat Loss"
        target_row = table[:data][table[:data].size - 3]
        row_data << sub_title
        target_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if i < 3
          #next if i == target_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

        # ground subtotal
        row_data = []
        sub_title = "Ground Exposed Surfaces Heat Loss"
        target_row = table[:data][table[:data].size - 2]
        row_data << sub_title
        target_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if i < 3
          #next if i == target_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

      else

        row_data = []
        last_row = table[:data].last
        row_data << title
        last_row.each_with_index do |value, i|
          next if value == "Monthly Totals"
          next if value == ""
          #next if i == last_row.size - 1 # don't want to include annual total
          row_data << value
        end
        summary_table_02[:data] << row_data

      end

    end

    # add table to array of tables
    summary_tables << summary_table_02
    return @template_section
  end

  # section for heat_gains
  def self.heat_gains_detail_section(model, sqlFile, runner, name_only = false)
    tables = []
    @heat_gains = {}
    @heat_gains[:title] = 'Heat Gains By Month Detailed'
    @heat_gains[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @heat_gains
    end

    tables << @elec_equip_gain_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Electric Equipment Total Heating Energy', 'J', 'GJ')
    tables << @gas_equip_gain_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Gas Equipment Total Heating Energy', 'J', 'GJ')
    tables << @lights_gain_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone Lights Total Heating Energy', 'J', 'GJ')
    tables << @people_gain_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone People Sensible Heating Energy', 'J', 'GJ')
    tables << @infiltration_gain_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone Infiltration Sensible Heat Gain Energy', 'J', 'GJ')
    tables << @window_gain_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Surface Window Heat Gain Energy', 'J', 'GJ')
    tables << @surface_gain_table = OsLib_Reporting.monthly_surface_heat_gains_table(model, sqlFile, runner)

    return @heat_gains
  end

  # section for heat_losses
  def self.heat_losses_detail_section(model, sqlFile, runner, name_only = false)
    tables = []
    @heat_losses = {}
    @heat_losses[:title] = 'Heat Losses By Month Detailed'
    @heat_losses[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @heat_losses
    end

    tables << @infiltration_loss_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Zone Infiltration Sensible Heat Loss Energy', 'J', 'GJ')
    tables << @window_loss_table = OsLib_Reporting.monthly_table_with_totals(model, sqlFile, runner, 'Surface Window Heat Loss Energy', 'J', 'GJ')
    tables << @surface_loss_table = OsLib_Reporting.monthly_surface_heat_losses_table(model, sqlFile, runner)

    return @heat_losses
  end

  # monthly monthly_table_with_totals
  def self.monthly_table_with_totals(model, sqlFile, runner, var, source_units, target_units)

    # variables
    frequency = 'Monthly'

    # create table
    monthly_table_with_totals = {}
    monthly_table_with_totals[:title] = "#{var} (#{target_units})"
    monthly_table_with_totals[:header] = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total']
    monthly_table_with_totals[:units] = [] # in title since all columns the same
    monthly_table_with_totals[:data] = []

    # get time series monthly data
    ann_env_pd = OsLib_Reporting.ann_env_pd(sqlFile)
    if ann_env_pd
      # loop through keys for variable
      keys = sqlFile.availableKeyValues(ann_env_pd, frequency, var)
      monthly_totals = ["Monthly Totals", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      keys.each do |key|
        total = 0.0
        var_value_monthly = [key]
        output_timeseries = sqlFile.timeSeries(ann_env_pd, frequency, var, key)
        # loop through timeseries and move the data from an OpenStudio timeseries to a normal Ruby array (vector)
        if output_timeseries.is_initialized # checks to see if time_series exists

          # see if filler needed at start or end of table/chart
          num_blanks_start = output_timeseries.get.dateTimes[0].date.monthOfYear.value - 2
          num_blanks_end = 12 - output_timeseries.get.values.size - num_blanks_start

          # fill in blank data for partial year simulations
          for i in 0..(num_blanks_start - 1)
            month = monthly_table_with_totals[:header][i + 1]
            var_value_monthly << ''
          end

          # get values
          output_timeseries = output_timeseries.get.values
          for i in 0..(output_timeseries.size - 1)
            month = monthly_table_with_totals[:header][i + 1 + num_blanks_start]
            value = OpenStudio.convert(output_timeseries[i], source_units, target_units).get
            total += value
            monthly_totals[i + 1] += value
            value_neat = OpenStudio::toNeatString(value, 1, true)
            var_value_monthly << value_neat
          end

          # fill in blank data for partial year simulations
          for i in 0..(num_blanks_end - 1)
            month = monthly_table_with_totals[:header][i]
            var_value_monthly << ''
          end

          # populate total column and clean up values
          total_neat = OpenStudio::toNeatString(total, 1, true)
          var_value_monthly << total_neat
          monthly_totals[13] += total

        else
          runner.registerWarning("Didn't find data for #{var} #{key}")
        end

        # add each key to data
        monthly_table_with_totals[:data] << var_value_monthly
      end
    else
      runner.registerWarning('An annual simulation was not run. Cannot get annual timeseries data')
      return false
    end

    # add table totals
    monthly_totals_neat = []
    monthly_totals.each do |total|
      if total == "Monthly Totals"
        monthly_totals_neat << total
      else
        monthly_totals_neat << OpenStudio::toNeatString(total, 1, true)
      end
    end
    monthly_table_with_totals[:data] << monthly_totals_neat
    reg_val_display_name = "#{var}_annual"
    runner.registerValue(reg_val_string_prep(reg_val_display_name), monthly_totals.last, 'GJ')
    return monthly_table_with_totals
  end

  # monthly_surface_heat_gains_and_losses_table rolled up from hourly values
  def self.monthly_surface_heat_gains_table(model, sqlFile, runner)

    # variables
    frequency = 'Hourly'
    var = 'Surface Inside Face Conduction Heat Transfer Energy'
    source_units = 'J'
    target_units = 'GJ'

    # create table
    monthly_surface_heat_gains_table = {}
    monthly_surface_heat_gains_table[:title] = "Surface Inside Face Conduction Heat Gain (#{target_units})" # heat losses will be in another table
    monthly_surface_heat_gains_table[:header] = ['', 'Surface Type', 'Ouside Boundary Condition', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total']
    monthly_surface_heat_gains_table[:units] = [] # in title since all columns the same
    monthly_surface_heat_gains_table[:data] = []

    monthly_totals = {}
    model.getSurfaces.sort.each do |surface|
      next if surface.outsideBoundaryCondition == "Surface"
      next if surface.outsideBoundaryCondition == "Adiabatic"
      key = surface.name.to_s
      row_data = []
      row_data << surface.name.to_s
      row_data << surface.surfaceType
      row_data << surface.outsideBoundaryCondition

      # get time series hourly data
      ann_env_pd = OsLib_Reporting.ann_env_pd(sqlFile)
      if ann_env_pd

        # get timeseries data
        output_timeseries = sqlFile.timeSeries(ann_env_pd, frequency, var, key)
        if output_timeseries.is_initialized # checks to see if time_series exists
          values = output_timeseries.get.values
          date_times = output_timeseries.get.dateTimes

          # loop through hourly data
          surface_values_hash = {}
          values.size.times do |i|
            value = values[i]
            # if value negative then set to 0 (heat losses will be in their own table with reversed logic)
            if value < 0.0
              value = 0.0
            end
            month = date_times[i].date.monthOfYear.valueName
            if surface_values_hash.has_key?(month)
              surface_values_hash[month] += value
            else
              surface_values_hash[month] = value
            end
          end

          # loop through has to populate row for table
          annual_total_ip = 0.0
          surface_values_hash.each do |month, monthly_value_si|
            monthly_value_ip = OpenStudio.convert(monthly_value_si, source_units, target_units).get

            # update value for total column
            annual_total_ip += monthly_value_ip

            # update value for totals row
            if monthly_totals.has_key?(month)
              monthly_totals[month][:total] += monthly_value_ip
            else
              monthly_totals[month] = {}
              monthly_totals[month][:total] = monthly_value_ip
            end

            # add sub-totals
            if surface.outsideBoundaryCondition == "Outdoors" && surface.surfaceType == "Wall"
              if monthly_totals[month].has_key?(:ext_wall)
                monthly_totals[month][:ext_wall] += monthly_value_ip
              else
                monthly_totals[month][:ext_wall] = monthly_value_ip
              end
            elsif surface.outsideBoundaryCondition == "Outdoors" && surface.surfaceType == "RoofCeiling"
              if monthly_totals[month].has_key?(:ext_roof)
                monthly_totals[month][:ext_roof] += monthly_value_ip
              else
                monthly_totals[month][:ext_roof] = monthly_value_ip
              end
            else
              # assume others are ground, could also include OtherSideConditionsModel, could be floor or walls
              if monthly_totals[month].has_key?(:ground)
                monthly_totals[month][:ground] += monthly_value_ip
              else
                monthly_totals[month][:ground] = monthly_value_ip
              end
            end
            monthly_value_ip_neat = OpenStudio::toNeatString(monthly_value_ip, 1, true)
            row_data << monthly_value_ip_neat
          end
          # add annual total
          row_data << OpenStudio::toNeatString(annual_total_ip, 1, true)
          monthly_surface_heat_gains_table[:data] << row_data
        else
          runner.registerWarning("Didn't find data for #{var} #{key}")
        end
      else
        runner.registerWarning('An annual simulation was not run. Cannot get annual timeseries data')
        return false
      end
    end

    # add total and sub-total rows
    row_data_total = ['Monthly Totals', '', '']
    row_data_sub_ext_wall = ['Monthly SubTotals', 'Wall', 'Outdoors']
    row_data_sub_ext_roof = ['Monthly SubTotals', 'Roof', 'Outdoors']
    row_data_sub_ground = ['Monthly SubTotals', '', 'Ground']
    row_data_total_annual = 0.0
    row_data_sub_ext_wall_annual = 0.0
    row_data_sub_ext_roof_annual = 0.0
    row_data_sub_ground_annual = 0.0
    monthly_totals.each do |month, hash|

      # add 0 value if key doesn't exist for surface type
      if not hash.has_key?(:ext_wall) then
        hash[:ext_wall] = 0
      end
      if not hash.has_key?(:ext_roof) then
        hash[:ext_roof] = 0
      end
      if not hash.has_key?(:ground) then
        hash[:ground] = 0
      end
      if not hash.has_key?(:total) then
        hash[:total] = 0
      end

      row_data_sub_ext_wall << OpenStudio::toNeatString(hash[:ext_wall], 1, true)
      row_data_sub_ext_wall_annual += hash[:ext_wall]
      row_data_sub_ext_roof << OpenStudio::toNeatString(hash[:ext_roof], 1, true)
      row_data_sub_ext_roof_annual += hash[:ext_roof]
      row_data_sub_ground << OpenStudio::toNeatString(hash[:ground], 1, true)
      row_data_sub_ground_annual += hash[:ground]
      row_data_total << OpenStudio::toNeatString(hash[:total], 1, true)
      row_data_total_annual += hash[:total]
    end

    # add annual total column in total and subtotal rows
    row_data_sub_ext_wall << OpenStudio::toNeatString(row_data_sub_ext_wall_annual, 1, true)
    row_data_sub_ext_roof << OpenStudio::toNeatString(row_data_sub_ext_roof_annual, 1, true)
    row_data_sub_ground << OpenStudio::toNeatString(row_data_sub_ground_annual, 1, true)
    row_data_total << OpenStudio::toNeatString(row_data_total_annual, 1, true)

    # register values
    runner.registerValue("ext_wall_heat_gain", row_data_sub_ext_wall.last.gsub(",", "").to_f, 'GJ')
    runner.registerValue("ext_roof_heat_gain", row_data_sub_ext_roof.last.gsub(",", "").to_f, 'GJ')
    runner.registerValue("ground_heat_gain", row_data_sub_ground.last.gsub(",", "").to_f, 'GJ')
    runner.registerValue("surface_heat_gain", row_data_total.last.gsub(",", "").to_f, 'GJ')

    # add rows
    monthly_surface_heat_gains_table[:data] << row_data_sub_ext_wall
    monthly_surface_heat_gains_table[:data] << row_data_sub_ext_roof
    monthly_surface_heat_gains_table[:data] << row_data_sub_ground
    monthly_surface_heat_gains_table[:data] << row_data_total

    return monthly_surface_heat_gains_table
  end

  # monthly_surface_heat_losses_and_losses_table rolled up from hourly values
  def self.monthly_surface_heat_losses_table(model, sqlFile, runner)

    # variables
    frequency = 'Hourly'
    var = 'Surface Inside Face Conduction Heat Transfer Energy'
    source_units = 'J'
    target_units = 'GJ'

    # create table
    monthly_surface_heat_losses_table = {}
    monthly_surface_heat_losses_table[:title] = "Surface Inside Face Conduction Heat Loss (#{target_units})" # heat losses will be in another table
    monthly_surface_heat_losses_table[:header] = ['', 'Surface Type', 'Ouside Boundary Condition', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Total']
    monthly_surface_heat_losses_table[:units] = [] # in title since all columns the same
    monthly_surface_heat_losses_table[:data] = []

    monthly_totals = {}
    model.getSurfaces.sort.each do |surface|
      next if surface.outsideBoundaryCondition == "Surface"
      next if surface.outsideBoundaryCondition == "Adiabatic"
      key = surface.name.to_s
      row_data = []
      row_data << surface.name.to_s
      row_data << surface.surfaceType
      row_data << surface.outsideBoundaryCondition

      # get time series hourly data
      ann_env_pd = OsLib_Reporting.ann_env_pd(sqlFile)
      if ann_env_pd

        # get timeseries data
        output_timeseries = sqlFile.timeSeries(ann_env_pd, frequency, var, key)
        if output_timeseries.is_initialized # checks to see if time_series exists
          values = output_timeseries.get.values
          date_times = output_timeseries.get.dateTimes

          # loop through hourly data
          surface_values_hash = {}
          values.size.times do |i|
            value = values[i]
            # if value positive then set to 0 (heat gains will be in their own table with reversed logic)
            if value > 0.0
              value = 0.0
            else
              value = value.abs
            end
            month = date_times[i].date.monthOfYear.valueName
            if surface_values_hash.has_key?(month)
              surface_values_hash[month] += value
            else
              surface_values_hash[month] = value
            end
          end

          # loop through has to populate row for table
          annual_total_ip = 0.0
          surface_values_hash.each do |month, monthly_value_si|
            monthly_value_ip = OpenStudio.convert(monthly_value_si, source_units, target_units).get

            # update value for total column
            annual_total_ip += monthly_value_ip

            # update value for totals row
            if monthly_totals.has_key?(month)
              monthly_totals[month][:total] += monthly_value_ip
            else
              monthly_totals[month] = {}
              monthly_totals[month][:total] = monthly_value_ip
            end

            # add sub-totals
            if surface.outsideBoundaryCondition == "Outdoors" && surface.surfaceType == "Wall"
              if monthly_totals[month].has_key?(:ext_wall)
                monthly_totals[month][:ext_wall] += monthly_value_ip
              else
                monthly_totals[month][:ext_wall] = monthly_value_ip
              end
            elsif surface.outsideBoundaryCondition == "Outdoors" && surface.surfaceType == "RoofCeiling"
              if monthly_totals[month].has_key?(:ext_roof)
                monthly_totals[month][:ext_roof] += monthly_value_ip
              else
                monthly_totals[month][:ext_roof] = monthly_value_ip
              end
            else
              # assume others are ground, could also include OtherSideConditionsModel, could be floor or walls
              if monthly_totals[month].has_key?(:ground)
                monthly_totals[month][:ground] += monthly_value_ip
              else
                monthly_totals[month][:ground] = monthly_value_ip
              end
            end

            monthly_value_ip_neat = OpenStudio::toNeatString(monthly_value_ip, 1, true)
            row_data << monthly_value_ip_neat
          end

          # add annual total
          row_data << OpenStudio::toNeatString(annual_total_ip, 1, true)
          monthly_surface_heat_losses_table[:data] << row_data
        else
          runner.registerWarning("Didn't find data for #{var} #{key}")
        end
      else
        runner.registerWarning('An annual simulation was not run. Cannot get annual timeseries data')
        return false
      end
    end

    # add total and sub-total rows
    row_data_total = ['Monthly Totals', '', '']
    row_data_sub_ext_wall = ['Monthly SubTotals', 'Wall', 'Outdoors']
    row_data_sub_ext_roof = ['Monthly SubTotals', 'Roof', 'Outdoors']
    row_data_sub_ground = ['Monthly SubTotals', '', 'Ground']
    row_data_total_annual = 0.0
    row_data_sub_ext_wall_annual = 0.0
    row_data_sub_ext_roof_annual = 0.0
    row_data_sub_ground_annual = 0.0
    monthly_totals.each do |month, hash|

      # add 0 value if key doesn't exist for surface type
      if not hash.has_key?(:ext_wall) then
        hash[:ext_wall] = 0
      end
      if not hash.has_key?(:ext_roof) then
        hash[:ext_roof] = 0
      end
      if not hash.has_key?(:ground) then
        hash[:ground] = 0
      end
      if not hash.has_key?(:total) then
        hash[:total] = 0
      end

      row_data_sub_ext_wall << OpenStudio::toNeatString(hash[:ext_wall], 1, true)
      row_data_sub_ext_wall_annual += hash[:ext_wall]
      row_data_sub_ext_roof << OpenStudio::toNeatString(hash[:ext_roof], 1, true)
      row_data_sub_ext_roof_annual += hash[:ext_roof]
      row_data_sub_ground << OpenStudio::toNeatString(hash[:ground], 1, true)
      row_data_sub_ground_annual += hash[:ground]
      row_data_total << OpenStudio::toNeatString(hash[:total], 1, true)
      row_data_total_annual += hash[:total]
    end

    # add annual total column in total and subtotal rows
    row_data_sub_ext_wall << OpenStudio::toNeatString(row_data_sub_ext_wall_annual, 1, true)
    row_data_sub_ext_roof << OpenStudio::toNeatString(row_data_sub_ext_roof_annual, 1, true)
    row_data_sub_ground << OpenStudio::toNeatString(row_data_sub_ground_annual, 1, true)
    row_data_total << OpenStudio::toNeatString(row_data_total_annual, 1, true)

    # add rows
    monthly_surface_heat_losses_table[:data] << row_data_sub_ext_wall
    monthly_surface_heat_losses_table[:data] << row_data_sub_ext_roof
    monthly_surface_heat_losses_table[:data] << row_data_sub_ground
    monthly_surface_heat_losses_table[:data] << row_data_total

    return monthly_surface_heat_losses_table
  end

  def self.steadySate_conductionheat_losses_section(model, sqlFile, runner, name_only = false)
    # create a second table
    steadySate_conductionheat_losses_table = {}
    steadySate_conductionheat_losses_table[:title] = ''
    steadySate_conductionheat_losses_table[:header] = ["Space name", "Surface name", "U value", "Exterior area", "Conductive heat loss"]
    steadySate_conductionheat_losses_table[:units] = ['', '', 'W/m2.K', 'm2', 'kW']
    steadySate_conductionheat_losses_table[:data] = []

    # gather data for section
    @steadySate_conductionheat_losses_section = {}
    @steadySate_conductionheat_losses_section[:title] = 'Steady state conductive heat loss'
    @steadySate_conductionheat_losses_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @steadySate_conductionheat_losses_section
    end

    # Calculate heat loss for each space
    # Get the outdoor design temperatures from necb_2015_table_c1#
    table_in_path = "#{File.dirname(__FILE__)}/necb_2015_table_c1.json"
    if File.exist?(table_in_path)
      table_in_path = table_in_path
    end
    file = ''
    File.open(table_in_path, 'r') do |file1|
      file = file1.read
    end

    data_hash1 = JSON.parse(file)
    all_keys = data_hash1.keys
    data_values = data_hash1.values[0]
    all_tables = data_values['necb_2015_table_c1']
    tables = all_tables['table']

    #Get City from the model
    city = model.weatherFile.get.city
    modelCity = city.split(" ").first

    outdoor_design_temp_heating = 0.0
    outdoor_design_temp_cooling = 0.0

    tables.each do |table|
      if modelCity == table['city']
        outdoor_design_temp_heating = table['design_temp_jan_2_5p']
        outdoor_design_temp_cooling = table['design_temp_july_2_5p_dry']
        break
      end
    end
    #convert from celsius to kelvin
    outdoor_design_temp_heating_k = outdoor_design_temp_heating + 273.15
    outdoor_design_temp_cooling_k = outdoor_design_temp_cooling + 273.15
    outdoor_design_temp_heating_F = (outdoor_design_temp_heating *9 / 5) + 32
    outdoor_design_temp_cooling_F = (outdoor_design_temp_cooling *9 / 5) + 32
    indoor_design_temp_heating = 21
    indoor_design_temp_heating_k = indoor_design_temp_heating + 273.15
    indoor_design_temp_cooling = 24
    indoor_design_temp_cooling_k = indoor_design_temp_cooling + 273.15
    indoor_design_temp_heating_F = (indoor_design_temp_heating *9 / 5) + 32
    indoor_design_temp_cooling_F = (indoor_design_temp_cooling *9 / 5) + 32
    #diff_heating_temp = indoor_design_temp_heating_F - outdoor_design_temp_heating_F
    diff_heating_temp = indoor_design_temp_heating_k - outdoor_design_temp_heating_k

    # Get spaces
    all_spaces = model.getBuilding.spaces
    @conductive_heat_loss = []
    count_extSpaces = 0
    spaces_count = model.getBuilding.spaces.count
    all_spaces.each do |space|
      netArea = 0.0
      sub_area = 0.0
      space_extWallArea = space.exteriorWallArea.to_f
      next if space_extWallArea == 0.0 # only outdoor spaces
      space_name = space.name
      surfaces_names = space.surfaces
      surfaces_names.each do |surface_name|
        next if surface_name.outsideBoundaryCondition != "Outdoors"
        netArea = surface_name.netArea
        #netArea_ft2 = netArea * 10.764
        cName = surface_name.construction.get
        uValue = surface_name.construction.get.thermalConductance.to_f
        uValue > 0.0001 ? (rValue = 5.678263337 / uValue) : (rValue = 10000)
        conductive_heatLoss = diff_heating_temp * uValue * netArea
        steadySate_conductionheat_losses_table[:data].push([space_name, surface_name.name, uValue.round(3), netArea.signif(3), (conductive_heatLoss / 1000).round(2)])

        surface_name.subSurfaces.each do |subsurf|
          #space_extWallArea = space.exteriorWallArea.to_f
          cName = subsurf.construction.get
          uValue_s = subsurf.construction.get.uFactor.to_f
          uValue_s > 0.0001 ? (rValue_s = 5.678263337 / uValue_s) : (rValue_s = 10000)
          sub_area = subsurf.netArea
          #sub_area_ft2 = sub_area * 10.764
          #netArea = netArea - sub_area
          conductive_heatLoss = diff_heating_temp * uValue_s * sub_area
          #conductive_heatLoss = diff_heating_temp / rValue_s * sub_area_ft2
          #conductive_heatLoss_kW = conductive_heatLoss * 0.000293071
          #@conductive_heat_loss.push([space_name, subsurf.name, uValue_s.round(3), sub_area.signif(3), (conductive_heatLoss / 1000).round(2)])
          steadySate_conductionheat_losses_table[:data].push([space_name, subsurf.name, uValue_s.round(3), sub_area.signif(3), (conductive_heatLoss / 1000).round(2)])
        end
      end
      space_extArea = space.exteriorArea.to_f
      count_extSpaces += 1
    end
    total_conductive_heat_loss = []
    @total_conductuctive_heatLoss = 0.0
    num_col = 4
    total_conductive_heat_loss = steadySate_conductionheat_losses_table[:data].map { |a| a[num_col] }
    for i in total_conductive_heat_loss
      @total_conductuctive_heatLoss += i.to_f
    end
    @total_conductuctive_heatLoss = @total_conductuctive_heatLoss.round(2)

    #steadySate_conductionheat_losses_table[:data] << @conductive_heat_loss
    if steadySate_conductionheat_losses_table[:data].size > 0
      @steadySate_conductionheat_losses_section[:tables] = [steadySate_conductionheat_losses_table] # only one table for this section
    else
      @steadySate_conductionheat_losses_section[:tables] = []
    end
    return @steadySate_conductionheat_losses_section
  end

  def self.thermal_zone_summary_section(model, sqlFile, runner, name_only = false)
    # create a second table
    thermal_zone_summary_information = {}
    thermal_zone_summary_information[:title] = '' # name will be with section
    thermal_zone_summary_information[:header] = ["Thermal Zone Name", "Space Name", "Volume", "Floor area", "Exterior Wall Area", "Roof Area"]
    thermal_zone_summary_information[:units] = ["", "", "m3", "m2", "m2", "m2"] # won't populate for this table since each row has different units
    thermal_zone_summary_information[:data] = []

    # gather data for section
    @thermal_zone_section = {}
    @thermal_zone_section[:title] = 'Thermal zones summary'
    @thermal_zone_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @thermal_zone_section
    end
    # Thermal zones
    zones = model.getThermalZones
    zones.each do |zone|
      first_row = true
      spaces = zone.spaces
      spaces.each do |space|
        first_row ? (zn = zone.name) : (zn = "")
        first_row = false

        # The exterior areas includes windows and skylights!
        thermal_zone_summary_information[:data].push([zn,
                                                      space.name,
                                                      space.volume.to_f.signif(3),
                                                      space.floorArea.to_f.signif(3),
                                                      space.exteriorWallArea.to_f.signif(3),
                                                      (space.exteriorArea.to_f - space.exteriorWallArea.to_f).signif(3)
                                                     ])
      end
    end

    if thermal_zone_summary_information[:data].size > 0
      @thermal_zone_section[:tables] = [thermal_zone_summary_information] # only one table for this section
    else
      @thermal_zone_section[:tables] = []
    end
    return @thermal_zone_section
  end

  def self.hvac_summary_section(model, sqlFile, runner, name_only = false)
    hvac_summary_data_table = {}
    hvac_summary_data_table[:title] = ''
    hvac_summary_data_table[:header] = ["HVAC loop name", "Supplied thermal zones"]
    hvac_summary_data_table[:units] = ['', '']
    hvac_summary_data_table[:data] = []

    # gather data for section
    @hvac_summary_table_section = {}
    @hvac_summary_table_section[:title] = 'Air Loops'
    @hvac_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @hvac_summary_table_section
    end

    # HVAC air loops
    air_loops = model.getAirLoopHVACs
    air_loops.each do |loop|
      hvac_summary_data_table[:data].push([loop.name, loop.thermalZones.count])
      zones = loop.thermalZones
    end

    # don't create empty table
    if hvac_summary_data_table[:data].size > 0
      @hvac_summary_table_section[:tables] = [hvac_summary_data_table] # only one table for this section
    else
      @hvac_summary_table_section[:tables] = []
    end
    return @hvac_summary_table_section
  end

  ###################### Copied from OpenStudio results
  # Generalized method for getting component performance characteristics
  def self.general_component_summary_logic(component)
    data_arrays = []
    is_ip_units = false
    # Convert to HVAC Component
    component = component.to_HVACComponent
    return data_arrays if component.empty?
    component = component.get
    # Skip object types that are not informative
    types_to_skip = ['SetpointManager:MixedAir', 'Node']
    idd_obj_type = component.iddObject.name.gsub('OS:', '')
    return data_arrays if types_to_skip.include?(idd_obj_type)

    # Only report the component type once
    comp_name_used = false

    # Airflow, heating and cooling capacity, and water flow
    summary_types = []
    summary_types << ['Air Flow Rate', 'maxAirFlowRate', 'm^3/s', 4, 'cfm', 0]
    summary_types << ['Heating Capacity', 'maxHeatingCapacity', 'W', 1, 'Btu/hr', 1]
    summary_types << ['Cooling Capacity', 'maxCoolingCapacity', 'W', 1, 'ton', 1]
    summary_types << ['Water Flow Rate', 'maxWaterFlowRate', 'm^3/s', 4, 'gal/min', 2]
    summary_types.each do |s|
      val_name = s[0]
      val_method = s[1]

      units_si = s[2]
      decimal_places_si = s[3]

      units_ip = s[4]
      decimal_places_ip = s[5]
      # Get the value and skip if not available
      val_si = component.public_send(val_method)
      next if val_si.empty?
      # Determine if the value was autosized or hard sized
      siz = 'Hard Sized'
      if component.public_send("#{val_method}Autosized").is_initialized
        if component.public_send("#{val_method}Autosized").get
          siz = 'Autosized'
        end
      end
      # Convert and report the value

      source_units = units_si
      if is_ip_units
        target_units = units_ip
        decimal_places = decimal_places_ip
      else
        target_units = source_units
        decimal_places = decimal_places_si
      end

      val_ip = OpenStudio.convert(val_si.get, source_units, target_units).get
      val_ip_neat = OpenStudio.toNeatString(val_ip, decimal_places, true)
      if is_ip_units
        data_arrays << ['', val_name, "#{val_ip_neat} #{units_ip}", siz, '']
      else
        data_arrays << ['', val_name, "#{val_ip_neat} #{units_si}", siz, '']
      end

    end
    perf_chars = component.performanceCharacteristics.each do |char|
      perf_val = char[0].to_s.to_f
      perf_name = char[1]
      display_units = '' # For Display
      # Unit conversion for pressure rise and pump head
      if perf_name.downcase.include?('pressure rise')
        source_units = 'Pa'
        if is_ip_units
          target_units = 'inH_{2}O'
          display_units = 'in w.g.'
        else
          target_units = source_units
          display_units = source_units
        end
        perf_val = OpenStudio.convert(perf_val, source_units, target_units).get
        perf_val = OpenStudio.toNeatString(perf_val, 2, true)
      elsif perf_name.downcase.include?('pump head')
        source_units = 'Pa'
        if is_ip_units
          target_units = 'ftH_{2}O'
          display_units = 'ft H2O'
          n_decimals = 1
        else
          target_units = source_units
          display_units = source_units
          n_decimals = 0
        end
        perf_val = OpenStudio.convert(perf_val, source_units, target_units).get
        perf_val = OpenStudio.toNeatString(perf_val, n_decimals, true)
      elsif perf_name.downcase.include?('efficiency') || perf_name.downcase.include?('effectiveness')
        display_units = '%'
        perf_val *= 100
        perf_val = OpenStudio.toNeatString(perf_val, 1, true)
      end
      # Report the value
      data_arrays << ['', perf_name, "#{perf_val} #{display_units}", '', '']
    end
    return data_arrays
  end

  # Gives the Plant Loop connection information for an HVAC Component
  def self.water_component_logic(component)
    data_arrays = []
    is_ip_units = false
    component = component.to_HVACComponent
    return data_arrays if component.empty?
    component = component.get

    # Only deal with plant-connected components
    return data_arrays unless component.respond_to?('plantLoop')

    # Report the plant loop name
    if component.plantLoop.is_initialized
      data_arrays << ['', 'Plant Loop', component.plantLoop.get.name, '', '']
    end

    return data_arrays
  end

  # Shows the calculated brake horsepower for fans and pumps
  def self.motor_component_logic(component)
    data_arrays = []
    is_ip_units = false
    # Skip exhaust fans for now because of bug in openstudio-standards
    return data_arrays if component.to_FanZoneExhaust.is_initialized

    concrete_comp = component.cast_to_concrete_type
    component = concrete_comp unless component.nil?

    # Only deal with plant-connected components
    return data_arrays unless component.respond_to?('brake_horsepower')

    # Report the plant loop name
    bhp = component.brake_horsepower
    bhp_neat = OpenStudio.toNeatString(bhp, 2, true)
    data_arrays << ['', 'Brake Horsepower', "#{bhp_neat} HP", '', '']
    return data_arrays
  end

  # Shows the setpoint manager details depending on type
  def self.spm_logic(component)
    data_arrays = []
    is_ip_units = false
    case component.iddObject.name
    when 'OS:SetpointManager:Scheduled'
      # Constrol type and temperature range
      setpoint = component.to_SetpointManagerScheduled.get
      supply_air_temp_schedule = setpoint.schedule
      schedule_values = OsLib_Schedules.getMinMaxAnnualProfileValue(component.model, supply_air_temp_schedule)
      if schedule_values.nil?
        schedule_values_pretty = "can't inspect schedule"
        target_units = ''
      else
        if setpoint.controlVariable.to_s == 'Temperature'
          #julien
          source_units = 'C'
          if is_ip_units
            target_units = 'F'
          else
            target_units = source_units
          end

          schedule_values_pretty = "#{OpenStudio.convert(schedule_values['min'], source_units, target_units).get.round(1)} to #{OpenStudio.convert(schedule_values['max'], source_units, target_units).get.round(1)}"
        else
          # TODO: - add support for other control variables
          schedule_values_pretty = "#{schedule_values['min']} to #{schedule_values['max']}"
          target_units = 'raw si values'
        end
      end
      data_arrays << ['', "Control Variable - #{setpoint.controlVariable}", "#{schedule_values_pretty} #{target_units}", '', '']

    when 'OS:SetpointManager:SingleZone:Reheat'
      # Control Zone
      setpoint = component.to_SetpointManagerSingleZoneReheat.get
      control_zone = setpoint.controlZone
      if control_zone.is_initialized
        control_zone_name = control_zone.get.name
      else
        control_zone_name = ''
      end
      data_arrays << ['', 'Control Zone', control_zone_name, '', '']

    when 'OS:SetpointManager:FollowOutdoorAirTemperature'
      setpoint = component.to_SetpointManagerFollowOutdoorAirTemperature.get
      ref_temp_type = setpoint.referenceTemperatureType
      data_arrays << [setpoint.iddObject.name, 'Reference Temperature Type', ref_temp_type, '', '']

    when 'OS:SetpointManager:OutdoorAirReset'
      setpoint = component.to_SetpointManagerOutdoorAirReset.get
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
      else
        target_units = source_units
      end
      wt_at_hi_oat_f = OpenStudio.convert(setpoint.setpointatOutdoorHighTemperature, source_units, target_units).get.round(1)
      wt_at_lo_oat_f = OpenStudio.convert(setpoint.setpointatOutdoorLowTemperature, source_units, target_units).get.round(1)
      hi_oat_f = OpenStudio.convert(setpoint.outdoorHighTemperature, source_units, target_units).get.round(1)
      lo_oat_f = OpenStudio.convert(setpoint.outdoorLowTemperature, source_units, target_units).get.round(1)
      #julien
      if is_ip_units
        desc = "#{wt_at_lo_oat_f} F to #{wt_at_hi_oat_f.round} F btwn OAT #{lo_oat_f} F to #{hi_oat_f} F."
      else
        desc = "#{wt_at_lo_oat_f} C to #{wt_at_hi_oat_f.round} C btwn OAT #{lo_oat_f} C to #{hi_oat_f} C."
      end

      data_arrays << [setpoint.iddObject.name, 'Reset', desc, '', '']

    when 'OS:SetpointManager:Warmest'
      setpoint = component.to_SetpointManagerWarmest.get
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
      else
        target_units = source_units
      end
      min_sat_f = OpenStudio.convert(setpoint.minimumSetpointTemperature, source_units, target_units).get.round(1)
      max_sat_f = OpenStudio.convert(setpoint.maximumSetpointTemperature, source_units, target_units).get.round(1)
      desc = "#{min_sat_f} #{target_units} to #{max_sat_f.round} #{target_units}"
      data_arrays << [setpoint.iddObject.name, 'Reset SAT per Worst Zone', desc, '', '']

    when 'OS:SetpointManager:WarmestTemperatureFlow'
      setpoint = component.to_SetpointManagerWarmestTemperatureFlow.get
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
      else
        target_units = source_units
      end
      min_sat_f = OpenStudio.convert(setpoint.minimumSetpointTemperature, source_units, target_units).get.round(1)
      max_sat_f = OpenStudio.convert(setpoint.maximumSetpointTemperature, source_units, target_units).get.round(1)
      desc = "#{min_sat_f} #{target_units} to #{max_sat_f.round} #{target_units}, #{setpoint.strategy}"
      data_arrays << [setpoint.iddObject.name, 'Reset SAT & Flow per Worst Zone', desc, '', '']
    end

    return data_arrays
  end

  # summary of what to show for each type of air loop component
  def self.air_loop_component_summary_logic(component, model)
    is_ip_units = false
    # Generic component logic first
    data_arrays = general_component_summary_logic(component)

    # Water component logic
    data_arrays += water_component_logic(component)

    # Motor component logic
    data_arrays += motor_component_logic(component)

    # Setpoint manager logic
    data_arrays += spm_logic(component)

    # Unique logic for subset of components
    case component.iddObject.name
    when 'OS:AirLoopHVAC:OutdoorAirSystem'
      component = component.to_AirLoopHVACOutdoorAirSystem.get
      controller_oa = component.getControllerOutdoorAir

      # Min OA
      #julien
      source_units = 'm^3/s'
      if is_ip_units
        target_units = 'cfm'
        n_decimals = 0
      else
        target_units = 'm^3/h'
        n_decimals = 0
      end

      if controller_oa.minimumOutdoorAirFlowRate.is_initialized
        value = OpenStudio.convert(controller_oa.minimumOutdoorAirFlowRate.get, source_units, target_units).get
        value_neat = OpenStudio.toNeatString(value, n_decimals, true)
        siz = 'Hard Sized'
      elsif controller_oa.autosizedMinimumOutdoorAirFlowRate.is_initialized
        value = OpenStudio.convert(controller_oa.autosizedMinimumOutdoorAirFlowRate.get, source_units, target_units).get
        value_neat = OpenStudio.toNeatString(value, n_decimals, true)
        siz = 'Autosized'
      else
        value_neat = 'Autosized'
      end
      data_arrays << ['', 'Minimum Outdoor Air Flow Rate', "#{value_neat} #{target_units}", siz, '']

      # Max OA
      if controller_oa.maximumOutdoorAirFlowRate.is_initialized
        value_ip = OpenStudio.convert(controller_oa.maximumOutdoorAirFlowRate.get, source_units, target_units).get
        value_ip_neat = OpenStudio.toNeatString(value_ip, n_decimals, true)
        siz = 'Hard Sized'
      elsif controller_oa.autosizedMaximumOutdoorAirFlowRate.is_initialized
        value_ip = OpenStudio.convert(controller_oa.autosizedMaximumOutdoorAirFlowRate.get, source_units, target_units).get
        value_ip_neat = OpenStudio.toNeatString(value_ip, n_decimals, true)
        siz = 'Autosized'
      else
        value_ip_neat = 'Autosized'
      end
      data_arrays << ['', 'Maximum Outdoor Air Flow Rate', "#{value_ip_neat} #{target_units}", siz, '']
    end

    # Make the component type the first element of the first row
    if !data_arrays.empty?
      data_arrays[0][0] = component.iddObject.name.gsub('OS:', '')
    end

    return data_arrays
  end

  # create table air loop summary
  def self.air_loops_detail_section(model, sqlFile, runner, name_only = false)
    is_ip_units = false
    # array to hold tables
    output_data_air_loop_tables = []

    # gather data for section
    @output_data_air_loop_section = {}
    @output_data_air_loop_section[:title] = 'Air Loops Detail'
    @output_data_air_loop_section[:tables] = output_data_air_loop_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @output_data_air_loop_section
    end

    # loop through air loops
    model.getAirLoopHVACs.sort.each do |air_loop|
      # air loop data output
      output_data_air_loops = {}
      output_data_air_loops[:title] = air_loop.name.get # TODO: - confirm first that it has name
      output_data_air_loops[:header] = ['Object', 'Description', 'Value', 'Sizing', 'Count']
      output_data_air_loops[:units] = [] # not using units for these tables
      output_data_air_loops[:data] = []

      output_data_air_loops[:data] << [{ sub_header: 'supply' }, '', '', '', '']

      # hold values for later use
      dcv_setting = 'na' # should hit this if there isn't an outdoor air object on the loop
      economizer_setting = 'na' # should hit this if there isn't an outdoor air object on the loop

      # loop through components
      air_loop.supplyComponents.each do |component|
        # skip some object types, but look for node with setpoint manager
        if component.to_Node.is_initialized
          setpoint_managers = component.to_Node.get.setpointManagers
          if !setpoint_managers.empty?
            # setpoint type
            setpoint = setpoint_managers[0] # TODO: - could have more than one in some situations
            data_arrays = OsLib_Reporting.air_loop_component_summary_logic(setpoint, model)
            data_arrays.each do |data_array|
              output_data_air_loops[:data] << data_array
            end
          end
        else
          # populate table for everything but setpoint managers, which are added above.
          data_arrays = OsLib_Reporting.air_loop_component_summary_logic(component, model)
          data_arrays.each do |data_array|
            output_data_air_loops[:data] << data_array
          end

        end

        # gather controls information to use later
        if component.to_AirLoopHVACOutdoorAirSystem.is_initialized
          hVACComponent = component.to_AirLoopHVACOutdoorAirSystem.get

          # get ControllerOutdoorAir
          controller_oa = hVACComponent.getControllerOutdoorAir
          # get ControllerMechanicalVentilation
          controller_mv = controller_oa.controllerMechanicalVentilation
          # get dcv value
          dcv_setting = controller_mv.demandControlledVentilation
          if dcv_setting
            dcv_setting = 'On'
          else
            dcv_setting = 'Off'
          end
          # get economizer setting
          economizer_setting = controller_oa.getEconomizerControlType
        end
      end

      output_data_air_loops[:data] << [{ sub_header: 'demand' }, '', '', '', '']
      # demand side summary, list of terminal types used, and number of zones
      thermal_zones = []
      terminals = []
      cooling_temp_ranges = []
      heating_temps_ranges = []
      air_loop.demandComponents.each do |component|
        # gather array of thermal zones and terminals
        if component.to_ThermalZone.is_initialized
          thermal_zone = component.to_ThermalZone.get
          thermal_zones << thermal_zone
          thermal_zone.equipment.each do |zone_equip|
            next if zone_equip.to_ZoneHVACComponent.is_initialized # should only find terminals
            terminals << zone_equip.iddObject.name.gsub('OS:', '')
          end

          # populate thermostat ranges
          if thermal_zone.thermostatSetpointDualSetpoint.is_initialized
            thermostat = thermal_zone.thermostatSetpointDualSetpoint.get
            if thermostat.coolingSetpointTemperatureSchedule.is_initialized
              schedule_values = OsLib_Schedules.getMinMaxAnnualProfileValue(model, thermostat.coolingSetpointTemperatureSchedule.get)
              unless schedule_values.nil?
                cooling_temp_ranges << schedule_values['min']
                cooling_temp_ranges << schedule_values['max']
              end
            end
            if thermostat.heatingSetpointTemperatureSchedule.is_initialized
              schedule_values = OsLib_Schedules.getMinMaxAnnualProfileValue(model, thermostat.heatingSetpointTemperatureSchedule.get)
              unless schedule_values.nil?
                heating_temps_ranges << schedule_values['min']
                heating_temps_ranges << schedule_values['max']
              end
            end
          end

        end
      end

      # get floor area of thermal zones
      total_loop_floor_area = 0
      thermal_zones.each do |zone|
        total_loop_floor_area += zone.floorArea
      end
      #julien
      source_units = 'm^2'
      if is_ip_units
        target_units = 'ft^2'
      else
        target_units = source_units
      end
      total_loop_floor_area_ip = OpenStudio.convert(total_loop_floor_area, source_units, target_units).get
      total_loop_floor_area_ip_neat = OpenStudio.toNeatString(total_loop_floor_area_ip, 0, true)

      # output zone and terminal data
      #julien
      if is_ip_units
        output_data_air_loops[:data] << ['Thermal Zones', 'Total Floor Area', "#{total_loop_floor_area_ip_neat} ft^2", '', thermal_zones.size]
      else
        output_data_air_loops[:data] << ['Thermal Zones', 'Total Floor Area', "#{total_loop_floor_area_ip_neat} m^2", '', thermal_zones.size]
      end
      if cooling_temp_ranges.empty?
        cooling_temp_ranges_pretty = "can't inspect schedules"

        #julien
        source_units = 'C'
        if is_ip_units
          target_units = 'F'
          target_units_display = "F"
        else
          target_units = source_units
          target_units_display = "C"
        end

      else
        cooling_temp_ranges_pretty = "#{OpenStudio.convert(cooling_temp_ranges.min, source_units, target_units).get.round(1)} to #{OpenStudio.convert(cooling_temp_ranges.max, source_units, target_units).get.round(1)}"
      end
      if heating_temps_ranges.empty?
        heating_temps_ranges_pretty = "can't inspect schedules"
      else
        heating_temps_ranges_pretty = "#{OpenStudio.convert(heating_temps_ranges.min, source_units, target_units).get.round(1)} to #{OpenStudio.convert(heating_temps_ranges.max, source_units, target_units).get.round(1)}"
      end

      #julien
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
        target_units_display = "F"
      else
        target_units = source_units
        target_units_display = "C"
      end
      #julien => ok? Tjs dans la boucle?
      output_data_air_loops[:data] << ['Thermal Zones', 'Cooling Setpoint Range', "#{cooling_temp_ranges_pretty} #{target_units_display}", '', '']
      output_data_air_loops[:data] << ['Thermal Zones', 'Heating Setpoint Range', "#{heating_temps_ranges_pretty} #{target_units_display}", '', '']
      output_data_air_loops[:data] << ['Terminal Types Used', terminals.uniq.sort.join(', '), '', '', terminals.size]

      # controls summary
      #julien
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
        target_units_display = "F"
      else
        target_units = source_units
        target_units_display = "C"
      end
      output_data_air_loops[:data] << [{ sub_header: 'controls' }, '', '', '', '']
      output_data_air_loops[:data] << ['HVAC Operation Schedule', '', air_loop.availabilitySchedule.name, '', ''] # I think this is a bool
      output_data_air_loops[:data] << ['Night Cycle Setting', '', air_loop.nightCycleControlType, '', '']
      output_data_air_loops[:data] << ['Economizer Setting', '', economizer_setting, '', '']
      output_data_air_loops[:data] << ['Demand Controlled Ventilation Status', '', dcv_setting, '', '']
      htg_sat_si = air_loop.sizingSystem.centralHeatingDesignSupplyAirTemperature
      htg_sat_ip = OpenStudio.toNeatString(OpenStudio.convert(htg_sat_si, source_units, target_units).get, 1, true)
      output_data_air_loops[:data] << ['Central Heating Design Supply Air Temperature', '', "#{htg_sat_ip} #{target_units_display}", '', '']
      clg_sat_si = air_loop.sizingSystem.centralCoolingDesignSupplyAirTemperature
      clg_sat_ip = OpenStudio.toNeatString(OpenStudio.convert(clg_sat_si, source_units, target_units).get, 1, true)
      output_data_air_loops[:data] << ['Central Cooling Design Supply Air Temperature', '', "#{clg_sat_ip} #{target_units_display}", '', '']
      output_data_air_loops[:data] << ['Load to Size On', '', air_loop.sizingSystem.typeofLoadtoSizeOn, '', '']

      # populate tables for section
      output_data_air_loop_tables << output_data_air_loops
    end

    return @output_data_air_loop_section
  end

  # summary of what to show for each type of plant loop component
  def self.plant_loop_component_summary_logic(component, model)
    is_ip_units = false
    # Generic component logic first
    data_arrays = general_component_summary_logic(component)

    # Motor component logic
    data_arrays += motor_component_logic(component)

    # Setpoint manager logic
    data_arrays += spm_logic(component)

    # Make the component type the first element of the first row
    if !data_arrays.empty?
      data_arrays[0][0] = component.iddObject.name.gsub('OS:', '')
    end

    return data_arrays
  end

  # create table plant loop summary
  def self.plant_loops_detail_section(model, sqlFile, runner, name_only = false)
    is_ip_units = false
    # array to hold tables
    output_data_plant_loop_tables = []

    # gather data for section
    @output_data_plant_loop_section = {}
    @output_data_plant_loop_section[:title] = 'Plant Loops Detail'
    @output_data_plant_loop_section[:tables] = output_data_plant_loop_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @output_data_plant_loop_section
    end

    # loop through plant loops
    model.getPlantLoops.sort.each do |plant_loop|
      ashpwh_flag = false
      # plant loop data output
      output_data_plant_loops = {}
      output_data_plant_loops[:title] = plant_loop.name.get # TODO: - confirm first that it has name
      output_data_plant_loops[:header] = ['Object', 'Description', 'Value', 'Sizing', 'Count']
      output_data_plant_loops[:units] = [] # not using units for these tables
      output_data_plant_loops[:data] = []

      output_data_plant_loops[:data] << [{ sub_header: 'supply' }, '', '', '', '']

      plant_loop.supplyComponents.each do |component|
        if component.to_ThermalZone.is_initialized
        end
        # skip some object types
        next if component.to_PipeAdiabatic.is_initialized
        next if component.to_Splitter.is_initialized
        next if component.to_Mixer.is_initialized
        if component.to_Node.is_initialized
          setpoint_managers = component.to_Node.get.setpointManagers
          if !setpoint_managers.empty?
            # setpoint type
            setpoint = setpoint_managers[0] # TODO: - could have more than one in some situations
            data_arrays = OsLib_Reporting.plant_loop_component_summary_logic(setpoint, model)
            data_arrays.each do |data_array|
              # typically just one, but in some cases there are a few
              output_data_plant_loops[:data] << data_array
            end
          end
        else
          # populate table for everything but setpoint managers, which are added above.
          #if the component is a waterheater, check if it's actually an ashpwh, if yes, get ashpwh data
          if component.to_WaterHeaterMixed.is_initialized and ashpwh_flag
            model.getWaterHeaterHeatPumps.each do |ashpwh|
              ashpwh_tank_name = ashpwh.tank.name.to_s
              wh_tank_name = component.to_WaterHeaterMixed.get.name.to_s
              if ashpwh_tank_name == wh_tank_name
                $ashpwh_flag = true
                ashp_component = ashpwh.dXCoil
                data_arrays = OsLib_Reporting.plant_loop_component_summary_logic(ashp_component, model)
                data_arrays.each do |data_array|
                  # typically just one, but in some cases there are a few
                  output_data_plant_loops[:data] << data_array
                end
              end
            end
          end
          # populate table for everything but setpoint managers, which are added above.
          data_arrays = OsLib_Reporting.plant_loop_component_summary_logic(component, model)
          data_arrays.each do |data_array|
            # typically just one, but in some cases there are a few
            output_data_plant_loops[:data] << data_array
          end
        end
      end

      # loop through demand components
      output_data_plant_loops[:data] << [{ sub_header: 'demand' }, '', '', '', '']

      # keep track of terminal count to report later
      terminal_connections = [] # Not sure how I want to list in display

      # loop through plant demand components
      plant_loop.demandComponents.each do |component|
        # flag for terminal connecxtions
        terminal_connection = false

        # skip some object types
        next if component.to_PipeAdiabatic.is_initialized
        next if component.to_Splitter.is_initialized
        next if component.to_Mixer.is_initialized
        next if component.to_Node.is_initialized

        # determine if water to air
        if component.to_WaterToAirComponent.is_initialized
          component = component.to_WaterToAirComponent.get
          if component.airLoopHVAC.is_initialized
            description = 'Air Loop'
            value = component.airLoopHVAC.get.name
          else
            # this is a terminal connection
            terminal_connection = true
            terminal_connections << component
          end
        elsif component.to_WaterToWaterComponent.is_initialized
          description = 'Plant Loop'
          component = component.to_WaterToWaterComponent.get
          ww_loop = component.plantLoop
          if ww_loop.is_initialized
            value = ww_loop.get.name
          else
            value = ''
          end
        else
          # water use connections would go here
          description = component.name
          value = ''
        end

        # don't report here if this component is connected to a terminal
        next if terminal_connection == true

        output_data_plant_loops[:data] << [component.iddObject.name.gsub('OS:', ''), description, value, '', '']
      end

      # report terminal connections
      if !terminal_connections.empty?
        output_data_plant_loops[:data] << ['Air Terminal Connections', '', '', '', terminal_connections.size]
      end

      output_data_plant_loops[:data] << [{ sub_header: 'controls' }, '', '', '', '']

      # Min loop flow rate
      source_units = 'm^3/s'
      if is_ip_units
        target_units = 'gal/min'
        n_decimals = 2
      else
        target_units = 'm^3/h'
        n_decimals = 0
      end
      if plant_loop.minimumLoopFlowRate.is_initialized
        value = OpenStudio.convert(plant_loop.minimumLoopFlowRate.get, source_units, target_units).get
        value_neat = OpenStudio.toNeatString(value, n_decimals, true)
        siz = 'Hard Sized'
      elsif plant_loop.autosizedMinimumLoopFlowRate.is_initialized
        value = OpenStudio.convert(plant_loop.autosizedMinimumLoopFlowRate.get, source_units, target_units).get
        value_neat = OpenStudio.toNeatString(value, n_decimals, true)
        siz = 'Autosized'
      else
        value_neat = 'Autosized'
      end
      output_data_plant_loops[:data] << ['Loop Flow Rate Range', 'Minimum Loop Flow Rate', "#{value_neat} #{target_units}", siz, '']

      # Max loop flow rate
      if plant_loop.maximumLoopFlowRate.is_initialized
        value = OpenStudio.convert(plant_loop.maximumLoopFlowRate.get, source_units, target_units).get
        value_neat = OpenStudio.toNeatString(value, n_decimals, true)
        siz = 'Hard Sized'
      elsif plant_loop.autosizedMaximumLoopFlowRate.is_initialized
        value = OpenStudio.convert(plant_loop.autosizedMaximumLoopFlowRate.get, source_units, target_units).get
        value_neat = OpenStudio.toNeatString(value, n_decimals, true)
        siz = 'Autosized'
      else
        value_neat = 'Autosized'
      end
      output_data_plant_loops[:data] << ['Loop Flow Rate Range', 'Maximum Loop Flow Rate', "#{value_neat} #{target_units}", siz, '']

      # loop temperatures
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
      else
        target_units = 'C'
      end
      min_temp = plant_loop.minimumLoopTemperature
      max_temp = plant_loop.maximumLoopTemperature
      value_neat = "#{OpenStudio.convert(min_temp, source_units, target_units).get.round(1)} to #{OpenStudio.convert(max_temp, source_units, target_units).get.round(1)}"
      output_data_plant_loops[:data] << ['Loop Temperature Range', '', "#{value_neat} #{target_units}", '', '']

      # get values out of sizing plant
      sizing_plant = plant_loop.sizingPlant
      source_units = 'C'
      if is_ip_units
        target_units = 'F'
      else
        target_units = 'C'
      end
      loop_exit_temp = sizing_plant.designLoopExitTemperature
      value_neat = OpenStudio.toNeatString(OpenStudio.convert(loop_exit_temp, source_units, target_units).get, 1, true)

      output_data_plant_loops[:data] << ['Loop Design Exit Temperature', '', "#{value_neat} #{target_units}", '', '']
      source_units = 'K'
      if is_ip_units
        target_units = 'R'
      else
        target_units = 'K'
      end
      loop_design_temp_diff = sizing_plant.loopDesignTemperatureDifference
      value_neat = OpenStudio.toNeatString(OpenStudio.convert(loop_design_temp_diff, source_units, target_units).get, 1, true)
      output_data_plant_loops[:data] << ['Loop Design Temperature Difference', '', "#{value_neat} #{target_units}", '', '']

      # Equipment staging
      output_data_plant_loops[:data] << ['Equipment Loading/Staging', '', plant_loop.loadDistributionScheme, '', '']

      # push tables
      output_data_plant_loop_tables << output_data_plant_loops
    end
    return @output_data_plant_loop_section
  end

  # summary of what to show for each type of zone equipment component
  def self.zone_equipment_component_summary_logic(component, model)
    is_ip_units = false
    # Generic component logic first
    data_arrays = general_component_summary_logic(component)
    # Motor component logic
    data_arrays += motor_component_logic(component)
    # Make the component type the first element of the first row
    if !data_arrays.empty?
      data_arrays[0][0] = component.iddObject.name.gsub('OS:', '')
    end

    return data_arrays
  end

  # create table zone eq loop summary
  def self.zone_equipment_detail_section(model, sqlFile, runner, name_only = false)
    is_ip_units = false
    # array to hold tables
    output_data_zone_equipment = []
    # gather data for section
    @output_data_zone_equipment_section = {}
    @output_data_zone_equipment_section[:title] = 'Zone Equipment Detail'
    @output_data_zone_equipment_section[:tables] = output_data_zone_equipment

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @output_data_zone_equipment_section
    end
    # loop through thermal zones
    model.getThermalZones.sort.each do |zone|
      # plant loop data output
      output_data_zone_equipment = {}
      output_data_zone_equipment[:title] = zone.name.get # TODO: - confirm that zone has a name
      output_data_zone_equipment[:header] = ['Object', 'Description', 'Value', 'Sizing', 'Count']
      output_data_zone_equipment[:units] = [] # not using units for these tables
      output_data_zone_equipment[:data] = []
      zone.equipment.sort.each do |zone_equip|
        next unless zone_equip.to_ZoneHVACComponent.is_initialized # skip any terminals
        data_arrays = OsLib_Reporting.zone_equipment_component_summary_logic(zone_equip, model)
        data_arrays.each do |data_array|
          # typically just one, but in some cases there are a few
          output_data_zone_equipment[:data] << data_array
        end
        # Make the component type the first element of the first row
        if !data_arrays.empty?
          data_arrays[0][0] = zone_equip.iddObject.name.gsub('OS:', '')
        end
      end
      # push table to array
      if !output_data_zone_equipment[:data].empty?
        @output_data_zone_equipment_section[:tables] << output_data_zone_equipment
      end
    end
    return @output_data_zone_equipment_section
  end

  ####################### Edward's section
  def self.hvac_airloops_detailed_section1(model, sqlFile, runner, name_only = false)

    airloop_system = {}
    airloop_system[:title] = ''
    airloop_system[:header] = ["Parameter", "Value"]
    airloop_system[:units] = ['', '']
    airloop_system[:data] = []

    # gather data for section
    @airLoops_summary_table_section = {}
    @airLoops_summary_table_section[:title] = 'Air Loops Summary'
    @airLoops_summary_table_section[:data] = []
    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @airLoops_summary_table_section
    end
    ################################################3
    data_arrays = OsLib_Reporting.air_loops_detail_section(model, sqlFile, runner)

    airloops = data_arrays[:tables] #array of hashes, each hash contains a zone's zone equipment
    airloops.each do |airloop|
      #airloop is a hash, each hash contains info of its own components
      #temporary variable, flag
      return_fan_flag = true # used to identify return and supply fans in VAV systems
      #Name and type of hvac
      #airloop_system["Name"] = airloop[:title] #>>>>>>>>>>>>
      airloop_system[:data] << ["Name", airloop[:title]]
      if airloop[:title].include?("Sys_1") or airloop[:title].include?("SYS_1")
        airloop_system[:data] << ["Type of HVAC", "Unitary AC"]
      elsif airloop[:title].include?("Sys_2") or airloop[:title].include?("SYS_2")
        airloop_system[:data] << ["Type of HVAC", "4-pipe FCU"]
      elsif airloop[:title].include?("Sys_3") or airloop[:title].include?("SYS_3")
        airloop_system[:data] << ["Type of HVAC", "Single Zone Packaged RTU"]
      elsif airloop[:title].include?("Sys_4") or airloop[:title].include?("SYS_4")
        airloop_system[:data] << ["Type of HVAC", "Single Zone MAU"]
      elsif airloop[:title].include?("Sys_5") or airloop[:title].include?("SYS_5")
        airloop_system[:data] << ["Type of HVAC", "2-pipe FCU"]
      elsif airloop[:title].include?("Sys_6") or airloop[:title].include?("SYS_6")
        airloop_system[:data] << ["Type of HVAC", "Multizone VAV"]
      elsif airloop[:title].include?("Sys_7") or airloop[:title].include?("SYS_7")
        airloop_system[:data] << ["Type of HVAC", "Unitary AC"]
      end
      #go through the components of this hvac (air loop)
      airloop_data = airloop[:data] # airloop_data is an array of component data
      airloop_data.each_with_index do |component_data, component_index|
        #component_data is an array, each array is a line of data of the coil/fan/outdoor system etc
        #loop through specific parameters
        if component_data[0].include?('Coil:Cooling:DX')
          airloop_system[:data] << ["Cooling System", "DX Cooled"]
          component = airloop_data[component_index + 1]
          airloop_system[:data] << ["Cooling Capacity", component[2]]
          component = airloop_data[component_index + 2]
          airloop_system[:data] << ["Cooling Rated COP", component[2]]
        elsif component_data[0].include?('Coil:Cooling:Water')
          airloop_system[:data] << ["Cooling System", "Water Cooled"]
          airloop_system[:data] << ["Cooling Capacity", "NA"]
          component = airloop_data[component_index + 1]
          airloop_system[:data] << ["Cooling Water Flowrate", component[2]]
        elsif component_data[0].include?('Coil:Heating:Water')
          airloop_system[:data] << ["Heating System", "Hot Water"]
          airloop_system[:data] << ["Heating Capacity", component_data[2]]
          component = airloop_data[component_index + 1]
          airloop_system[:data] << ["Heating Water Flowrate", component[2]]
        elsif component_data[0].include?('Coil:Heating:Gas')
          airloop_system[:data] << ["Heating System", "Fuel"]
          airloop_system[:data] << ["Heating Capacity", component_data[2]]
          component = airloop_data[component_index + 1]
          airloop_system[:data] << ["Efficiency", component[2]]
        elsif component_data[0].include?('Coil:Heating:Electric')
          airloop_system[:data] << ["Heating System", "Electric"]
          airloop_system[:data] << ["Heating Capacity", component_data[2]]
          component = airloop_data[component_index + 1]
          airloop_system[:data] << ["Efficiency", component[2]]
        elsif component_data[0].include?('Fan:ConstantVolume')
          airloop_system[:data] << ["Fan Type", "Constant"]
          airloop_system[:data] << ["Flowrate", component_data[2]]
          component = airloop_data[component_index + 2]
          airloop_system[:data] << ["Pressure", component[2]]
          #component = airloop_data[component_index+2]
          #airloop_system["Efficiency"] = component[2]
        elsif component_data[0].include?('Fan:VariableVolume') # sometimes there are 2 variable fans
          if return_fan_flag
            #if there is a return fan, there must be a supply fan. Declare these parameters first
            airloop_system[:data] << ["Supply Fan Type", ""]
            airloop_system[:data] << ["Supply Fan Flowrate", ""]
            airloop_system[:data] << ["Supply Fan Pressure", ""]
            #now do return fan
            airloop_system[:data] << ["Return Fan Type", "Variable"]
            airloop_system[:data] << ["Return Fan Flowrate", component_data[2]]
            component = airloop_data[component_index + 2]
            airloop_system[:data] << ["Return Fan Pressure", component[2]]
            return_fan_flag = false
          else
            airloop_system[:data] << ["Supply Fan Type", "Variable"]
            airloop_system[:data] << ["Supply Fan Flowrate", component_data[2]]
            component = airloop_data[component_index + 2]
            airloop_system[:data] << ["Supply Fan Pressure", component[2]]
          end
        elsif component_data[0].include?('HeatExchanger:AirToAir:SensibleAndLatent')
          #check if it's an ERV
          total_latent_eff = 0
          l_eff1 = airloop_data[component_index + 2]
          total_latent_eff = +l_eff1[2].to_f
          l_eff1 = airloop_data[component_index + 4]
          total_latent_eff = +l_eff1[2].to_f
          l_eff1 = airloop_data[component_index + 6]
          total_latent_eff = +l_eff1[2].to_f
          l_eff1 = airloop_data[component_index + 8]
          total_latent_eff = +l_eff1[2].to_f
          if total_latent_eff > 1
            erv_hrv = "ERV"
          else
            erv_hrv = "HRV"
          end
          #record effectiveness
          component = airloop_data[component_index + 1]
          airloop_system[:data] << ["#{erv_hrv} Sensible Effectiveness 100% Heating Air Flow", component[2]]
          component = airloop_data[component_index + 2]
          airloop_system[:data] << ["#{erv_hrv} Latent Effectiveness 100% Heating Air Flow", component[2]]
          component = airloop_data[component_index + 3]
          airloop_system[:data] << ["#{erv_hrv} Sensible Effectiveness 75% Heating Air Flow", component[2]]
          component = airloop_data[component_index + 4]
          airloop_system[:data] << ["#{erv_hrv} Latent Effectiveness 75% Heating Air Flow", component[2]]
          component = airloop_data[component_index + 5]
          airloop_system[:data] << ["#{erv_hrv} Sensible Effectiveness 100% Cooling Air Flow", component[2]]
          component = airloop_data[component_index + 6]
          airloop_system[:data] << ["#{erv_hrv} Latent Effectiveness 100% Cooling Air Flow", component[2]]
          component = airloop_data[component_index + 7]
          airloop_system[:data] << ["#{erv_hrv} Sensible Effectiveness 75% Heating Air Flow", component[2]]
          component = airloop_data[component_index + 8]
          airloop_system[:data] << ["#{erv_hrv} Latent Effectiveness 75% Cooling Air Flow", component[2]]
        elsif component_data[0].include?("Terminal Types Used")
          #variables used navigate list of terminals from hash
          counter = 0
          controls_flag = false
          #sets unrecognized terminal key
          airloop_system[:data] << ["Terminals not recognized", 0]

          #loop get all the parameers of every air terminal used by this air loop and express as an average
          while !controls_flag
            component = airloop_data[component_index + counter]
            #filters terminals based on type
            if component[0].class == Hash #has hit the controls ssection, end of terminals, stop
              controls_flag = true
            elsif component[1] == "AirTerminal:SingleDuct:ConstantVolume:NoReheat"
              airloop_system[:data] << ["Number of CAV RH Terminals ", component[4]]
            elsif component[1] == "AirTerminal:SingleDuct:VAV:NoReheat" or component[1] == "AirTerminal:SingleDuct:VAV:HeatAndCool:NoReheat"
              airloop_system[:data] << ["Number of VAV Terminals (No RH)", component[4]]
            elsif component[1] == "AirTerminal:SingleDuct:ConstantVolume:Reheat" or component[1] == "AirTerminal:SingleDuct:VAV:Reheat"
              #both terminals uses the same type of reheat coils
              #temporary variables
              terminal_type = ""
              terminal_list = []
              terminal_maxflowrate_sum = 0
              terminal_waterflowrate_sum = 0
              terminal_water_capacity_sum = 0
              gas_terminal_capacity_sum = 0
              elec_terminal_capacity_sum = 0
              gas_terminal_efficiency_sum = 0
              elec_terminal_efficiency_sum = 0
              num_elec_rh = 0
              num_gas_rh = 0
              num_water_rh = 0

              if component[1] == "AirTerminal:SingleDuct:ConstantVolume:NoReheat"
                terminal_type = "CAV RH Terminal"
                terminal_list = model.getAirTerminalSingleDuctConstantVolumeReheats
              else
                terminal_type = "VAV RH Terminals"
                terminal_list = model.getAirTerminalSingleDuctVAVReheats
              end

              #same code for both types of terminals - get reheat coil parameters
              airloop_system[:data] << ["Number of #{terminal_type}", component[4]]
              #loop thru each terminal and get its RH parameters
              terminal_list.each do |terminal|
                #add up max air flowrate
                if terminal.autosizedMaximumAirFlowRate.is_initialized
                  terminal_maxflowrate_sum += terminal.autosizedMaximumAirFlowRate.get
                else
                  terminal_maxflowrate_sum += terminal.maximumAirFlowRate.get
                end

                #determine type of reheat coil
                if terminal.reheatCoil.to_CoilHeatingWater.is_initialized #water coil
                  num_water_rh += 1
                  #store water flowrate
                  if terminal.reheatCoil.to_CoilHeatingWater.get.maximumWaterFlowRate.is_initialized
                    terminal_waterflowrate_sum += terminal.reheatCoil.to_CoilHeatingWater.get.maximumWaterFlowRate.to_f
                    terminal_water_capacity_sum += terminal.reheatCoil.to_CoilHeatingWater.get.autosizedRatedCapacity.to_f
                  else
                    terminal_waterflowrate_sum += terminal.reheatCoil.to_CoilHeatingWater.get.autosizedMaximumWaterFlowRate.to_f
                    terminal_water_capacity_sum += terminal.reheatCoil.to_CoilHeatingWater.get.autosizedRatedCapacity.to_f
                  end
                elsif terminal.reheatCoil.to_CoilHeatingGas.is_initialized #gas coil
                  num_gas_rh += 1
                  # store capacity
                  if terminal.reheatCoil.to_CoilHeatingGas.get.nominalCapacity.is_initialized
                    gas_terminal_capacity_sum += terminal.reheatCoil.to_CoilHeatingGas.get.nominalCapacity.get.to_f
                  else
                    gas_terminal_capacity_sum += terminal.reheatCoil.to_CoilHeatingGas.get.autosizedNominalCapacity.get.to_f
                  end
                elsif terminal.reheatCoil.to_CoilHeatingElectric.is_initialized #electric coil
                  num_elec_rh += 1
                  # store capacity
                  if terminal.reheatCoil.to_CoilHeatingElectric.get.nominalCapacity.is_initialized
                    elec_terminal_capacity_sum += terminal.reheatCoil.to_CoilHeatingElectric.get.nominalCapacity.get.to_f
                  else
                    elec_terminal_capacity_sum += terminal.reheatCoil.to_CoilHeatingElectric.get.autosizedNominalCapacity.get.to_f
                  end
                end

              end # end of terminal_list.each do |terminal|

              #compute and store the avg reheat coil parameters
              if num_water_rh > 0
                airloop_system[:data] << ["Average #{terminal_type} Water RH Water Flowrate (m3/s)", terminal_waterflowrate_sum / num_water_rh]
                airloop_system[:data] << ["Average #{terminal_type} Water RH Capacity (W)", terminal_water_capacity_sum / num_water_rh.round]
              end
              if num_gas_rh > 0
                airloop_system[:data] << ["Average #{terminal_type} Gas RH Capacity (W)", gas_terminal_capacity_sum / num_gas_rh.round]
              end
              if num_elec_rh > 0
                airloop_system[:data] << ["Average #{terminal_type} Electric RH Capacity (W)", elec_terminal_capacity_sum / num_gas_rh.round]
              end

            elsif component[1].include?("AirTerminal") #catches terminals not defined above
              airloop_system["Terminals not recognized"] += component[4]
            end
            counter += 1
          end
          #eval("airloop_terminals = OsLib_Reporting.#{section_name}(model,sql_file,runner,false,false)")
        end
      end
      # add this AHU to the list of AHU
      # airloop_system
    end #end of airloops.each do |airloop|
    # @airLoops_summary_table_section << [airloop_system]
    #Check if there are VRF outdoor units
    if model.getAirConditionerVariableRefrigerantFlows.size > 0
      vrf_system = {}
      #record outdoor unit parameters
      vrf_units = model.getAirConditionerVariableRefrigerantFlows
      vrf_units.each_with_index do |vrf_unit, index|
        #use autosized value if it exists
        #number of compressors
        airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} No. of Compressors", vrf_unit.numberofCompressors]
        # heat recovery
        if vrf_unit.heatPumpWasteHeatRecovery
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Heat Recovery", "Yes"]
        else
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Heat Recovery", "No - Heat Pump Only"]
        end
        #Rated cooling
        if vrf_unit.autosizedRatedTotalCoolingCapacity.is_initialized
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Cooling Cap (W)", vrf_unit.autosizedRatedTotalCoolingCapacity.get]
        else
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Cooling Cap (W)", vrf_unit.ratedTotalCoolingCapacity.get]
        end
        #rated heating
        if vrf_unit.autosizedRatedTotalHeatingCapacity.is_initialized
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Heating Cap (W)", vrf_unit.autosizedRatedTotalHeatingCapacity.get]
        else
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Heating Cap (W)", vrf_unit.ratedTotalHeatingCapacity.get]
        end
        #rated COPs
        airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Heating COP", vrf_unit.ratedHeatingCOP]
        airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Cooling COP", vrf_unit.ratedCoolingCOP]
        #evaporative air flow rate
        if vrf_unit.autosizedEvaporativeCondenserAirFlowRate.is_initialized
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Evaporative Condenser Airflow (m3/s)", vrf_unit.autosizedEvaporativeCondenserAirFlowRate.get]
        else
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Evaporative Condenser Airflow (m3/s)", vrf_unit.evaporativeCondenserAirFlowRate.get]
        end
        #Defrost
        if vrf_unit.autosizedResistiveDefrostHeaterCapacity.is_initialized
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Defrost Capacity", vrf_unit.autosizedResistiveDefrostHeaterCapacity.get]
        else
          airloop_system[:data] << ["VRF Outdoor Unit-#{index + 1} Defrost Capacity", vrf_unit.resistiveDefrostHeaterCapacity.get]
        end
      end # end of vrf_units.each_with_index do |vrf_unit,index|

      #record vrf indoor unit parameters
      if model.getZoneHVACTerminalUnitVariableRefrigerantFlows.size > 0
        #hash for different terminal units
        vrf_terminal = {}
        #temporary variables
        vrf_terminal_counter = 0
        vrf_max_airflow_array = []
        vrf_max_heat_cap = []
        vrf_max_cool_cap = []

        vrf_terminals = model.getZoneHVACTerminalUnitVariableRefrigerantFlows
        vrf_terminals.each do |vrf_terminal|
          vrf_terminal_counter += 1
          #get the max flowrate - following os_lib vrf terminal method
          if vrf_terminal.autosizedSupplyAirFlowRateDuringCoolingOperation.is_initialized
            vrf_max_airflow_array << vrf_terminal.autosizedSupplyAirFlowRateDuringCoolingOperation.get
          else
            vrf_max_airflow_array << vrf_terminal.supplyAirFlowRateDuringCoolingOperation.get
          end
          if vrf_terminal.autosizedSupplyAirFlowRateWhenNoCoolingisNeeded.is_initialized
            vrf_max_airflow_array << vrf_terminal.autosizedSupplyAirFlowRateWhenNoCoolingisNeeded.get
          else
            vrf_max_airflow_array << vrf_terminal.supplyAirFlowRateWhenNoCoolingisNeeded.get
          end

          if vrf_terminal.autosizedSupplyAirFlowRateDuringHeatingOperation.is_initialized
            vrf_max_airflow_array << vrf_terminal.autosizedSupplyAirFlowRateDuringHeatingOperation.get
          else
            vrf_max_airflow_array << vrf_terminal.supplyAirFlowRateDuringHeatingOperation.get
          end

          if vrf_terminal.autosizedSupplyAirFlowRateWhenNoHeatingisNeeded.is_initialized
            vrf_max_airflow_array << vrf_terminal.autosizedSupplyAirFlowRateWhenNoHeatingisNeeded.get
          else
            vrf_max_airflow_array << vrf_terminal.supplyAirFlowRateWhenNoHeatingisNeeded.get
          end
          #cooling capacity
          if vrf_terminal.coolingCoil.is_initialized
            if vrf_terminal.coolingCoil.get.autosizedRatedTotalCoolingCapacity.is_initialized
              vrf_max_cool_cap << vrf_terminal.coolingCoil.get.autosizedRatedTotalCoolingCapacity.get

            else
              vrf_max_cool_cap << vrf_terminal.coolingCoil.get.ratedTotalCoolingCapacity.get
            end
          end
          #heating capacity
          if vrf_terminal.heatingCoil.is_initialized
            if vrf_terminal.heatingCoil.get.autosizedRatedTotalHeatingCapacity.is_initialized
              vrf_max_heat_cap << vrf_terminal.heatingCoil.get.autosizedRatedTotalHeatingCapacity.get
            else
              vrf_max_heat_cap << vrf_terminal.heatingCoil.get.ratedTotalHeatingCapacity.get
            end
          end
        end # vrf_terminals.each do |vrf_terminal|
        airloop_system[:data] << ["VRF Terminal Unit Max Airflow", vrf_max_airflow_array.max]
        airloop_system[:data] << ["VRF Terminal Unit Max Heating Capacity", vrf_max_heat_cap.max]
        temp_cool_max = vrf_max_cool_cap.max.to_s << "- this does not match with Eplus html (OS problem)"
        airloop_system[:data] << ["VRF Terminal Unit Max Cooling Capacity", temp_cool_max]

      end # end of model.getZoneHVACTerminalUnitVariableRefrigerantFlows.size > 0
      #@airLoops_summary_table_section << [airloop_system]
    end # end of if model.getAirConditionerVariableRefrigerantFlows.is_initialized
    # @airLoops_summary_table_section << [airloop_system]
    @airLoops_summary_table_section[:tables] = [airloop_system]
    return @airLoops_summary_table_section
    #####################
  end

  def self.hvac_plantloops_detailed_section1(model, sqlFile, runner, name_only = false)

    plantloop_system = {}
    plantloop_system[:title] = ''
    plantloop_system[:header] = ["Parameter", "Value"]
    plantloop_system[:units] = ['', '']
    plantloop_system[:data] = []

    # gather data for section
    @plantLoops_summary_table_section = {}
    @plantLoops_summary_table_section[:title] = 'Plant Loops Summary'
    @plantLoops_summary_table_section[:data] = []
    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @plantLoops_summary_table_section
    end
    ################################################3
    data_arrays = OsLib_Reporting.plant_loops_detail_section(model, sqlFile, runner, name_only = false)
    #Plant loop description
    plantloops = data_arrays[:tables] #array of hashes, each hash contains a zone's zone equipment
    plantloops.each do |plantloop|
      #plantloop is a hash, each hash contains info of its own components
      #temporary variable, flag
      one_chiller = true
      one_pump = true # used to identify return and supply pumps if any

      #Name
      plantloop_system[:data] << ["Name", plantloop[:title]]
      #go through the components of this plant loop
      plantloop_data = plantloop[:data] # plantloop_data is an array of component data
      plantloop_data.each_with_index do |component_data, component_index|
        #component_data is an array, each array is a line of data of the boiler, chiller, pump system etc
        #loop through specific components
        if component_data[0].include?('Chiller:Electric:EIR')
          if one_chiller
            plantloop_system[:data] << ["Cooling Equipment", component_data[0]]
            plantloop_system[:data] << ["Cooling Capacity", component_data[2]]
            component = plantloop_data[component_index + 1]
            plantloop_system[:data] << ["Cooling Water Flowrate", component[2]]
            component = plantloop_data[component_index + 2]
            plantloop_system[:data] << ["Cooling Ref COP", component[2]]
            one_chiller = false
          else
            #there are at most 2 chillers
            capacity = component_data[2]
            capacity = capacity.gsub(/ W/, "")
            if capacity.to_f > 1 #sometimes a 2nd 0W chiller exists, ignore it
              plantloop_system[:data] << ["2nd Cooling Equipment", component_data[0]]
              plantloop_system[:data] << ["2nd Cooling Capacity", component_data[2]]
              component = plantloop_data[component_index + 2]
              plantloop_system[:data] << ["2nd Cooling Water Flowrate", component[2]]
              component = plantloop_data[component_index + 2]
              plantloop_system[:data] << ["2nd Cooling Rated COP", component[2]]
            end
          end
        elsif component_data[0].include?('Pump:')
          if one_pump
            plantloop_system[:data] << ["Pump Type", component_data[0].gsub(/Pump:/, "")]
            component = plantloop_data[component_index + 1]
            plantloop_system[:data] << ["Pump Head", component[2]]
            component = plantloop_data[component_index + 2]
            plantloop_system[:data] << ["Motor Efficiency", component[2]]
            one_pump = false
          else
            plantloop_system[:data] << ["2nd Pump Type", component_data[0].gsub(/Pump:/, "")]
            component = plantloop_data[component_index + 1]
            plantloop_system[:data] << ["2nd Pump Head", component[2]]
            component = plantloop_data[component_index + 2]
            plantloop_system[:data] << ["2nd Motor Efficiency", component[2]]
            one_pump = false
          end
        elsif component_data[0].include?('CoolingTower:SingleSpeed')
          plantloop_system[:data] << ["Cooling Equipment", component_data[0]]
          plantloop_system[:data] << ["Cooling Air Flowrate", component_data[2]]
          component = plantloop_data[component_index + 1]
          plantloop_system[:data] << ["Cooling Water Flowrate", component[2]]
        elsif component_data[0].include?('Boiler:HotWater')
          plantloop_system[:data] << ["Heating Equipment", component_data[0]]
          plantloop_system[:data] << ["Heating Capacity", component_data[2]]
          component = plantloop_data[component_index + 1]
          plantloop_system[:data] << ["Heating Water Flowrate", component[2]]
          component = plantloop_data[component_index + 2]
          plantloop_system[:data] << ["Boiler Efficiency", component[2]]
        elsif component_data[0].include?('WaterHeater:Mixed') and $ashpwh_flag #air source heat pump water heater
          component = plantloop_data[component_index - 1]
          plantloop_system[:data] << ["Heating Equipment", "ASHP Water Heater"]
          plantloop_system[:data] << ["Heating Capacity", component_data[2]]
          plantloop_system[:data] << ["Water Heater Efficiency", component[2]]
        elsif component_data[0].include?('WaterHeater:Mixed') # normal water heater
          plantloop_system[:data] << ["Heating Equipment", component_data[0]]
          plantloop_system[:data] << ["Heating Capacity", component_data[2]]
          component = plantloop_data[component_index + 1]
          plantloop_system[:data] << ["Water Heater Efficiency", component[2]]
        elsif component_data[0].class == Hash # if it reaches this item, break from this loop. End of the supply side components
          subheader = component_data[0]
          if subheader[:sub_header] == "demand"
            break
          end
        end
      end
    end
    @plantLoops_summary_table_section[:tables] = [plantloop_system]
    return @plantLoops_summary_table_section
  end

  def self.hvac_zoneEquip_detailed_section1(model, sqlFile, runner, name_only = false)

    zoneEq_data_table = {}
    zoneEq_data_table[:title] = ''
    zoneEq_data_table[:header] = ["Parameter", "Value"]
    zoneEq_data_table[:units] = ['', '']
    zoneEq_data_table[:data] = []

    # gather data for section
    @zoneEq_summary_table_section = {}
    @zoneEq_summary_table_section[:title] = 'Zone Equipment Summary'
    @zoneEq_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @zoneEq_summary_table_section
    end

    data_arrays = OsLib_Reporting.zone_equipment_detail_section(model, sqlFile, runner, name_only = false)
    #Zone equip description
    zone_eqp_lists = data_arrays[:tables] #array of hashes, each hash contains a zone's zone equipment
    bsbrd_water_flow_sum = 0
    bsbrd_water_flow_counter = 0
    bsbrd_electric_counter = 0
    bsbrd_electric_max_cap = []
    bsbrd_electric_max_eff = []
    ptac_heat_sum = 0
    ptac_cool_sum = 0
    ptac_heat_eff_sum = 0
    ptac_cool_cop_sum = 0
    ptac_max_heat_cap = []
    ptac_max_cool_cap = []
    ptax_max_heat_eff = []
    ptac_max_cop = []
    ptac_counter = 0
    zone_eqp_lists.each do |zone_eqp_list|
      #zone_eqp_list is a hash, each hash contains info of its own component (multiple zone equipment sometimes)
      zone_eqp = zone_eqp_list[:data]
      zone_eqp.each_with_index do |zone_eqp_data, index|
        # zone_eqp_data are individiual arrays containing parameters
        if zone_eqp_data[0] == "ZoneHVAC:Baseboard:Convective:Water"
          bsbrd_water_flow_sum += zone_eqp_data[2].to_f
          bsbrd_water_flow_counter += 1
        elsif zone_eqp_data[0] == "ZoneHVAC:Baseboard:Convective:Electric"
          bsbrd_electric_counter += 1
          #heat cap
          bsbrd_electric_max_cap << zone_eqp_data[2].delete(",").to_f
          #max eff
          eqp_data = zone_eqp[index + 1]
          bsbrd_electric_max_eff << eqp_data[2].delete(",").to_f
        elsif zone_eqp_data[0] == "ZoneHVAC:PackagedTerminalAirConditioner"
          ptac_counter += 1
          #heat cap
          eqp_data = zone_eqp[index + 1]
          ptac_heat_sum += eqp_data[2].delete(",").to_f
          ptac_max_heat_cap << eqp_data[2].delete(",").to_f

          #cooling cap
          eqp_data = zone_eqp[index + 2]
          ptac_cool_sum += eqp_data[2].delete(",").to_f
          ptac_max_cool_cap << eqp_data[2].delete(",").to_f

          #heat efficiency (electric)
          eqp_data = zone_eqp[index + 6]
          ptac_heat_eff_sum += eqp_data[2].to_f
          ptax_max_heat_eff << eqp_data[2].delete(",").to_f

          #cooling cop
          eqp_data = zone_eqp[index + 7]
          ptac_cool_cop_sum += eqp_data[2].to_f
          ptac_max_cop << eqp_data[2].delete(",").to_f
        end
      end #end of zone_eqp.each_with_index do |zone_eqp_data,index|
    end #end of zone_eqp_lists.each do |zone_eqp_list|
    #calculate max and avg terminal parameters (assuming single sized used)
    if ptac_counter > 0
      zoneEq_data_table[:data] << ["Type of PTAC", "DX Cooling & Electric Heating"]
      zoneEq_data_table[:data] << ["Number of Units", ptac_counter.to_i]
      zoneEq_data_table[:data] << ["PTAC Avg Heating Cap (W)", (ptac_heat_sum / ptac_counter).round.to_s]
      zoneEq_data_table[:data] << ["PTAC Avg Cooling Cap (W)", (ptac_cool_sum / ptac_counter).round.to_s]
      zoneEq_data_table[:data] << ["PTAC Max Heating Cap (W)", (ptac_max_heat_cap).max.round.to_s]
      zoneEq_data_table[:data] << ["PTAC Max Cooling Cap (W)", (ptac_max_cool_cap).max.round.to_s]
      zoneEq_data_table[:data] << ["PTAC Max Heating Eff", ptax_max_heat_eff.max.to_s]
      zoneEq_data_table[:data] << ["PTAC Max COP", ptac_max_cop.max]
    end
    if bsbrd_water_flow_counter > 0
      zoneEq_data_table[:data] << ["Baseboard Type", "Water Heating"]
      zoneEq_data_table[:data] << ["Number of Units", bsbrd_water_flow_counter]
      zoneEq_data_table[:data] << ["Avg Water Flowrate (m^3/s)", ((bsbrd_water_flow_sum / bsbrd_water_flow_counter).round(4))]
    end
    if bsbrd_electric_counter > 0
      zoneEq_data_table[:data] << ["Baseboard Type", "Electric Heating"]
      zoneEq_data_table[:data] << ["Number of Units", bsbrd_electric_counter]
      zoneEq_data_table[:data] << ["Max Capacity (W)", bsbrd_electric_max_cap.max.round.to_s]
      zoneEq_data_table[:data] << ["Max Efficiency (%)", bsbrd_electric_max_eff.max.round.to_s]
    end
    @zoneEq_summary_table_section[:tables] = [zoneEq_data_table]
    return @zoneEq_summary_table_section
  end
end
