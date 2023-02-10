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
    return "Report Utility Costs"
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
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('total_site_energy') # kWh; 4 significant figs
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('total_site_energy_normalized') # kWh/m2; 4 significant figs
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('annual_electricity_use') # kWh; 3 significant figs
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('annual_natural_gas_use') # GJ; 3 significant figs
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('annual_electricity_cost') # $; 2 decimal places
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('annual_natural_gas_cost') # $; 2 decimal places
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
    request << OpenStudio::IdfObject.load('Output:Meter,NaturalGas:Facility,Monthly;').get
    request << OpenStudio::IdfObject.load('Output:Meter,Electricity:Facility,Monthly;').get
    request << OpenStudio::IdfObject.load('Output:Meter,NaturalGas:Facility,Hourly;').get
    request << OpenStudio::IdfObject.load('Output:Meter,Electricity:Facility,Hourly;').get

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
	
	# Always recover the EUI.
    totalSiteEnergy_kWh = OpenStudio.convert(@sql_file.totalSiteEnergy.get, "GJ", "kWh").get
    runner.registerValue('total_site_energy', totalSiteEnergy_kWh.signif(4), 'kWh')
	floor_area = model.getBuilding.floorArea
    runner.registerValue('total_site_energy_normalized', (totalSiteEnergy_kWh/floor_area).signif(4), 'kWh')
	
	# Rate summary and costs sections.
	rate_summary = "Rule set used: #{ruleset}"
	if ruleset == "Use rates below"
	  rate_summary, cost_table = calcSimpleCosts(runner, elec_rate, gas_rate)
	elsif ruleset == "Nova Scotia rates 2021"
	  rate_summary, cost_table = calcNS2021Costs(runner)
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
  def calcSimpleCosts(runner, elec_rate, gas_rate)
  
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
                                   table = 'Annual and Peak Values - Natural Gas', 
                                   row = 'NaturalGas:Facility', 
								   column = 'Natural Gas Annual Value', 
								   units = 'GJ')

    # Convert consumption to units used for costing.
	annual_elec = annual_elec * 277.778 # Convert to kWh
	#annual_gas = annual_gas * 26.137 # Convert to m3
	# Calculate costs. Note signif defaults to three sig figs.
    # Fuel; Consumption; Unit; Cost
    cost_table = "<tr><td>Electricity</td><td>#{annual_elec.signif}</td><td>kWh</td><td>#{(annual_elec*elec_rate).round(2)}</td></tr>"
    cost_table << "<tr><td>Natural gas</td><td>#{annual_gas.signif}</td><td>GJ</sup></td><td>#{(annual_gas*gas_rate).round(2)}</td></tr>"
	
	# Populate outputs.
    runner.registerValue('annual_electricity_use', annual_elec.signif, 'kWh')
    runner.registerValue('annual_natural_gas_use', annual_gas.signif, 'GJ')
    runner.registerValue('annual_electricity_cost', (annual_elec*elec_rate).round(2), '$')
    runner.registerValue('annual_natural_gas_cost', (annual_gas*elec_rate).round(2), '$')
	
    return rate_summary, cost_table
  end
	
  def calcNS2021Costs(runner)
  
    # Define output strings (html table content).
	rate_summary = ""
	cost_table = ""
	
	# Get monthly consumption and peak results from SQL database.
	months = ["January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	monthly_elec = Hash.new
	monthly_gas = Hash.new
	annual_elec = 0.0
	annual_gas = 0.0
	monthly_peak_elec = 0.1
	(1..12).each do |month|
	  elec_total = getMonthlyEnergyConsumptionFromSQL('Electricity:Facility', month)/(3.6e+06) # return value in J, convert to kWh
	  gas_total = getMonthlyEnergyConsumptionFromSQL('NaturalGas:Facility', month)/(1.0e+09) # return value in J, convert to GJ
	  elec_peak = getMonthlyPeakEnergyFromSQL('Electricity:Facility', month)/3600000.0 # return value in J, convert to kW (averaged over the hour)
	  gas_peak = getMonthlyPeakEnergyFromSQL('NaturalGas:Facility', month)/3600000.0 # return value in J, convert to kW (averaged over the hour)
	  monthly_elec[months[month-1]] = {total: elec_total, peak: elec_peak}
	  monthly_gas[months[month-1]] = {total: gas_total, peak: gas_peak}
	  annual_elec += elec_total
	  annual_gas += gas_total
	  monthly_peak_elec = [monthly_peak_elec, elec_peak].max
	end
	
	# Figure out what tarrif to use for electricity.
	# https://www.nspower.ca/about-us/electricity/rates-tariffs
	if annual_elec < 32000
	  rate_summary << "<tr><td>Electricity</td>
	                      <td>Small General Tarrif
						  <br>Base charge $12.65 per month
						  <br>16.416 c/kWh for first 200 kWh per month
						  <br>14.602 c/kWh for additional kWh</td></tr>"
	  
	  # Calculate cost
	  base_cost = 12.65 * 12.0
	  total_cost = 0.0
	  months.each do |month|
	    use = monthly_elec[month][:total]
		use_cost = 0
		if use > 200
		  use_cost = 16.416 * 200.0 / 100.0 # Convert to $
		  use_cost += (14.602 * (use-200.0) / 100.0)
		else
		  use_cost = 16.416 * use / 100.0 # Convert to $
		end
		total_cost += use_cost
	  end
	  total_cost += base_cost
	  cost_table << "<tr><td>Electricity</td><td>#{annual_elec.signif}</td><td>kWh</td><td>#{(total_cost).round(2)}</td></tr>"
	elsif monthly_peak_elec < 1800
	  rate_summary << "<tr><td>Electricity</td>
	                      <td>Commercial tarrif
						  <br>Base charge $10.497 per kW of maximum demand
						  <br>12.545 c/kWh for first 200 kWh per month
						  <br>9.266 c/kWh for additional kWh</td></tr>"
	  
	  # Calculate cost
	  total_cost = 0.0
	  months.each do |month|
	    use = monthly_elec[month][:total]
	    peak = monthly_elec[month][:peak]
		peak_cost = peak * 10.497
		use_cost = 0
		if use > 200
		  use_cost = 12.545 * 200.0 / 100.0 # Convert to $
		  use_cost += (9.266 * (use-200.0) / 100.0)
		else
		  use_cost = 12.545 * use / 100.0 # Convert to $
		end
		total_cost += (peak_cost + use_cost)
	  end
	  cost_table << "<tr><td>Electricity</td><td>#{annual_elec.signif}</td><td>kWh</td><td>#{(total_cost).round(2)}</td></tr>"
	else 
	  rate_summary << "<tr><td>Electricity</td>
	                      <td>Large Commercial tarrif
						  <br>Demand charge $13.345 per kVA of maximum demand this month or previous Dec/Jan/Feb (calculated as kW current month only)
						  <br>9.526 c/kWh</td></tr>"
	  
	  # Calculate cost
	  total_cost = 0.0
	  months.each do |month|
	    use = monthly_elec[month][:total]
	    peak = monthly_elec[month][:peak]
		peak_cost = peak * 13.345
		use_cost = 0
		use_cost = 9.526 * use / 100.0 # Convert to $
		total_cost += (peak_cost + use_cost)
	  end
	  cost_table << "<tr><td>Electricity</td><td>#{annual_elec.signif}</td><td>kWh</td><td>#{(total_cost).round(2)}</td></tr>"
	end
	
	# Populate outputs.
    runner.registerValue('annual_electricity_use', annual_elec.signif, 'kWh')
    runner.registerValue('annual_electricity_cost', (total_cost).round(2), '$')
	
	# Figure out what tarrif to use for natural gas.
	# https://www.heritagegas.com/for-business/rates/
	# https://www.heritagegas.com/wp-content/uploads/2021/11/HGL-Rate-Table-November-2021-FINAL.pdf
	if annual_gas < 500
	  rate_summary << "<tr><td>Gas</td>
	                      <td>Rate classs 1
						  <br> Consumption: < 500 GJ
						  <br> Fixed monthly charge $21.87
						  <br>20.047 $/GJ (Grand total variable rate)</td></tr>"
	  use_cost = 20.047 * annual_gas
	  total_cost = use_cost + 21.87
	elsif annual_gas < 5000
	  rate_summary << "<tr><td>Gas</td>
	                      <td>Rate class 1a
						  <br> Consumption: 500 to 4999 GJ
						  <br> Fixed monthly charge $21.87
						  <br>20.989 $/GJ (Grand total variable rate)</td></tr>"
	  use_cost = 20.989 * annual_gas
	  total_cost = use_cost + 21.87
	elsif annual_gas < 50000
	  rate_summary << "<tr><td>Gas</td>
	                      <td>Rate class 2
						  <br> Consumption: 5000 to 50,000 GJ
						  <br> Fixed monthly charge $562.83
						  <br>16.760 $/GJ (Grand total variable rate)</td></tr>"
	  use_cost = 16.760 * annual_gas
	  total_cost = use_cost + 562.83
	else
	  rate_summary << "<tr><td>Gas</td>
	                      <td>Rate class 2
						  <br> Consumption: > 50,000 GJ
						  <br> Fixed monthly charge $1,995.54
						  <br>15.241 $/GJ (Grand total variable rate)</td></tr>"
	  use_cost = 15.241 * annual_gas
	  total_cost = use_cost + 1995.54
	end
	cost_table << "<tr><td>Gas</td><td>#{annual_gas.signif}</td><td>GJ</td><td>#{(total_cost).round(2)}</td></tr>"
	
	# Populate outputs.
    runner.registerValue('annual_natural_gas_use', annual_gas.signif, 'GJ')
    runner.registerValue('annual_natural_gas_cost', (total_cost).round(2), '$')
	
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
          WHERE Name='#{report}'
		  AND ReportingFrequency='Daily'
		  AND Month=#{month}
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
          WHERE Name='#{report}'
		  AND ReportingFrequency='Hourly'
		  AND Month=#{month}
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