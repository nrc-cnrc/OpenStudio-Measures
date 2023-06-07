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

  # cleanup - prep html and close sql
  def self.cleanup(html_in_path)
    return html_out_path
  end

  # clean up unknown strings used for runner.registerValue names
  def self.reg_val_string_prep(string)
    # replace non alpha-numberic characters with an underscore
    string = string.gsub(/[^0-9a-z]/i, '_')
    # snake case string
    string = OpenStudio.toUnderscoreCase(string)
    return string
  end

  # Copied from https://stackoverflow.com/questions/7749568/
  def self.standard_deviation(arr)
    mean = arr.inject(:+) / arr.length.to_f
    var_sum = arr.map { |n| (n - mean) ** 2 }.inject(:+).to_f
    sample_variance = var_sum / (arr.length - 1)
    Math.sqrt(sample_variance)
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
    numSetPointManagers = model.getSetpointManagers.size + 1
    model_summary_data_table[:data] << ["Location", model.getWeatherFile.city]
    model_summary_data_table[:data] << ["Standard building type", model.getBuilding.standardsBuildingType]
    model_summary_data_table[:data] << ["Number of Set point Managers", numSetPointManagers]

    if model_summary_data_table[:data].size > 0
      @model_summary_table_section[:tables] = [model_summary_data_table] # only one table for this section
    else
      @model_summary_table_section[:tables] = []
    end

    return @model_summary_table_section
  end

  # Create hourly temperatures table at setpoint manager nodes
  def self.temperature_detailed_section(model, sqlFile, runner, name_only = false)
    is_ip_units = false
    # array to hold tables
    temp_diff_detail_tables = []
    # gather data for section
    @temp_diff_data_section = {}
    @temp_diff_data_section[:title] = "Hourly Temperatures at Setpoint Manager Nodes"
    @temp_diff_data_section[:tables] = temp_diff_detail_tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @temp_diff_data_section
    end

    reporting_frequency = $timeStep.to_s
    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      runner.registerInfo("env_pd #{env_pd}".green)
      env_type = sqlFile.environmentType(env_pd)
      runner.registerInfo("env_type #{env_type}".light_blue)
      runner.registerInfo("sql ::: #{sqlFile.availableReportingFrequencies(env_pd)}".green)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
          break
        end
      end
    end

    variable_names = sqlFile.availableVariableNames(ann_env_pd, reporting_frequency)

    # Create an array with all the setpoint managers nodes
    @detail_arr = []
    node_names = []
    total_arr = []
    setPoints = model.getSetpointManagers
    runner.registerInfo("Setpoints object count: #{setPoints.size}".red)
    setPoints.each do |setPoint|
      total_arr << ["#{setPoint.setpointNode.get.name}", "#{setPoint.name}"]
      node_name = "#{setPoint.setpointNode.get.name}"
      node_names << node_name
    end

    node_names.each do |key_value|
      output_data_air_loops = {}
      output_data_air_loops[:title] = key_value # TODO: - confirm first that it has name
      output_data_air_loops[:header] = ['Time', 'System Node Setpoint Temperature', 'System Node Temperature', 'Temperature Difference']
      output_data_air_loops[:units] = []
      output_data_air_loops[:data] = []
      headers = []
      csv_array = []
      output_timeseries = {}
      variable_names.each do |variable_name|
        timeseries = sqlFile.timeSeries(ann_env_pd, reporting_frequency, variable_name.to_s, key_value.to_s)

        if !timeseries.empty?
          timeseries = timeseries.get
          units = timeseries.units
          headers << "#{key_value.to_s}:#{variable_name.to_s}[#{units}]"
          output_timeseries[headers[-1]] = timeseries
        else
          runner.registerWarning("Timeseries for #{key_value} #{variable_name} is empty.")
        end
      end

      final_array = []
      date_times = output_timeseries[output_timeseries.keys[0]].dateTimes
      values = {}
      for key in output_timeseries.keys
        key_index = headers.find_index(key)
        values[key_index] = output_timeseries[key].values
      end

      num_times = date_times.size - 1
      for i in 0..num_times
        row = []

        for key in headers
          key_index = headers.find_index(key)
          puts "#{key}: #{values[key_index][i]}".light_blue + " & Next:".green + " #{values[key_index][i + 1]}".light_blue if i == 0

          value = values[key_index][i].round(2)
          if key_index == 0
            row << date_times[i].to_s
          end
          row << value
        end
        final_array << row
      end
      # Calculate Diff between actual and setpoint temperature
      diff = []
      final_array.each do |sub_array|
        diff << sub_array[2] - sub_array[1] # create a col of temperature diff
        sub_array << (sub_array[2] - sub_array[1]).round(2)
      end

      final_array.each do |row|
        output_data_air_loops[:data] << row
      end

      max_tempDiff = diff.max
      min_tempDiff = diff.min
      mean = diff.inject(&:+).to_f / diff.size
      std_dev = standard_deviation(diff)

      arr = []
      total_arr.each do |row|
        if row[0].include? key_value
          arr = [row[0], row[1], max_tempDiff.round(2), min_tempDiff.round(2), mean.round(2), std_dev.round(2)]
          @detail_arr << arr
        end
      end
      # populate tables for section
      temp_diff_detail_tables << output_data_air_loops

      if $detail == "Yes"
        # Save the time serious data to csv files
        csv_header = ['Time', 'System Node Setpoint Temperature', 'System Node Temperature', 'Temperature Difference']
        final_array.unshift(csv_header) # add header to the csv files
        #csv_array = csv_array.transpose
        File.open("./report__#{key_value.delete(' ')}_#{reporting_frequency.delete(' ')}.csv", 'wb') do |file|
          final_array.each do |elem|
            file.puts elem.join(',')
          end
        end
      end
    end

    return @temp_diff_data_section
  end

  def self.temp_diff_summary_section(model, sqlFile, runner, name_only = false)
    temp_diff_summary_data_table = {}
    temp_diff_summary_data_table[:title] = ''
    temp_diff_summary_data_table[:header] = ["Node", "Setpoint Manager", "Maximum temperature Diff", "Minimum temperature Diff", "Mean", "Standard Devtiation",]
    temp_diff_summary_data_table[:units] = ['', '']
    temp_diff_summary_data_table[:data] = []

    # gather data for section
    @hvac_summary_table_section = {}
    @hvac_summary_table_section[:title] = 'Temperature Deviations Summary'
    @hvac_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @hvac_summary_table_section
    end

    @detail_arr.each do |row|
      temp_diff_summary_data_table[:data] << row
    end

    # don't create empty table
    if temp_diff_summary_data_table[:data].size > 0
      @hvac_summary_table_section[:tables] = [temp_diff_summary_data_table] # only one table for this section
    else
      @hvac_summary_table_section[:tables] = []
    end
    return @hvac_summary_table_section
  end

end
