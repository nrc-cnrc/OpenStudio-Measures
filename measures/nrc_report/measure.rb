# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'openstudio-standards'
require "#{File.dirname(__FILE__)}/resources/os_lib_reporting"
require "#{File.dirname(__FILE__)}/resources/os_lib_schedules"
require "#{File.dirname(__FILE__)}/resources/os_lib_helper_methods"
require "#{File.dirname(__FILE__)}/resources/Siz.Model"
require_relative 'resources/NRCReportingMeasureHelper'

require 'erb'
require 'json'
require 'zlib'
require 'base64'

# start the measure
class NrcReport < OpenStudio::Measure::ReportingMeasure

  #Adds helper functions to make life a bit easier and consistent.
  attr_accessor :use_json_package, :use_string_double
  include(NRCReportingMeasureHelper)

  # human readable name
  def name
    'NrcReport'
  end

  # human readable description
  def description
    'This measure generates a report  of the model supplied in html format.
     The report provides either summary or detailed view depending on the users choice.'
  end

  # human readable description of modeling approach
  def modeler_description
    'This reporting measure generates an output report based on model information and EnergyPlus outputs.
     It provides general summary and detailed information on the building. Output includes construction and envelope
     description and details. Also, includes both an annual summary and monthly detailed heat gains and losses tables.
     In addition, the report provides high level tables of thermal zones and HVAC air loops.
     In this measure, windows areas will only be included in the calculations for fenestration door wall ratio,
     as there are no doors in the models.
     The heat loss and gain section is modified from BCL measure (https://bcl.nrel.gov/node/84747) to use si units.
     The HVAC detailed section is based on OpenStudio Results measure (https://bcl.nrel.gov/node/82918).
     The End Use table is modified from OpenStudio Results measure to create tables instead of charts'
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

    @measure_interface_detailed = [
      {
        "name" => "report_depth",
        "type" => "Choice",
        "display_name" => "Report detail level",
        "default_value" => "Summary",
        "choices" => ["Summary", "Detailed"],
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
    result << 'model_summary_section'
    result << 'server_summary_section'
    result << 'building_construction_detailed_section'
    result << 'construction_summary_section'
    result << 'heat_gains_summary_section'
    result << 'heat_loss_summary_section'
    result << 'heat_gains_detail_section'
    result << 'heat_losses_detail_section'
    result << 'steadySate_conductionheat_losses_section'
    result << 'thermal_zone_summary_section'
    result << 'hvac_summary_section'
    result << 'air_loops_detail_section'
    result << 'plant_loops_detail_section'
    result << 'zone_equipment_detail_section'
    result << 'hvac_airloops_detailed_section1'
    result << 'hvac_plantloops_detailed_section1'
    result << 'hvac_zoneEquip_detailed_section1'
    result << 'output_data_end_use_table'
    result << 'serviceHotWater_summary_section'
    result << 'interior_lighting_summary_section'
    result << 'interior_lighting_detail_section'
    result << 'daylighting_summary_section'
    result << 'exterior_light_section'
    result << 'shading_summary_section'
    result
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
    model = runner.lastOpenStudioModel

    # monthly heat gain outputs
    result << OpenStudio::IdfObject.load('Output:Variable,,Electric Equipment Total Heating Energy,monthly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Gas Equipment Total Heating Energy,monthly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Zone Lights Total Heating Energy,monthly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Zone People Sensible Heating Energy,monthly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Zone Infiltration Sensible Heat Gain Energy,monthly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Surface Window Heat Gain Energy,monthly;').get

    # monthly heat loss outputs
    result << OpenStudio::IdfObject.load('Output:Variable,,Zone Infiltration Sensible Heat Loss Energy,monthly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Surface Window Heat Loss Energy,monthly;').get

    # hourly outputs (will bin by hour to heat loss or gain and roll up to monthly, may break out by surface type)
    result << OpenStudio::IdfObject.load('Output:Variable,,Surface Average Face Conduction Heat Transfer Energy,hourly;').get
    return result
  end

  def outputs
    result = OpenStudio::Measure::OSOutputVector.new
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('heating') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('cooling') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('electricity_consumption') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('natural_gas_consumption') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('district_heating') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('district_cooling') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('total_site_eui') # kWh
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('eui') # kWh/m^2
    return result
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    #get arguments
    report_depth = runner.getStringArgumentValue("report_depth", user_arguments)

    # Get the last model and sql file.
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.').yellow
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

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
    @sections << ordered_section[1]
    @sections << ordered_section[17]
    @sections << ordered_section[3]
    @sections << ordered_section[2] unless report_depth != "Detailed"
    @sections << ordered_section[4]
    @sections << ordered_section[6] unless report_depth != "Detailed"
    @sections << ordered_section[5]
    @sections << ordered_section[7] unless report_depth != "Detailed"
    @sections << ordered_section[8]
    @sections << ordered_section[9]
    @sections << ordered_section[10]
    @sections << ordered_section[11] unless report_depth != "Detailed"
    @sections << ordered_section[12] unless report_depth != "Detailed"
    @sections << ordered_section[13] unless report_depth != "Detailed"
    @sections << ordered_section[14]
    @sections << ordered_section[15]
    @sections << ordered_section[16]
    @sections << ordered_section[18]
    @sections << ordered_section[19]
    @sections << ordered_section[20] unless report_depth != "Detailed"
    @sections << ordered_section[21]
    @sections << ordered_section[22]
    @sections << ordered_section[23]

    html_in_path = "#{File.dirname(__FILE__)}/resources/report.html.erb"
    if File.exist?(html_in_path)
      html_in_path = html_in_path
      # else
      #html_in_path = "#{File.dirname(__FILE__)}/report.html.erb"
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

    # get short or extended list (not using now)
    fuel_types = []
    OpenStudio::EndUseFuelType.getValues.each do |fuel_type|
      # convert integer to string
      fuel_name = OpenStudio::EndUseFuelType.new(fuel_type).valueDescription
      next if fuel_name == "Water"
      fuel_types << fuel_name
    end

    # Calculate the output values in PAT
    array_endUse_all = []
    array_endUse = []
    endUse_summary_data_table = {}
    endUse_summary_data_table[:data] = []
    ####### This loop is copied from OpenStudio Results measure, updated to create a table instead of a chart
    OpenStudio::EndUseCategoryType.getValues.each do |end_use|
      # get end uses
      end_use = OpenStudio::EndUseCategoryType.new(end_use).valueDescription
      array_endUse << end_use
      # loop through fuels
      total_end_use = 0.0
      fuel_types.each do |fuel_type|
        query_fuel = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='AnnualBuildingUtilityPerformanceSummary' and TableName='End Uses' and RowName= '#{end_use}' and ColumnName= '#{fuel_type}'"
        results_fuel = sqlFile.execAndReturnFirstDouble(query_fuel).get
        total_end_use += results_fuel
        array_endUse << results_fuel
      end
      array_endUse_all.push(array_endUse)
      endUse_summary_data_table[:data] << array_endUse
      array_endUse = []
    end

    #Get heating and cooling energy
    heating = []
    total_heating = 0.0
    cooling = []
    total_cooling = 0.0
    total_heating_kWh = 0.0
    total_cooling_kWh = 0.0
    array_endUse_all.each do |array|
      if array[0] == "Heating"
        heating = array.drop(1)
        total_heating = heating.sum
        total_heating_kWh = OpenStudio::convert(total_heating, "GJ", "kWh").get
      end

      if array[0] == "Cooling"
        cooling = array.drop(1)
        total_cooling = cooling.sum
        total_cooling_kWh = OpenStudio::convert(total_cooling, "GJ", "kWh").get
      end
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
      @totals << sum
    end
    @totals[0] = 'Total'
    endUse_summary_data_table[:data] << @totals

    # Get the electricity and naturalGas consumption , district heating and cooling
    electricity_consumption = @totals[1]
    gas_consumption = @totals[2]
    districtHeating = @totals[4]
    districtCooling = @totals[5]
    electricity_consumption_kWh = OpenStudio::convert(electricity_consumption, "GJ", "kWh").get
    gas_consumption_kWh = OpenStudio::convert(gas_consumption, "GJ", "kWh").get
    districtHeating_kWh = OpenStudio::convert(districtHeating, "GJ", "kWh").get
    districtCooling_kWh = OpenStudio::convert(districtCooling, "GJ", "kWh").get
    totalSiteEnergy_kWh = OpenStudio.convert(sqlFile.totalSiteEnergy.get, "GJ", "kWh").get

    #Calculate eui kWh/m2
    query_area = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='AnnualBuildingUtilityPerformanceSummary' and TableName='Building Area' and RowName= 'Total Building Area' and ColumnName= 'Area' and Units='m2'"
    area = sqlFile.execAndReturnFirstDouble(query_area).get
    eui_kWhPerm2 = totalSiteEnergy_kWh / area # kWh/m2

    runner.registerValue('heating', total_heating_kWh.round(2), 'kWh')
    runner.registerValue('cooling', total_cooling_kWh.round(2), 'kWh/m^2')
    runner.registerValue('electricity_consumption', electricity_consumption_kWh.round(2), 'kWh')
    runner.registerValue('natural_gas_consumption', gas_consumption_kWh.round(2), 'kWh')
    runner.registerValue('district_heating', districtHeating_kWh.round(2), 'kWh')
    runner.registerValue('district_cooling', districtCooling_kWh.round(2), 'kWh')
    runner.registerValue('total_site_eui', totalSiteEnergy_kWh.round(2), 'kWh')
    runner.registerValue('eui', eui_kWhPerm2.round(2), 'kW/m^2')

    # close the sql file
    sqlFile.close
    return true
  end
end

# register the measure to be used by the application
NrcReport.new.registerWithApplication
