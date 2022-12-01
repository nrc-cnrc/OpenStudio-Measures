require 'json'
#require "csv"
require_relative '../measure.rb'
#require 'fileutils'

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

  # Create eui loads
  def self.loads_summary_section(model, sqlFile, runner, name_only = false)
    is_ip_units = false
    # array to hold tables
    heating_cooling_loads_table = {}
    heating_cooling_loads_table[:title] = ''
    heating_cooling_loads_table[:header] = []
    heating_cooling_loads_table[:units] = ['', '']
    heating_cooling_loads_table[:data] = []

    # gather data for section
    @heating_cooling_loads_data_section = {}
    @heating_cooling_loads_data_section[:title] = "Hourly EUI for the Output Variables"
    @heating_cooling_loads_data_section[:tables] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @heating_cooling_loads_data_section
    end

    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      runner.registerInfo("env_pd #{env_pd}".green)
      env_type = sqlFile.environmentType(env_pd)
      puts " mmmm env_type #{env_type}".light_blue
      puts " mmmmm sql ::: #{sqlFile.availableReportingFrequencies(env_pd)}".green #Only Hourly and timestep
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
          break
        end
      end
    end
    reporting_frequency = "Hourly"
    variable_names = sqlFile.availableVariableNames(ann_env_pd, reporting_frequency)
    meters = model.getOutputMeters
    output_timeseries = {}
    output_timeseries1 = {}
    headers = []
    csv_array = []
    values = []
    allValues = []
    output_timeseries = {}
    cnt = 1
    cnt2 = cnt # set a counter to add the time series dates for one time only
    variable_names.each do |variable_name|
      puts "variable name : ".green + "#{variable_name}  ".light_blue
      source_units = 'J'
      target_units = 'kWh'
      keys = sqlFile.availableKeyValues(ann_env_pd, reporting_frequency, variable_name.to_s)
      keys.each do |key_value|
        timeseries = sqlFile.timeSeries(ann_env_pd, reporting_frequency, variable_name.to_s, key_value.to_s)
        if !timeseries.empty?
          timeseries = timeseries.get
          units = timeseries.units
          date_times = timeseries.dateTimes
          values[0] = date_times if cnt2 == 1 #Only add the dates one time
          if variable_name.include? ":Facility"
            allValues = []
            for i in 0..(timeseries.values.size - 1)
              value = OpenStudio.convert(timeseries.values[i], source_units, target_units).get
              allValues << value
            end
            headers << "#{key_value.to_s}:#{variable_name.to_s}[#{target_units}]"
            values[cnt] = allValues
          else
            headers << "#{key_value.to_s}:#{variable_name.to_s}[#{units}]"
            values[cnt] = timeseries.values
          end
          output_timeseries[headers[-1]] = timeseries
        else
          runner.registerWarning("Timeseries for #{key_value} #{variable_name} is empty.")
        end

        # Save the time serious data to csv files
        csv_header = ['Time', "#{key_value}_#{variable_name}"]
        cnt = cnt + 1
      end
    end

    buildingType = model.getBuilding.standardsBuildingType.get.to_s
    weatherFile = model.getWeatherFile

    city = weatherFile.city.split('.')[0]
    if city.include? '-'
      city = city.split('-')[0]
    end
    if city.include? ' '
      city = city.split(' ')[0]
    end
    if city.include? '='
      city = city.split('=')[0]
    end
    final_arr = []
    for i in 0..values.length - 1
      for j in 0..values[i].length - 1
        csv_array << values[i][j]
      end
      final_arr << csv_array
      csv_array = []
    end

    new_arr = final_arr.transpose
    headers.unshift('Date') # leave first cell in headers empty

    heating_cooling_loads_table[:header] = headers

    File.open("./report_#{city}_#{buildingType}_baseLoad.csv", 'wb') do |file|
      file.puts headers.join(',')
      new_arr.each do |elem|
        heating_cooling_loads_table[:data] << elem
        file.puts elem.join(',')
      end
    end

    @heating_cooling_loads_data_section[:tables] = [heating_cooling_loads_table]
    return @heating_cooling_loads_data_section
  end

end
