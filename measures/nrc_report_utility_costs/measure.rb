# Start the measure
require_relative 'resources/NRCReportingMeasureHelper'
require 'erb'

# start the measure
class NrcReportUtilityCosts < OpenStudio::Measure::ReportingMeasure

  attr_accessor :use_json_package, :use_string_double
  
  #Adds helper functions to make life a bit easier and consistent.
  include(NRCReportingMeasureHelper)
  
  # Human readable name
  def name
    return "NRC Report Utility Costs"
  end

  # Human readable description
  def description
    return "This measure calculates utility costs for Canadian locations. By default a simple $/kWh tarrif can be applied but for 
	    several locations more complex rules are enabled.
		Peak values are reported averaged over the hour (the default LEED table produced by E+ reports the PEAK timestep value)."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "The measure creates a simple csv file and html output. The annual costs are available as output metrics for PAT."
  end
  
  # Define the outputs that the measure will create.
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('annual electricity ($)')
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('annual natural gas ($)')
    return outs
  end

  # Return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # Warning: Do not change the name of this method to be snake_case. The method must be lowerCamelCase.
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    request = OpenStudio::IdfObjectVector.new

    # Use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return request
    end

    # List outputs required.
	# No need ofr these as OpenStudio outputs the data required already. If this changes the CI testing will 
	# catch the change.
    #request << OpenStudio::IdfObject.load('Output:Meter,Gas:Facility,Monthly;').get
    #request << OpenStudio::IdfObject.load('Output:Meter,Electricity:Facility,Monthly;').get

    return request
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
            "name" => "calc_choice",
            "type" => "Choice",
            "display_name" => "Utility cost choice",
            "default_value" => "Use rates below",
            "choices" => ["Use rates below", "Nova Scotia rates 2021"],
            "is_required" => true
        },
        {
            "name" => "electricity_cost",
            "type" => "Double",
            "display_name" => "Electricity rate ($/kWh)",
            "default_value" => 0.10,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => false
        },
        {
            "name" => "gas_cost",
            "type" => "Double",
            "display_name" => "Natural gas rate ($/m3)",
            "default_value" => 0.20,
            "max_double_value" => 100.0,
            "min_double_value" => 0.0,
            "is_required" => false
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
      runner.registerError("Cannot find last model.")
      return false
    end
    model = model.get

    @sql_file = runner.lastEnergyPlusSqlFile
    if @sql_file.empty?
      runner.registerError("Cannot find last sql file.")
      return false
    end
    @sql_file = @sql_file.get
    model.setSqlFile(@sql_file)

    # Read in template
    html_in_path = "#{File.dirname(__FILE__)}/resources/report.html.in"
    html_in = ""
    File.open(html_in_path, "r") do |file|
      html_in = file.read
    end
	
	# Recover arguments and set local variables
    ruleset = arguments['calc_choice']
    elec_rate = arguments['electricity_cost']
    gas_rate = arguments['gas_cost']
	
    # Put data into the local variable 'summary', all local variables are available for erb to use when configuring the input html file.
    summary =  "<h1>#{name}</h1>"
    summary << "Building Name: #{model.getBuilding.name.get}<br>" # optional variable
	
	# Rate summary and costs sections.
	rate_summary = "Rule set used: #{ruleset}"
	puts "Ruleset: #{ruleset}".yellow
	if ruleset == "Use rates below"
	  rate_summary, cost_table = calcSimpleCosts(elec_rate, gas_rate)
	elsif ruleset == "Nova Scotia rates 2021"
	  rate_summary, cost_table = calcNS2021Costs
	end
	
    # Get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    @sql_file.availableEnvPeriods.each do |env_pd|
      env_type = @sql_file.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new('WeatherRunPeriod')
          ann_env_pd = env_pd
          break
        end
      end
    end

    # Only try to get the annual timeseries if an annual simulation was run
    if ann_env_pd

      # Get desired variable
      key_value = 'Environment'
      time_step = 'Hourly' # "Zone Timestep", "Hourly", "HVAC System Timestep"
      variable_name = 'Site Outdoor Air Drybulb Temperature'
      output_timeseries = @sql_file.timeSeries(ann_env_pd, time_step, variable_name, key_value) # key value would go at the end if we used it.

      if output_timeseries.empty?
        runner.registerWarning('Timeseries not found.')
      else
        runner.registerInfo('Found timeseries.')
      end
    else
      runner.registerWarning('No annual environment period found.')
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

    # close the sql file
    @sql_file.close
	
    return true
	
  end
  
  # Specific costing methods
  def calcSimpleCosts(elec_rate, gas_rate)
  
	# Create table content for rate summary.
    rate_summary = "<tr><td>Electricity</td><td>#{elec_rate} $/kWh</td></tr>"
    rate_summary << "<tr><td>Natural gas</td><td>#{gas_rate} $/m<sup>3</sup></td></tr>"
	
	# Get annual results from SQL database.
	annual_elec = getValueFromSQL(report = 'EnergyMeters', 
                                   scope = 'Entire Facility', 
                                   table = 'Annual and Peak Values - Electricity', 
                                   row = 'ElectricityNet:Facility', 
								   column = 'Electricity Annual Value', 
								   units = 'GJ')
	annual_gas = getValueFromSQL(report = 'EnergyMeters', 
                                   scope = 'Entire Facility', 
                                   table = 'Annual and Peak Values - Gas', 
                                   row = 'Gas:Facility', 
								   column = 'Gas Annual Value', 
								   units = 'GJ')

	# Calculate costs. Note signif defaults to three sig figs.
	# *** Need to convert fuel use from GJ to units required for costing.
    # Fuel; Consumption; Unit; Cost"
    cost_table = "<tr><td>Electricity</td><td>#{annual_elec.signif}</td><td>GJ</td><td>#{(annual_elec*elec_rate).round(2)}</td></tr>"
    cost_table << "<tr><td>Natural gas</td><td>#{annual_gas.signif}</td><td>GJ</td><td>#{(annual_gas*gas_rate).round(2)}</td></tr>"
    return rate_summary, cost_table
  end
	
  def calcNS2021Costs
  
	# Get monthly consumption and peak results from SQL database.
	months = ["January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	monthly_elec = Hash.new
	monthly_gas = Hash.new
	annual_elec = 0.0
	annual_gas = 0.0
	monthly_peak_elec = 0.1
	(1..12).each do |month|
	  elec_total = getMonthlyEnergyConsumptionFromSQL(10, month)/3.6e+6 # return value in J, convert to kWh
	  gas_total = getMonthlyEnergyConsumptionFromSQL(952, month)/3.6e+6 # return value in J, convert to kWh
	  elec_peak = getMonthlyPeakEnergyFromSQL(9, month)/3600.0 # return value in J, convert to W (averaged over the hour)
	  gas_peak = getMonthlyPeakEnergyFromSQL(951, month)/3600.0 # return value in J, convert to W (averaged over the hour)
	  monthly_elec[months[month-1]] = {total: elec_total, peak: elec_peak}
	  monthly_gas[months[month-1]] = {total: gas_total, peak: gas_peak}
	  annual_elec += elec_total
	  annual_gas += gas_total
	  monthly_peak_elec = max(monthly_peak_elec, elec_peak)
	end
	
	puts "Elec monthly: #{monthly_elec}".red
	puts "Gas monthly: #{monthly_gas}".light_blue
	puts "Elec annual: #{annual_elec}".red
	puts "Gas annual: #{annual_gas}".light_blue
	
	# Figure out what tarrif to use for electricity.
	# https://www.nspower.ca/about-us/electricity/rates-tariffs
	if annual_elec < 32000
	  puts "Small General Tarrif".pink
	elsif monthly_peak_elec < 1800
	  puts "Commercial tarrif".pink
	else 
	  puts "Large Commercial tarrif".pink
	end
	
	  
    return rate_summary, cost_table
  end
	
  # SQL queries
  # Recover data from TabularDataWithStrings
  def getValueFromSQL(report, scope, table, row, column, units)

	# Generate the SQL query
	query = "SELECT Value 
          FROM TabularDataWithStrings
          WHERE ReportName='#{report}'
          AND ReportForString='#{scope}'
          AND TableName='#{table}'
		  AND RowName='#{row}'
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
  
  
  def getMonthlyEnergyConsumptionFromSQL(report, month)

	# Generate the SQL query
	query = "SELECT SUM(Value) 
          FROM ReportVariableWithTime
          WHERE ReportDataDictionaryIndex='#{report}'
		  AND Month='#{month}'
		  AND EnvironmentPeriodIndex = 3" # Ths is the simulation period, not design days.
		  
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
  def getMonthlyPeakEnergyFromSQL(report, month)

	# Generate the SQL query
	query = "SELECT MAX(Value) 
          FROM ReportVariableWithTime
          WHERE ReportDataDictionaryIndex='#{report}'
		  AND Month='#{month}'
		  AND EnvironmentPeriodIndex = 3" # Ths is the simulation period, not design days.
		  
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
end

# register the measure to be used by the application
NrcReportUtilityCosts.new.registerWithApplication
