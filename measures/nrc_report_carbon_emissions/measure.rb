# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require 'openstudio-standards'
require_relative 'resources/NRCReportingMeasureHelper'
require "#{File.dirname(__FILE__)}/resources/os_lib_reporting"
require "#{File.dirname(__FILE__)}/resources/os_lib_helper_methods"

require 'erb'
require 'json'
require 'zlib'
require 'base64'

# Keep track of the total CO2e value. This is a hack with a global variable.
$co_total = 0.0
$electricity_EF = 0.0
$naturalGas_EF = 0.0

# start the measure
class NrcReportCarbonEmissions < OpenStudio::Measure::ReportingMeasure

  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NrcReportCarbonEmissions'
  end

  # human readable description
  def description
    return 'This reporting measure calculates the annual greenhouse gas emissions.'
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure calculates the GHG emissions expressed in tonnes CO2eq. Annual electricity intensity factors before year 2019 are defined in 'NATIONAL INVENTORY REPORT 1990 2018: GREENHOUSE GAS SOURCES AND SINKS IN CANADA CANADA’S SUBMISSION TO
            THE UNITED NATIONS FRAMEWORK CONVENTION ON CLIMATE CHANGE(http://publications.gc.ca/collections/collection_2020/eccc/En81-4-2018-3-eng.pdf)'.
            Whereas annual electricity intensity factors after year 2019 and also future GHG factors till 2050 are created by Environment and Climate Change Canada.
            There are no electricity emission factors for Nunavut for the following years : 1990, 2000, and 2005.
            The natural gas emission factors for each province are calculated by Environment and Climate Change Canada."
  end

  # define the arguments that the user will input
  def arguments(model = nil)
    args = OpenStudio::Measure::OSArgumentVector.new

    # make choice argument for location
    choices = OpenStudio::StringVector.new
    choices << 'Canada'
    choices << 'Newfoundland and Labrador'
    choices << 'Prince Edward Island'
    choices << 'Nova Scotia'
    choices << 'New Brunswick'
    choices << 'Quebec'
    choices << 'Ontario'
    choices << 'Manitoba'
    choices << 'Saskatchewan'
    choices << 'Alberta'
    choices << 'British Columbia'
    choices << 'Yukon'
    choices << 'Northwest Territories'
    choices << 'Nunavut'
    location = OpenStudio::Measure::OSArgument.makeChoiceArgument('location', choices)
    location.setDisplayName('Location')
    location.setDefaultValue('Ontario')
    args << location

    # make choice argument for year
    choices = OpenStudio::StringVector.new
    choices << '1990'
    choices << '2000'
    choices << '2005'
    choices << '2013'
    choices << '2014'
    choices << '2015'
    choices << '2016'
    choices << '2017'
    choices << '2018'
    choices << '2019'
    choices << '2020'
    choices << '2021'
    choices << '2022'
    choices << '2023'
    choices << '2024'
    choices << '2025'
    choices << '2026'
    choices << '2027'
    choices << '2028'
    choices << '2029'
    choices << '2030'
    choices << '2031'
    choices << '2032'
    choices << '2033'
    choices << '2034'
    choices << '2035'
    choices << '2036'
    choices << '2037'
    choices << '2038'
    choices << '2099'
    choices << '2040'
    choices << '2041'
    choices << '2042'
    choices << '2043'
    choices << '2044'
    choices << '2045'
    choices << '2046'
    choices << '2047'
    choices << '2048'
    choices << '2049'
    choices << '2050'
    year = OpenStudio::Measure::OSArgument.makeChoiceArgument('year', choices)
    year.setDisplayName('Year')
    year.setDefaultValue('2037')
    args << year

    # populate arguments
    possible_sections.each do |method_name|
      # get display name
      arg = OpenStudio::Measure::OSArgument.makeBoolArgument(method_name, true)
      display_name = "#{method_name}"
      arg.setDisplayName(display_name)
      arg.setDefaultValue(true)
      args << arg
    end
    args
  end

  def possible_sections
    result = []
    # methods for sections in order that they will appear in report
    result << 'model_summary_section'
    result << 'endUse_summary_section'
    result
  end

  # define the outputs that the measure will create
  def outputs
    result = OpenStudio::Measure::OSOutputVector.new
    result << OpenStudio::Measure::OSOutput.makeDoubleOutput('co_2_e') # tCO2e
    return result
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

    return result
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking (need model)
    if !runner.validateUserArguments(arguments, user_arguments)
      return false
    end
    # assign the user inputs to variables
    location = runner.getStringArgumentValue('location', user_arguments)
    year = runner.getStringArgumentValue('year', user_arguments)
    year = year.to_i

    #Convert variables to global variables to use them in the report
    $year = year
    $location = location

    # Get the natural gas EF from the JSON file 'NG_EFs.json'
    ng_path = File.expand_path('../resources/NG_EFs.json', __FILE__)
    ng_emissionFactorsFile = File.read(ng_path)
    ng_data_hash = JSON.parse(ng_emissionFactorsFile)
    ng_data_hash.each do |k, v|
      k.each do |k1, v1|
        if k1 == location
          $naturalGas_EF = v1['kg CO2e/GJ']
          break
        end
      end
    end

    # Find the electricity EF from the JSON file 'EmissionFactors.json'
    path = File.expand_path('../resources/EmissionFactors.json', __FILE__)
    allEmissionFactorsFile = File.read(path)
    data_hash = JSON.parse(allEmissionFactorsFile)
    data_hash.each do |k, v|
      # all locations
      k.each do |k1, v1|
        if k1 == location
          $electricity_EF = v1[year.to_s]
        end
      end
    end

    # get sql, model, and web assets
    setup = OsLib_Reporting.setup(runner)
    unless setup
      return false
    end
    model = setup[:model]
    # workspace = setup[:workspace]
    sql_file = setup[:sqlFile]
    web_asset_path = setup[:web_asset_path]

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
        eval("section = OsLib_Reporting.#{method_name}(model,sql_file,runner,false)")
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
    sql_file.close

    # Finally update the output variables
    runner.registerValue('co_2_e', $co_total.round(2), 'tCO2eq')

    return true
  end
end

# register the measure to be used by the application
NrcReportCarbonEmissions.new.registerWithApplication
