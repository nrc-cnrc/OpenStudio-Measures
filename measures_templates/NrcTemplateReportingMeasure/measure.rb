# Start the measure
require_relative 'resources/NRCReportingMeasureHelper'
require 'erb'

# start the measure
class NrcReportingMeasure < OpenStudio::Measure::ReportingMeasure

  attr_accessor :use_json_package, :use_string_double
  
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCReportingMeasureHelper)
  
  # Human readable name
  def name
    return "NrcTemplateReportingMeasure"
  end

  # Human readable description
  def description
    return "This template reporting measure is used to ensure consistency in detailed BTAP measures using the NRC modificatoins."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "This template reporting measure is used to ensure consistency in BTAP measures using the NRC modificatoins."
  end
  
  # Define the outputs that the measure will create ??? Can this be folded into the initialise method?
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new
    return outs
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

    request = OpenStudio::IdfObject.load('Output:Variable,,Site Outdoor Air Drybulb Temperature,Hourly;').get
    result << request

    return result
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
            "name" => "a_string_argument",
            "type" => "String",
            "display_name" => "A String Argument (string)",
            "default_value" => "The Default Value",
            "is_required" => true
        },
        {
            "name" => "a_double_argument",
            "type" => "Double",
            "display_name" => "A Double numeric Argument (double)",
            "default_value" => 0,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "an_integer_argument",
            "type" => "Integer",
            "display_name" => "An Integer numeric Argument (integer)",
            "default_value" => 1,
            "max_double_value" => 20,
            "min_double_value" => 0,
            "is_required" => true
        },
        {
            "name" => "a_string_double_argument",
            "type" => "StringDouble",
            "display_name" => "A String Double numeric Argument (double)",
            "default_value" => 23.0,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "valid_strings" => ["Baseline", "NA"],
            "is_required" => true
        },
        {
            "name" => "a_choice_argument",
            "type" => "Choice",
            "display_name" => "A Choice String Argument ",
            "default_value" => "choice_1",
            "choices" => ["choice_1", "choice_2"],
            "is_required" => true
        },
        {
            "name" => "a_bool_argument",
            "type" => "Bool",
            "display_name" => "A Boolean Argument ",
            "default_value" => false,
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

    sql_file = runner.lastEnergyPlusSqlFile
    if sql_file.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sql_file = sql_file.get
    model.setSqlFile(sql_file)

    # Put data into the local variable 'output', all local variables are available for erb to use when configuring the input html file

    output =  'Measure Name = ' << name << '<br>'
    output << 'Building Name = ' << model.getBuilding.name.get << '<br>' # optional variable
    output << 'Floor Area = ' << model.getBuilding.floorArea.to_s << '<br>' # double variable
    output << 'Floor to Floor Height = ' << model.getBuilding.nominalFloortoFloorHeight.to_s << ' (m)<br>' # double variable
    output << 'Net Site Energy = ' << sql_file.netSiteEnergy.to_s << ' (GJ)<br>' # double variable

    # Read in template
    html_in_path = "#{File.dirname(__FILE__)}/resources/report.html.in"
    html_in = ''
    File.open(html_in_path, 'r') do |file|
      html_in = file.read
    end

    # get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    sql_file.availableEnvPeriods.each do |env_pd|
      env_type = sql_file.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new('WeatherRunPeriod')
          ann_env_pd = env_pd
          break
        end
      end
    end

    # only try to get the annual timeseries if an annual simulation was run
    if ann_env_pd

      # get desired variable
      key_value = 'Environment'
      time_step = 'Hourly' # "Zone Timestep", "Hourly", "HVAC System Timestep"
      variable_name = 'Site Outdoor Air Drybulb Temperature'
      output_timeseries = sql_file.timeSeries(ann_env_pd, time_step, variable_name, key_value) # key value would go at the end if we used it.

      if output_timeseries.empty?
        runner.registerWarning('Timeseries not found.')
      else
        runner.registerInfo('Found timeseries.')
      end
    else
      runner.registerWarning('No annual environment period found.')
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
      rescue StandardError
        file.flush
      end
    end

    # close the sql file
    sql_file.close
	
    return true
  end
end

# register the measure to be used by the application
NrcReportingMeasure.new.registerWithApplication
