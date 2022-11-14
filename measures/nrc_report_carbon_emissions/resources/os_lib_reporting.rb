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

  def self.findProvince(loc)
    if loc == 'Alberta'
      province = 'AB'
    elsif loc == 'British Columbia'
      province = 'BC'
    elsif loc == 'Manitoba'
      province = 'MB'
    elsif loc == 'New Brunswick'
      province = 'NB'
    elsif loc == 'Newfoundland and Labrador'
      province = 'NL'
    elsif loc == 'Northwest Territories'
      province = 'NT'
    elsif loc == 'Nova Scotia'
      province = 'NS'
    elsif loc == 'Nunavut'
      province = 'NU'
    elsif loc == 'Ontario'
      province = 'ON'
    elsif loc == 'Prince Edward Island'
      province = 'PE'
    elsif loc == 'Quebec'
      province = 'QC'
    elsif loc == 'Saskatchewan'
      province = 'SK'
    elsif loc == 'Yukon'
      province = 'YT'
    end
    return province
  end

  # Copied from https://github.com/NREL/openstudio-standards/blob/aca8b959ad59216d5d7ddc56c93dfc3d928ec30e/lib/openstudio-standards/standards/necb/common/btap_data.rb#L1649
  def self.get_utility_ghg_kg_per_gj(province:, fuel_type:)
    ghg_data = [
      # Obtained from Portfolio Manager https://portfoliomanager.energystar.gov/pdf/reference/Emissions.pdf 10/10/2020
      { "province": 'AB', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 53.24, "CO2eq Emissions (g/m3)": 1939.0 },
      { "province": 'BC', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 53.19, "CO2eq Emissions (g/m3)": 1937.0 },
      { "province": 'MB', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.09, "CO2eq Emissions (g/m3)": 1897.0 },
      { "province": 'NB', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'NL', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'NT', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'NS', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'NU', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'ON', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.14, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'PE', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },
      { "province": 'QC', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.12, "CO2eq Emissions (g/m3)": 1898.0 },
      { "province": 'SK', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 50.53, "CO2eq Emissions (g/m3)": 1840.0 },
      { "province": 'YT', "fuel_type": 'Gas', "CO2eq Emissions (kg/MBtu)": 52.50, "CO2eq Emissions (g/m3)": 1912.0 },

      { "province": 'AB', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'BC', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'MB', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'NB', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'NL', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'NT', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'NS', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'NU', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'ON', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'PE', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'QC', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'SK', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },
      { "province": 'YT', "fuel_type": 'FuelOilNo2', "CO2eq Emissions (kg/MBtu)": 75.13, "CO2eq Emissions (g/m3)": 2763.0 },

      { "province": 'AB', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'BC', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'MB', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'NB', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'NL', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'NT', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'NS', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'NU', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'ON', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'PE', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'QC', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'SK', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },
      { "province": 'YT', "fuel_type": 'Propane', "CO2eq Emissions (kg/MBtu)": 64.25, "CO2eq Emissions (g/m3)": 1548.00 },

      { "province": 'AB', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 231.54, "CO2eq Emissions (g/m3)": 790.0 },
      { "province": 'BC', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 2.99, "CO2eq Emissions (g/m3)": 10.2 },
      { "province": 'MB', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 0.56, "CO2eq Emissions (g/m3)": 1.9 },
      { "province": 'NB', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 76.20, "CO2eq Emissions (g/m3)": 260.0 },
      { "province": 'NL', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 11.72, "CO2eq Emissions (g/m3)": 40.0 },
      { "province": 'NT', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 46.89, "CO2eq Emissions (g/m3)": 160.0 },
      { "province": 'NS', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 213.95, "CO2eq Emissions (g/m3)": 730.0 },
      { "province": 'NU', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 222.74, "CO2eq Emissions (g/m3)": 760.0 },
      { "province": 'ON', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 5.86, "CO2eq Emissions (g/m3)": 20.0 },
      { "province": 'PE', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 76.20, "CO2eq Emissions (g/m3)": 260.0 },
      { "province": 'QC', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 0.41, "CO2eq Emissions (g/m3)": 1.4 },
      { "province": 'SK', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 211.04, "CO2eq Emissions (g/m3)": 720.0 },
      { "province": 'YT', "fuel_type": 'Electricity', "CO2eq Emissions (kg/MBtu)": 16.41, "CO2eq Emissions (g/m3)": 140.0 }
    ]
    mbtu_to_gj = 1.05505585
    factor = ghg_data.detect { |item| (item[:province] == province) && (item[:fuel_type] == fuel_type) }
    raise "could not find ghg factor for province name #{province} and fuel_type #{fuel_type}" if factor.nil?

    return factor[:"CO2eq Emissions (kg/MBtu)"] / mbtu_to_gj
  end

  ####### This section calculates the GHG based on NIR reports
  def self.ghg_NIR_summary_section(model, sqlFile, runner, name_only = false)
    nir_emmision_summary_data_table = {}
    nir_emmision_summary_data_table[:title] = ''
    nir_emmision_summary_data_table[:header] = ["Year", "Electricity NIR EF", "Electricity Emissions", "Natural Gas EF", "Natural Gas Emissions", "Annual GHG Emissions"]
    nir_emmision_summary_data_table[:units] = ['', 'g CO2eq/kWh', 'tCO2eq', 'kg CO2eq/GJ', 'tCO2eq', 'tCO2eq']
    nir_emmision_summary_data_table[:data] = []

    # gather data for section
    @nir_emission_summary_table_section = {}
    @nir_emission_summary_table_section[:title] = 'Annual GHG Emissions Based on NIR Report Emission Factors'
    @nir_emission_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @nir_emission_summary_table_section
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
        if ((fuel_type.include? "Electricity") || (fuel_type.include? "Natural Gas"))
          query_fuel = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='AnnualBuildingUtilityPerformanceSummary' and TableName='End Uses' and RowName= '#{end_use}' and ColumnName= '#{fuel_type}'"
          results_fuel = sqlFile.execAndReturnFirstDouble(query_fuel).get
          total_end_use += results_fuel
          array_endUse << results_fuel
        end
      end
      array_endUse_all.push(array_endUse)
      #nir_emmision_summary_data_table[:data] << array_endUse
      array_endUse = []
      counter += 1
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

    #Calculate the ghg emissions
    total_emissions_array = []
    total_emissions_sub_array = []
    $electricity_EF.each do |year, electricity_EF|
      # Natural gas ghgEmission
      gas_consumption_gj = @totals[2]
      naturalGas_emissions = $naturalGas_EF * gas_consumption_gj / 1000 # convert from kgCO2eq to tCO2eq
      # Electricity ghgEmission
      electricity_consumption_kWh = OpenStudio::convert(@totals[1], "GJ", "kWh").get
      electricity_emissions = electricity_EF * electricity_consumption_kWh / 1000000 # convert from g CO2eq to tCO2eq
      total_emissions = electricity_emissions + naturalGas_emissions
      total_emissions_sub_array << [year, electricity_EF, electricity_emissions.signif(3), $naturalGas_EF, naturalGas_emissions.signif(3), total_emissions.signif(3)]
      total_emissions_array << total_emissions_sub_array
      total_emissions_sub_array = []
      nir_emmision_summary_data_table[:data] << [year, electricity_EF, electricity_emissions.signif(3), $naturalGas_EF, naturalGas_emissions.signif(3), total_emissions.signif(3)]
    end

    total_emissions_array = total_emissions_array.flatten(1)


    #Calculate Sum of Columns
    array_emissions_all_transpose = []
    array_emissions_all_transpose = total_emissions_array.transpose
    total_emissions = []
    array_emissions_all_transpose.each do |row|
      sum = 0
      for i in row do
        next if i.class == String
        sum += i
      end
      total_emissions << sum.round(2)
    end
    total_emissions[0] = 'Total Emissions'
    total_emissions[1] = ''
    total_emissions[3] = ''

    total_emissions_array << total_emissions
    nir_emmision_summary_data_table[:data] << total_emissions
      # Create a csv file
    # Create if does not exist. Different logic from other testing as there are multiple test scripts writing
    # to this folder so it cannot be deleted.
    @test_dir = NRCReportingMeasureTestHelper.appendOutputFolder("EmissionReport")
    if !Dir.exists?(@test_dir)
      puts "Creating output folder: #{@test_dir}"
      Dir.mkdir(@test_dir)
    end

    testing_report = "#{@test_dir}/NIR_ghgEmissions.csv"
    File.open(testing_report, 'a') do |file|
      # Add the header only once
      if file.tell() == 0
        file.puts "Year, Electricity NIR EF [g CO2eq/kWh], Electricity Emissions [tCO2eq], Natural Gas EF [kg CO2eq/GJ], Natural Gas Emissions [tCO2eq], Annual GHG Emissions [tCO2eq]"
      end
      total_emissions_array.each do |elem|
        file.puts elem.join(',')
      end
    end

    # don't create empty table
    @nir_emission_summary_table_section[:tables] = [nir_emmision_summary_data_table] # only one table for this section
    return @nir_emission_summary_table_section
  end

  ####### This section calculates the GHG based on Energy Star Portfolio Manager factors
  def self.ghg_energyStar_summary_section(model, sqlFile, runner, name_only = false)

    energyStar_summary_data_table = {}
    energyStar_summary_data_table[:title] = ''
    energyStar_summary_data_table[:header] = ["End Use", "Electricity", "Natural Gas", "FuelOilNo2", "Propane", "Annual GHG Emissions"]
    energyStar_summary_data_table[:units] = ['', 'GJ', 'GJ', 'GJ', 'GJ', 'tCO2eq']
    energyStar_summary_data_table[:data] = []

    # gather data for section
    @energyStar_summary_table_section = {}
    @energyStar_summary_table_section[:title] = 'Annual GHG Emissions Based on Energy Star Portfolio Manager Emission Factors'
    @energyStar_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @energyStar_summary_table_section
    end
    array_endUse_all = []
    array_endUse = []
    # loop through fuels for consumption tables
    counter = 0

    ####### This loop include just 4 Fuel types ("Electricity", "Natural Gas", "Fuel Oil No 2","Propane") that have EFs from Portfolio Manager
    OpenStudio::EndUseCategoryType.getValues.each do |end_use|
      # get end uses
      end_use = OpenStudio::EndUseCategoryType.new(end_use).valueDescription
      array_endUse << end_use
      # loop through fuels
      total_end_use = 0.0
      fuel_type_names.each do |fuel_type|
        if ((fuel_type.include? "Electricity") || (fuel_type.include? "Natural Gas") || (fuel_type.include? "Fuel Oil No 2") || (fuel_type.include? "Propane"))
          query_fuel = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='AnnualBuildingUtilityPerformanceSummary' and TableName='End Uses' and RowName= '#{end_use}' and ColumnName= '#{fuel_type}'"
          results_fuel = sqlFile.execAndReturnFirstDouble(query_fuel).get
          total_end_use += results_fuel
          array_endUse << results_fuel
        end
      end
      array_endUse_all.push(array_endUse)
      energyStar_summary_data_table[:data] << array_endUse
      array_endUse = []
      counter += 1
    end

    #Calculate the ghg emissions
    array_endUse_all.each do |array|

      # Electricity ghgEmission
      electricity_consumption_gj = array[1]
      province = findProvince($location)
      @energyStar_electricity_emission_factor = get_utility_ghg_kg_per_gj(province: province, fuel_type: "Electricity")
      electricity_emissions = @energyStar_electricity_emission_factor * electricity_consumption_gj / 1000 # convert from kg CO2eq to tCO2eq

      # Natural gas ghgEmission
      gas_consumption_gj = array[2]
      @gas_emission_factor = get_utility_ghg_kg_per_gj(province: province, fuel_type: "Gas")
      naturalGas_emissions = @gas_emission_factor * gas_consumption_gj / 1000 # convert from kgCO2eq to tCO2eq

      # Fuel Oil No 2 ghgEmission
      fuelOilNo2_consumption_gj = array[3]
      @fuelOilNo2_emission_factor = get_utility_ghg_kg_per_gj(province: province, fuel_type: "FuelOilNo2")
      fuelOilNo2_emissions = @fuelOilNo2_emission_factor * fuelOilNo2_consumption_gj / 1000 # convert from kgCO2eq to tCO2eq

      # Propane ghgEmission
      propane_consumption_gj = array[4]
      @propane_emission_factor = get_utility_ghg_kg_per_gj(province: province, fuel_type: "Propane")
      propane_emissions = @propane_emission_factor * propane_consumption_gj / 1000 # convert from kg CO2eq to tCO2eq

      total_emissions = electricity_emissions + naturalGas_emissions + fuelOilNo2_emissions + propane_emissions
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
    energyStar_summary_data_table[:data] << @totals
    # Create a csv file
    testing_report = "#{@test_dir}/EnergyStar_ghgEmissions.csv"

    column_header = ["Location, Standard building type,  Electricity_EndUse (GJ),EnergyStar_electricity_emission_factor (kg CO2eq/GJ), NaturalGas_EndUse (GJ), NaturalGas_EF (kg CO2eq/GJ), total_emissions (tCO2eq)}"]
    File.open(testing_report, 'a') do |file|
      # Add the header only once
      if file.tell() == 0
        file.puts "Location, Standard building type,  Electricity_EndUse (GJ),EnergyStar_electricity_emission_factor (kg CO2eq/GJ), NaturalGas_EndUse (GJ), NaturalGas_EF (kg CO2eq/GJ), total_emissions (tCO2eq)}"
      end
      file.puts "#{model.getWeatherFile.city} , #{model.getBuilding.standardsBuildingType.get.to_s}, #{@totals[1]}, #{@energyStar_electricity_emission_factor} , #{@totals[2]} , #{@gas_emission_factor}, #{@totals[5]} "
    end

    # don't create empty table
    @energyStar_summary_table_section[:tables] = [energyStar_summary_data_table] # only one table for this section
    return @energyStar_summary_table_section
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
    model_summary_data_table[:data] << ["Standard building type", model.getBuilding.standardsBuildingType.get.to_s]
    model_summary_data_table[:data] << ["Location", $location]

    # don't create empty table
    @model_summary_table_section[:tables] = [model_summary_data_table] # only one table for this section

    return @model_summary_table_section
  end

  # create model summary section
  def self.emissionFactors_summary_section(model, sqlFile, runner, name_only = false)
    emissionFactors_summary_data_table = {}
    emissionFactors_summary_data_table[:title] = ''
    emissionFactors_summary_data_table[:header] = ["Parameter", "Value"]
    emissionFactors_summary_data_table[:units] = ['', '']
    emissionFactors_summary_data_table[:data] = []

    # gather data for section
    @emissionFactors_summary_table_section = {}
    @emissionFactors_summary_table_section[:title] = 'Energy Star Emission Factors'
    @emissionFactors_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @emissionFactors_summary_table_section
    end

    emissionFactors_summary_data_table[:data] << ["ECCC Natural Gas Emission Factor (kg CO2eq/GJ)", $naturalGas_EF.round(2)]
    emissionFactors_summary_data_table[:data] << ["Energy Star Electricity Emission Factor (kg CO2eq/GJ)", @energyStar_electricity_emission_factor.round(2)]
    emissionFactors_summary_data_table[:data] << ["Energy Star Natural Gas Emission Factor (kg CO2eq/GJ)", @gas_emission_factor.round(2)]
    emissionFactors_summary_data_table[:data] << ["Energy Star FuelOilNo2 Emission Factor (kg CO2eq/GJ)", @fuelOilNo2_emission_factor.round(2)]
    emissionFactors_summary_data_table[:data] << ["Energy Star Propane Emission Factor (kg CO2eq/GJ)", @propane_emission_factor.round(2)]

    # don't create empty table
    @emissionFactors_summary_table_section[:tables] = [emissionFactors_summary_data_table] # only one table for this section

    return @emissionFactors_summary_table_section
  end

  # create model summary section
  def self.nir_emissionFactors_summary_section(model, sqlFile, runner, name_only = false)
    nir_emissionFactors_summary_data_table = {}
    nir_emissionFactors_summary_data_table[:title] = ''
    nir_emissionFactors_summary_data_table[:header] = ["NIR Report Year : #{$nir_report_year}", "NIR Emission factor (g CO2eq/kWh)"]
    nir_emissionFactors_summary_data_table[:units] = ['', '']
    nir_emissionFactors_summary_data_table[:data] = []

    # gather data for section
    @nir_emissionFactors_summary_table_section = {}
    @nir_emissionFactors_summary_table_section[:title] = 'NIR Report Emission Factors'
    @nir_emissionFactors_summary_table_section[:data] = []

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @nir_emissionFactors_summary_table_section
    end

    $electricity_EF.each do |key, value|
      nir_emissionFactors_summary_data_table[:data] << [key, value]
    end

    # don't create empty table
    @nir_emissionFactors_summary_table_section[:tables] = [nir_emissionFactors_summary_data_table] # only one table for this section

    return @nir_emissionFactors_summary_table_section
  end

end
