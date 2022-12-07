require 'openstudio-standards'
require_relative 'resources/NRCReportingMeasureHelper'
require 'csv'
require 'fileutils'
require 'erb'
require 'json'
require 'zlib'
require 'base64'
# start the measure
class NrcReportSeveralOutputVariables < OpenStudio::Measure::ReportingMeasure
  #Adds helper functions to make life a bit easier and consistent.
  attr_accessor :use_json_package, :use_string_double
  include(NRCReportingMeasureHelper)
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Nrc Report Several Output Variables'
  end

  # human readable description
  def description
    return 'This measure displays csv files for output variables.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'The measure creates CSV files for output variables entered by the user. The output variables have to be entered in the format :
    OutputVariable1 : Key Name1,OutputVariable2 : Key Name2,OutputVariable3 : Key Name3,...etc
    Also the measures creates hourly data for meter outputs ("Electricity:Facility", "Gas:Facility", "NaturalGas:Facility")'
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
        "name" => "reporting_frequency",
        "type" => "Choice",
        "display_name" => "Reporting Frequency",
        "default_value" => "Hourly",
        "choices" => ["Hourly", "Timestep"],
        "is_required" => true
      },
      {
        "name" => "output_variables",
        "type" => "String",
        "display_name" => "Please Enter the Output Variables in the format 'OutputVariable1 : Key Name1,OutputVariable2 : Key Name2,OutputVariable3 : Key Name3'   ",
        "default_value" => "Heating Coil Heating Rate:*,Baseboard Total Heating Rate:*",
        "is_required" => true
      }
    ]
  end

  # Return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return result
    end
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    reporting_frequency = runner.getStringArgumentValue("reporting_frequency", user_arguments)
    output_variables = runner.getStringArgumentValue("output_variables", user_arguments)

    myArray = []
    if output_variables.include? ','
      myArray = output_variables.split(/,/)
    else
      myArray << output_variables
    end
    result << OpenStudio::IdfObject.load('Output:Meter,NaturalGas:Facility,Hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Electricity:Facility,Hourly;').get

    myArray.to_a.each do |output_variable|
      output_var = output_variable.split(/:/)[0]
      key_var = output_variable.split(/:/)[1]
      key_var = '*' if key_var == ''
      outputVariable = OpenStudio::Model::OutputVariable.new(output_var, model)
      outputVariable.setReportingFrequency(reporting_frequency.to_s)
      outputVariable.setKeyValue(key_var)
      result << OpenStudio::IdfObject.load("Output:Variable,#{key_var},#{output_var},#{reporting_frequency};").get
    end
    return result
  end

  # Define the outputs that the measure will create.
  def outputs
    result = OpenStudio::Measure::OSOutputVector.new
    return result
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      puts "Cannot find last model.".red
      return false
    end
    model = model.get

    # use the built-in error checking (need model)
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    reporting_frequency = runner.getStringArgumentValue("reporting_frequency", user_arguments)
    output_variables = runner.getStringArgumentValue("output_variables", user_arguments)

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.').red
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

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
              allValues << value.signif(3)
            end
            headers << "#{key_value.to_s}:#{variable_name.to_s}[#{target_units}]"
            values[cnt] = allValues
          else
            headers << "#{key_value.to_s}:#{variable_name.to_s}[#{units}]"
            arr = timeseries.values.to_a
            arr = arr.map { |x| x.signif(3) }
            values[cnt] = arr
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

    File.open("./report_#{city}_#{buildingType}_baseLoad.csv", 'wb') do |file|
      file.puts headers.join(',')
      new_arr.each do |elem|
        file.puts elem.join(',')
      end
    end

=begin
    # Read in template
    html_in_path = "#{File.dirname(__FILE__)}/resources/report.html.in"
    html_in = ''
    File.open(html_in_path, 'r') do |file|
      html_in = file.read
    end

    # Configure template with variable values
    renderer = ERB.new(html_in)
    html_out = renderer.result(binding)

    # Write html file
    html_out_path = './report.html'
    File.open(html_out_path, 'w') do |file|
      file << html_out
      # make sure data is written to the disk one way or the other
      begin
        file.fsync
      rescue StandardError
        file.flush
      end
    end
=end

    # close the sql file
    sqlFile.close

    return true
  end

end

# register the measure to be used by the application
NrcReportSeveralOutputVariables.new.registerWithApplication
