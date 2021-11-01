require 'json'
require "csv"
require_relative '../measure.rb'
require 'fileutils'

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
      next if fuel_name == "Water"
      fuel_types << fuel_name
    end
    return fuel_types
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

    model_summary_data_table[:data] << ["Location", $location]
    model_summary_data_table[:data] << ["Year", $year]
    model_summary_data_table[:data] << ["Electricity Emission Factor", $electricity_EF]
    model_summary_data_table[:data] << ["Natural Gas Emission Factor", $naturalGas_EF]
    model_summary_data_table[:data] << ["Standard building type", model.getBuilding.standardsBuildingType.get.to_s]

    # don't create empty table
    @model_summary_table_section[:tables] = [model_summary_data_table] # only one table for this section

    return @model_summary_table_section
  end

  ####### This section is copied from OpenStudio Results measure, updated to create a table instead of a chart
  def self.endUse_summary_section(model, sqlFile, runner, name_only = false)
    endUse_summary_data_table = {}
    endUse_summary_data_table[:title] = ''
    endUse_summary_data_table[:header] = ["End Use", "Electricity", "Natural Gas", "Additional Fuel", "District Cooling", "District Heating", "Annual GHG Emissions"]
    endUse_summary_data_table[:units] = ['', 'GJ', 'GJ', 'GJ', 'GJ', 'GJ', 'tCO2eq']
    endUse_summary_data_table[:data] = []

    # gather data for section
    @endUse_summary_table_section = {}
    @endUse_summary_table_section[:title] = 'Annual End Use Summary and GHG Emissions'
    @endUse_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @endUse_summary_table_section
    end
    array_endUse_all = []
    array_endUse = []
    # loop through fuels for consumption tables
    counter = 0

    ####### This loop is copied from OpenStudio Results measure, updated to create a table instead of a chart
    OpenStudio::EndUseCategoryType.getValues.each do |end_use|
      # get end uses
      end_use = OpenStudio::EndUseCategoryType.new(end_use).valueDescription
      array_endUse << end_use
      # loop through fuels
      total_end_use = 0.0
      fuel_type_names.each do |fuel_type|
        query_fuel = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='AnnualBuildingUtilityPerformanceSummary' and TableName='End Uses' and RowName= '#{end_use}' and ColumnName= '#{fuel_type}'"
        results_fuel = sqlFile.execAndReturnFirstDouble(query_fuel).get
        total_end_use += results_fuel
        array_endUse << results_fuel
      end
      array_endUse_all.push(array_endUse)
      endUse_summary_data_table[:data] << array_endUse
      array_endUse = []
      counter += 1
    end

    #Calculate the ghg emissions
    array_endUse_all.each do |array|
      # Natyral gas ghgEmission
      gas_emissions_mj = OpenStudio::convert(array[2], "GJ", "MJ").get
      naturalGas_emissions = $naturalGas_EF * gas_emissions_mj / 1000000 # convert from gCO2eq to tCO2eq
      #  electricity ghgEmission
      electricity_emissions_kWh = OpenStudio::convert(array[1], "GJ", "kWh").get
      electricity_emissions = $electricity_EF * electricity_emissions_kWh / 1000000 # convert from g CO2eq to tCO2eq
      total_emissions = electricity_emissions + naturalGas_emissions
      array << total_emissions.round(2)
    end

    #Calculate Sum of Columns
    array_endUse_all_transpose = []
    array_endUse_all_transpose = array_endUse_all.transpose
    @totals = []
    array_endUse_all_transpose.each do |row|
      sum = 0
      for i in row do
        next if i.class == String
        sum += i
      end
      @totals << sum.round(2)
	  $co_total = sum.round(2) # The last value here will be the correct one.
    end
    @totals[0] = 'Total'
    endUse_summary_data_table[:data] << @totals
    # Create a csv file
    @test_dir = "#{File.dirname(__FILE__)}/EmissionReport"
    # Create if does not exist. Different logic from outher testing as there are multiple test scripts writing
    # to this folder so it cannot be deleted.
    if !Dir.exists?(@test_dir)
      puts "Creating output folder: #{@test_dir}"
      Dir.mkdir(@test_dir)
    end
    testing_report = "#{@test_dir}/ghgEmissions.csv"

    File.open(testing_report, 'a') do |file|
      file.puts "Location, Standard building type,  Electricity_EndUse (GJ),Elec_EF (gCO2eq/kWh), NaturalGas_EndUse (GJ), NaturalGas_EF (gCO2eq/MJ), total_emissions (tCO2eq)}"
      file.puts "#{model.getWeatherFile.city} , #{model.getBuilding.standardsBuildingType.get.to_s}, #{@totals[1]}, #{$electricity_EF} , #{@totals[2]} , #{$naturalGas_EF}, #{@totals[6]} "
    end

    # don't create empty table
    @endUse_summary_table_section[:tables] = [endUse_summary_data_table] # only one table for this section
    return @endUse_summary_table_section
  end

end
