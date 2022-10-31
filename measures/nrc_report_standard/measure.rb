# Start the measure
require_relative 'resources/NRCReportingMeasureHelper'
require_relative 'resources/report_writer.rb'
require_relative 'resources/report_sections.rb'
require_relative 'resources/additional_measure_methods.rb'
require 'erb'
require 'json'
#require 'caracal' # Required nokogiri which does not work with openstudio_cli.exe on server

# start the measure
class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  attr_accessor :use_json_package, :use_string_double
  attr_accessor :btap_data, :qaqc_data

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCReportingMeasureHelper)

  # Human readable name
  def name
    return "NRC Standard Report"
  end

  # Human readable description
  def description
    return "This reporting measure uses and extends the standard QAQC reporting from openstudio-standards."
  end

  # Human readable description of modeling approach
  def modeler_description
    return "The report calls the reporting in BTAP to create a json file describing the model and results. Extensions to the
	        functionality are contained here (and do...?)"
  end

  # Define the outputs that the measure will create.
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('total_site_energy') # kWh; 4 significant figs
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

    # Parse the model for setpoints and add to the requested outputs.
    model = runner.lastOpenStudioModel
    if not model.empty? then
      model = model.get
      setPoints = model.getSetpointManagers
      puts ("Setpoints object count: #{setPoints.size}".red)
      setPoints.each do |setPoint|
        puts ("#{setPoint.controlVariable}".light_blue)
        puts ("#{setPoint.setpointNode.get.name}".light_blue)
        variable = setPoint.controlVariable
        node = setPoint.setpointNode.get.name
        result << OpenStudio::IdfObject.load("Output:Variable,#{node},System Node #{variable},Hourly;").get
        result << OpenStudio::IdfObject.load("Output:Variable,#{node},System Node Setpoint #{variable},Hourly;").get
      end
    end

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
        "name" => "a_choice_argument",
        "type" => "Choice",
        "display_name" => "A Choice String Argument ",
        "default_value" => "choice_1",
        "choices" => ["choice_1", "choice_2"],
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

    # Get the last model and sql file.
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

    # Recover the btap and qaqc data. Store in global variables for use in report sections.
    # Need to generate the qaqc json first.
    if model.getBuilding.standardsTemplate.is_initialized
      standardsTemplate = (model.getBuilding.standardsTemplate).to_s
      @standard = Standard.build(standardsTemplate)
    else
      puts "The measure wasn't able to determine the standards template from the model, a default value of 'NECB2017' will be used.".red
      @standard = Standard.build('NECB2017')
    end

    qaqc_data = @standard.init_qaqc(model)
    command = "SELECT Value
                  FROM TabularDataWithStrings
                  WHERE ReportName='LEEDsummary'
                  AND ReportForString='Entire Facility'
                  AND TableName='Sec1.1A-General Information'
                  AND RowName = 'Principal Heating Source'
                  AND ColumnName='Data'"
    value = model.sqlFile.get.execAndReturnFirstString(command)
    # Make sure all the data are available.
    qaqc_data[:building][:principal_heating_source] = 'unknown'
    unless value.empty?
      qaqc_data[:building][:principal_heating_source] = value.get
    end

    if qaqc_data[:building][:principal_heating_source] == 'Additional Fuel'
      model.getPlantLoops.sort.each do |iplantloop|
        boilers = iplantloop.components.select { |icomponent| icomponent.to_BoilerHotWater.is_initialized }
        qaqc_data[:building][:principal_heating_source] = 'FuelOilNo2' unless boilers.select { |boiler| boiler.to_BoilerHotWater.get.fuelType.to_s == 'FuelOilNo2' }.empty?
      end
    end

    # Use the openstudio-standards methods in btap data_point. Output files need to be 'report.html' for some funky reason.
    btap_data = BTAPData.new(model: model,
                             runner: runner,
                             cost_result: nil,
                             npv_start_year: nil, 
                             npv_end_year: nil, 
                             npv_discount_rate: nil,
                             qaqc: qaqc_data).btap_data

    # Ensure that all levels of the has have symbols (makes for consistent look up syntax)							
    qaqc_data.transform_keys!(&:to_sym)
    btap_data.transform_keys!(&:to_sym)
    puts "#{btap_data.keys}".light_blue

    # Add fields to btap_data that we want in our output.
    btap_data.merge! simulation_configuration(qaqc_data)
    btap_data.merge! envelope_areas(qaqc_data)
    btap_data.merge! gatherSetpointSummary(model)

    # Create output data structure.
    # This is a structured has of all the sections we want to report on.
    # Each section is a hash.
    output = Array.new
    output << ServerSummary.new(btap_data: btap_data)
    output << ModelSummary.new(btap_data: btap_data)
    output << EnergySummary.new(btap_data: btap_data)
    output << EnvelopeSummary.new(btap_data: btap_data, standard: @standard)
    output << InfiltrationSummary.new(btap_data: btap_data, standard: @standard)
    output << VentilationSummary.new(btap_data: btap_data, standard: @standard, sqlFile: sql_file, model:model)
	output << LightSummary.new(btap_data: btap_data, standard: @standard)
    output.each { |section| puts section.class }
    output.each { |section| puts section.content }

    # Put this together in an html file.
    html = Html_writer.new
    writer = Writer.new(html)
    writer.write(output)

    # Put this together in a word file. ** Requires caracal.
=begin
    docx=Word_writer.new
    writer = Writer.new(docx)
    writer.write(output)
=end

    # Put this together in a word file.
    json = Json_writer.new
    writer = Writer.new(json)
    writer.write(output)

    # Close the sql file.
    sql_file.close

    # Write other output files.
    File.open('./btap_data.json', 'w') { |f| f.write(JSON.pretty_generate(btap_data.sort.to_h, allow_nan: true)) }
    puts "Wrote file btap_data.json in #{Dir.pwd} "

    File.open('./qaqc_data.json', 'w') { |f| f.write(JSON.pretty_generate(qaqc_data, allow_nan: true)) }
    puts "Wrote file qaqc_data.json in #{Dir.pwd} "

    # Set output variables (listed in outputs method). Grab the numbers directly from btap_data.
    runner.registerValue('total_site_energy', ((btap_data[:energy_eui_total_gj_per_m_sq]) / 0.0036).signif(4), 'kWh')
   #puts "#{output.class}".yellow
    

    return true
  end

  # Additional data for btap_data json structure
  #  Simulation environment configuration
  def simulation_configuration(qaqc_data)
    data = { simulation_openstudio_version: qaqc_data[:openstudio_version].split('+')[0],
             simulation_openstudio_revision: qaqc_data[:openstudio_version].split('+')[1],
             simulation_energyplus_version: qaqc_data[:energyplus_version]
    }
  end

  # Building envelope areas
  def envelope_areas(qaqc_data)
    data = { bldg_outdoor_walls_area_m2: qaqc_data[:envelope][:outdoor_walls_area_m2],
             bldg_outdoor_roofs_area_m2: qaqc_data[:envelope][:outdoor_roofs_area_m2],
             bldg_outdoor_floors_area_m2: qaqc_data[:envelope][:outdoor_floors_area_m2],
             bldg_ground_walls_area_m2: qaqc_data[:envelope][:ground_walls_area_m2],
             bldg_ground_roofs_area_m2: qaqc_data[:envelope][:ground_roofs_area_m2],
             bldg_ground_floors_area_m2: qaqc_data[:envelope][:ground_floors_area_m2],
             bldg_windows_area_m2: qaqc_data[:envelope][:windows_area_m2],
             bldg_doors_area_m2: qaqc_data[:envelope][:doors_area_m2],
             bldg_overhead_doors_area_m2: qaqc_data[:envelope][:overhead_doors_area_m2],
             bldg_skylights_area_m2: qaqc_data[:envelope][:skylights_area_m2]
    }
  end
end

# register the measure to be used by the application
NrcReportingMeasureStandard.new.registerWithApplication
