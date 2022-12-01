require 'openstudio-standards'
require_relative 'resources/NRCReportingMeasureHelper'
require "#{File.dirname(__FILE__)}/resources/os_lib_reporting"
require "#{File.dirname(__FILE__)}/resources/os_lib_helper_methods"

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
        "default_value" => "Site Outdoor Air Drybulb Temperature:*,Baseboard Total Heating Rate:*",
        "is_required" => true
      }
    ]
    possible_sections.each do |method_name|
      @measure_interface_detailed << {
        "name" => method_name,
        "type" => "Bool",
        "display_name" => "OsLib_Reporting.#{method_name}(nil,nil,nil,true)[:title]",
        "default_value" => true,
        "is_required" => true
      }
    end
  end

  def possible_sections
    result = []
    # methods for sections in order that they will appear in report
    result << 'loads_summary_section'
    result
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

    myArray.to_a.each do |output_variable|
      output_var = output_variable.split(/:/)[0]
      key_var = output_variable.split(/:/)[1]
      key_var = '*' if key_var == ''
      outputVariable = OpenStudio::Model::OutputVariable.new(output_var, model)
      outputVariable.setReportingFrequency(reporting_frequency.to_s)
      outputVariable.setKeyValue(key_var)
      result << OpenStudio::IdfObject.load("Output:Variable,#{key_var},#{output_variable},#{reporting_frequency};").get
    end

    model = runner.lastOpenStudioModel
    model = model.get
    # OpenStudio doesn't seem to like two meters of the same name, even if they have different reporting frequencies.
    meter_names = ["Electricity:Facility", "Gas:Facility", "NaturalGas:Facility"]
    meters = model.getOutputMeters
    #reporting initial condition of model
    runner.registerInitialCondition("The model started with #{meters.size} meter objects.")

    meter_names.each do |meter_name|
      add_meter = true

      # If a meter exists change the reporting frequency to hourly.
      meters.each do |meter|
        if meter.name.to_s == meter_name
          old_frequency = meter.reportingFrequency
          runner.registerWarning("A meter named #{meter.name.to_s} already exists with reporting frequency #{old_frequency}. Changing frequency to hourly.")
          meter.setReportingFrequency("Hourly")
          add_meter = false
        end
      end

      if add_meter
        meter = OpenStudio::Model::OutputMeter.new(model)
        meter.setName(meter_name)
        meter.setReportingFrequency("Hourly")
        meter.setMeterFileOnly(true)
      end
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

    # get measure arguments
    reporting_frequency = runner.getStringArgumentValue("reporting_frequency", user_arguments)
    output_variables = runner.getStringArgumentValue("output_variables", user_arguments)

    meters = model.getOutputMeters
    # reporting initial condition of model
    puts "The model started with ".green + "#{meters.size}".light_blue + " meter objects.".green

    # get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.').red
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)
    sqlFile.availableEnvPeriods.each do |env_pd|
      puts " mmmmm sql measure ::: #{sqlFile.availableReportingFrequencies(env_pd)}".green #Only Hourly and timestep
      env_type = sqlFile.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new('WeatherRunPeriod')
          ann_env_pd = env_pd
          break
        end
      end
    end

    meter_names = sqlFile.availableVariableNames(ann_env_pd, "Hourly")
    meters = model.getOutputMeters
    #reporting final condition of model
    runner.registerFinalCondition("The model finished with #{meters.size} meter objects.")
    # reporting final condition of model
    puts "The model finished with ".green + "#{meters.size}".light_blue + " meter objects.".green
    # assign the user inputs to variables
    args = OsLib_HelperMethods.createRunVariables(runner, model, user_arguments, arguments)
    unless args
      return false
    end

    # pass measure display name to erb
    @name = name
    # create a array of sections to loop through in erb file
    @sections = []
    ordered_section = []
    # generate data for requested sections
    sections_made = 0
    possible_sections.each do |method_name|
      begin
        #next unless args[method_name]
        section = false
        eval("section = OsLib_Reporting.#{method_name}(model,sqlFile,runner,false)")
        display_name = eval("OsLib_Reporting.#{method_name}(nil,nil,nil,true)[:title]")
        if section
          ordered_section << section

          sections_made += 1
          # look for emtpy tables and warn if skipped because returned empty
          section[:tables].each do |table|
            if not table
              runner.registerWarning("A table in #{display_name} section returned false and was skipped.")
              section[:messages] = ["One or more tables in #{display_name} section returned false and was skipped."]
            end
          end
        else
          runner.registerWarning("#{display_name} section returned false and was skipped.")
          section = {}
          section[:title] = "#{display_name}"
          section[:tables] = []
          section[:messages] = []
          section[:messages] << "#{display_name} section returned false and was skipped."
          ordered_section << section
        end
      rescue => e
        display_name = eval("OsLib_Reporting.#{method_name}(nil,nil,nil,true)[:title]")
        if display_name == nil then
          display_name == method_name
        end
        runner.registerWarning("#{display_name} section failed and was skipped because: #{e}. Detail on error follows.")
        runner.registerWarning("#{e.backtrace.join("\n")}")

        # add in section heading with message if section fails
        section = eval("OsLib_Reporting.#{method_name}(nil,nil,nil,true)")
        section[:messages] = []
        section[:messages] << "#{display_name} section failed and was skipped because: #{e}. Detail on error follows."
        section[:messages] << ["#{e.backtrace.join("\n")}"]
        ordered_section << section
      end
    end
    @sections << ordered_section[0]

    html_in_path = "#{File.dirname(__FILE__)}/resources/report.html.erb"
    if File.exist?(html_in_path)
      html_in_path = html_in_path
    end
    html_in = ''
    File.open(html_in_path, 'r') do |file|
      html_in = file.read
    end
    # configure template with variable values
    renderer = ERB.new(html_in)
    html_out = renderer.result(binding)
    # write html file
    html_out_path = './report.html'
    File.open(html_out_path, 'w') do |file|
      file << html_out
      # make sure data is written to the disk one way or the other
      begin
        file.fsync
      rescue
        file.flush
      end
    end

    # close the sql file
    sqlFile.close
    return true
  end
end

# register the measure to be used by the application
NrcReportSeveralOutputVariables.new.registerWithApplication
