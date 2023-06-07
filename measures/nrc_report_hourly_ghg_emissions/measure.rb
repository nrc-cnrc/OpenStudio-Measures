# Start the measure
require 'openstudio-standards'
require_relative 'resources/NRCReportingMeasureHelper'
require "#{File.dirname(__FILE__)}/resources/os_lib_helper_methods"
require 'erb'

# start the measure
class NrcReportHourlyGhgEmissions < OpenStudio::Measure::ReportingMeasure

  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCReportingMeasureHelper)

  # Human readable name
  def name
    return "NrcReportHourlyGhgEmissions"
  end

  # Human readable description
  def description
    return "This reporting measure calculates the hourly GHG emissions."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "The measure only calculates the hourly GHG emissions related to electrical use. Only the hourly emission factors for electricity
            in Ottawa, Toronto, and Windsor for 3 years ( 2016, 2017 and 2018) are available.
            One flat yearly natural gas emission factor of 0.18 kgCO2e/kWh is used, or it could be updated by the user.
            The stat weather files were obtained from 'https://climate.onebuilding.org/WMO_Region_4_North_and_Central_America/CAN_Canada/index.html'.
            In order to use this measure, the 'nrc_set_hourly_weather_file' measure has to be used first to set the hourly weather files.
            The units of emission factors in the 'hourlyEmissionsFactors.csv' file are in 'gCO2eq/kWh', the units of EUI consumption in the output file '*_hourly_eui_baseLoad.csv'
            are all in 'kWh', and the units of emissions in the output file '*_hourly_emissions_baseLoad.csv' are all in 'tCO2eq'."
  end

  #Use the constructor to set global variables
  def initialize()
    super()

    #Set to true if you want to package the arguments as json.
    @use_json_package = false

    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    #@use_string_double = true
    @use_string_double = false

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "ng_emissionFactor",
        "type" => "Double",
        "display_name" => "Natural gas emission factor (kg CO2e/kWh)",
        "default_value" => 0.18,
        "max_double_value" => 20.0,
        "is_required" => true
      }
    ]
  end

  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # Warning: Do not change the name of this method to be snake_case. The method must be lowerCamelCase.
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return result
    end

    # Get the last model and sql file.
    model = runner.lastOpenStudioModel
    if model.empty?
      puts 'Cannot find last model.'.red
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    meters = model.getOutputMeters
    #reporting initial condition of model
    runner.registerInitialCondition("The model started with #{meters.size} meter objects.")

    # List outputs required.
    result << OpenStudio::IdfObject.load('Output:Meter,NaturalGas:Facility,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Electricity:Facility,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,ExteriorLights:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,InteriorLights:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,InteriorEquipment:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,ExteriorEquipment:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Fans:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Pumps:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Heating:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Cooling:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,HeatRejection:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Humidifer:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,HeatRecovery:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,WaterSystems:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Cogeneration:Electricity,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,InteriorEquipment:NaturalGas,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,ExteriorEquipment:NaturalGas,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Heating:NaturalGas,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Cooling:NaturalGas,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,WaterSystems:NaturalGas,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Cogeneration:NaturalGas,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,DistrictHeating:Facility,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,DistrictCooling:Facility,Hourly;').get

    return result
  end

  # define the outputs that the measure will create
  def outputs
    result = OpenStudio::Measure::OSOutputVector.new
    return result
  end

  # Define what happens when the measure is run
  def run(runner, user_arguments)
    # Runs parent run method.
    super(runner, user_arguments)

    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

    #puts JSON.pretty_generate(arguments)
    arguments = validate_and_get_arguments_in_hash(runner, user_arguments)
    return false if false == arguments
    weatherFile = model.getWeatherFile.url.get.split('/').last
    puts "Weather file ".green + "#{weatherFile}".light_blue
    ng_ef = arguments['ng_emissionFactor']

    if weatherFile.include? "_16."
      year = 2016
    elsif weatherFile.include? "_17."
      year = 2017
    elsif weatherFile.include? "_18."
      year = 2018
    end

    location = ""
    if weatherFile.include? "Ottawa"
      location = "Ottawa"
    elsif weatherFile.include? "Toronto"
      location = "Toronto"
    elsif weatherFile.include? "Windsor"
      location = "Southwest"
    else
      puts "Error: Location must be 'Ottawa' , 'Toronto' or 'Windsor'".red
    end

    puts "In measure :  WeatherFile ".green + " #{weatherFile}".light_blue
    puts "In measure : model.getRunPeriod ".green + " #{model.getRunPeriod}".light_blue
    puts "In measure : model.getYearDescription ".green + "#{model.getYearDescription}".light_blue

    meters = model.getOutputMeters
    # reporting initial condition of model
    puts "The model started with ".green + "#{meters.size}".light_blue + " meter objects.".green

    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      runner.registerInfo("env_pd #{env_pd}".green)
      env_type = sqlFile.environmentType(env_pd)
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
          puts " timeseries.firstReportDateTime #{timeseries.firstReportDateTime}"
          #variable_name.include? ":Facility"
          allValues = []
          for i in 0..(timeseries.values.size - 1)
            value = OpenStudio.convert(timeseries.values[i], source_units, target_units).get
            allValues << value
          end
          headers << "#{key_value.to_s}:#{variable_name.to_s}[#{target_units}]"
          values[cnt] = allValues

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

    testing_report = "./#{location}_#{buildingType}_#{year}_hourly_eui_baseLoad.csv"
    puts ">> testing_report #{testing_report}"
    File.open(testing_report, 'a') do |file|
      file.puts headers.join(',')
      new_arr.each do |elem|
        file.puts elem.join(',')
      end
    end

    # Create a class variable array to be used in other sections
    hourly_eui = []
    hourly_eui << headers
    new_arr.each do |row|
      hourly_eui << row
    end

    # Get the electricity EF from the CSV file 'hourlyEmissionsFactors.csv'
    ef_path = File.expand_path('../resources/hourlyEmissionsFactors.csv', __FILE__)

    emissionFactorsFile = File.read(ef_path)

    emissionFactors = CSV.parse(emissionFactorsFile, :headers => true).map(&:to_h)

    # Create an array for the hourly emission factors for location and year selected by the user
    arr_ef = []
    emissionFactors.each do |row|
      if row["Timestep"].include? year.to_s
        row.each do |key, value|
          if key == location
            arr_ef << value
          end
        end
      end
    end

    arr_ef.unshift(location)
    index_ng = []
    index_elec = []
    headers = []
    # Find the indices for the columns of electricity, and columns for natural gas
    hourly_eui[0].each_with_index do |elem, index|
      if elem.include? "kWh"
        header = elem.gsub("[kWh]", "")
      end

      if elem.include? "Electricity"
        headers << header
        index_elec << index
      elsif elem.include? "NaturalGas"
        headers << header
        index_ng << index
      end
    end

    emission_arr_total = []
    hourly_eui.each_with_index do |row, index1|
      emission_arr = []
      next if index1 == 0
      row.each_with_index do |elem, index|
        if index_elec.include?(index)
          electricity_emissions = (elem * arr_ef[index1].to_f).to_f / 1000000 # convert from gCO2eq to tCO2eq
          emission_arr.push(electricity_emissions)
        elsif index_ng.include?(index)
          naturalGas_emissions = (ng_ef.to_f * elem).to_f / 1000 # convert from kgCO2eq to tCO2eq
          emission_arr.push(naturalGas_emissions)
        end
      end
      emission_arr_total << emission_arr
    end

    buildingType = model.getBuilding.standardsBuildingType.get.to_s

    headers1 = headers.map { |n| "#{n} [tCO2eq]" }
    testing_emission_report = "./#{location}_#{buildingType}_#{year}_baseLoad_hourly_emissions.csv"
    File.open(testing_emission_report, 'a') do |file|
      file.puts headers1.join(',')
      emission_arr_total.each do |elem|
        file.puts elem.join(',')
      end
    end

    #Calculate Sum of Columns
    array_emission_all_transpose = []
    array_emission_all_transpose = emission_arr_total.transpose()
    @totals = []
    array_emission_all_transpose.each do |row|
      sum = 0
      for i in row do
        next if i.class == String
        sum += i
      end
      @totals << sum.round(15)
    end

    @totals = @totals.map { |n| n.signif(3) }
    testing_emission_total_report = "./#{location}_#{buildingType}_#{year}_total_Hourly_ghgEmissions.csv"
    File.open(testing_emission_total_report, 'a') do |file|
      file.puts headers1.join(',')
      file.puts @totals.join(',')
    end

    # close the sql file
    sqlFile.close
    return true
  end
end

# register the measure to be used by the application
NrcReportHourlyGhgEmissions.new.registerWithApplication
