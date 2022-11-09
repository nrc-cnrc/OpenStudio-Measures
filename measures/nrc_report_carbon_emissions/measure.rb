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

  #Adds helper functions to make life a bit easier and consistent.
  attr_accessor :use_json_package, :use_string_double
  include(NRCReportingMeasureHelper)

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
    return "This measure calculates the GHG emissions expressed in tonnes CO2eq based on Emission Factors from NIR reports and Energy Star Portfolio Manager. User can select emission factors before year 2019 from one of 3 NIR reports (2019, 2020 and 2021).
            Emission Factors from 2019 NIR reports are till 2017, Emission Factors from 2020 NIR reports are till 2018, and Emission Factors from 2019 NIR reports are till 2020.
            If the input argument 'Year' was selected equals to '2018' or '2019', and input argument 'NIR Report Year' was selected '2019' or '2020', Emission
            Factors will be calculated based on NIR Report '2021'
            Future GHG factors till 2050 are created by Environment and Climate Change Canada.
            The natural gas emission factors for each province are calculated by Environment and Climate Change Canada."
  end

  #################################
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
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => 'Nunavut',
        "choices" => ['Get From the Model', 'Canada', 'Newfoundland and Labrador', 'Prince Edward Island', 'Nova Scotia', 'New Brunswick', 'Quebec', 'Ontario', 'Manitoba',
                      'Saskatchewan', 'Alberta', 'British Columbia', 'Yukon', 'Northwest Territories', 'Nunavut'],
        "is_required" => true
      },
      {
        "name" => "year",
        "type" => "Choice",
        "display_name" => "Year",
        "default_value" => '2016',
        "choices" => ['1990', '2000', '2005', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035', '2036', '2037', '2038', '2099',
                      '2040', '2041', '2042', '2043', '2044', '2045', '2046', '2047', '2048', '2049', '2050'],
        "is_required" => true
      },
      {
        "name" => "nir_report_year",
        "type" => "Choice",
        "display_name" => "NIR Report Year",
        "default_value" => '2019',
        "choices" => ['2019', '2020', '2021'],
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
    result << 'ghg_NIR_summary_section'
    result << 'ghg_energyStar_summary_section'
    result << 'model_summary_section'
    result << 'emissionFactors_summary_section'
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
    model = runner.lastOpenStudioModel
    return result
  end

  def findProvince(loc)
    if loc == 'AB'
      province = 'Alberta'
    elsif loc == 'BC'
      province = 'British Columbia'
    elsif loc == 'MB'
      province = 'Manitoba'
    elsif loc == 'NB'
      province = 'New Brunswick'
    elsif loc == 'NL'
      province = 'Newfoundland and Labrador'
    elsif loc == 'NT'
      province = 'Northwest Territories'
    elsif loc == 'NS'
      province = 'Nova Scotia'
    elsif loc == 'NU'
      province = 'Nunavut'
    elsif loc == 'ON'
      province = 'Ontario'
    elsif loc == 'PE'
      province = 'Prince Edward Island'
    elsif loc == 'QC'
      province = 'Quebec'
    elsif loc == 'SK'
      province = 'Saskatchewan'
    elsif loc == 'YT'
      province = 'Yukon'
    end
    return province
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking (need model)
    if !runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    #get arguments
    location = runner.getStringArgumentValue("location", user_arguments)
    year = runner.getStringArgumentValue("year", user_arguments)
    nir_report_year = runner.getStringArgumentValue("nir_report_year", user_arguments)

    puts ">>>>> measure user_arguments #{user_arguments}"
    puts ">>>>>>>>>> location #{location}  year #{year}  nir_report_year #{nir_report_year} "
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
    location = runner.getStringArgumentValue('location', user_arguments)
    year = runner.getStringArgumentValue('year', user_arguments)
    year = year.to_i
    nir_report_year = nir_report_year.to_i

    #Convert variables to global variables to use them in the report
    #$year = year
    if location.include? "Get From the Model"
      loc = model.getWeatherFile.stateProvinceRegion
      location = findProvince(loc)
    end
    $location = location
    puts ">>>>> location #{location} "
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

    nir_files_path = File.expand_path("#{File.expand_path(__dir__)}/resources/")
=begin
    ##########################################################
    # Merge the 3 different json NIR files into one
    hash_arr = []
    files = Dir.entries(nir_files_path)
    files.each do |file_name|
      next unless ((File.extname(file_name) == '.json') and (file_name.include? "EmissionFactors_NIR"))
      path = File.expand_path("#{nir_files_path}/#{file_name}", __FILE__)
      all_nir_files = File.read(path)
      nir_data_hash = JSON.parse(all_nir_files)
      stored = {file_name.to_s => nir_data_hash}
      hash_arr << stored
  end

    File.open("#{nir_files_path}/all_nir_reports.json", "a") do |f|
      f.write(JSON.pretty_generate(hash_arr))
    end
=end




=begin

    # Find the electricity EF from the JSON file 'EmissionFactors.json'
    path = ''
    if nir_report_year == 2019
      path = File.expand_path('../resources/EmissionFactors_NIR2019.json', __FILE__)
    elsif nir_report_year == 2020
      path = File.expand_path('../resources/EmissionFactors_NIR2020.json', __FILE__)
    elsif nir_report_year == 2021
      path = File.expand_path('../resources/EmissionFactors_NIR2021.json', __FILE__)
    end
=end

    # NIR 2019 has EFs till 2017 only, so if year 2018 or 2019 is selected, the EF will be determined from NIR 2021

   if year <= 2019
     json_path = File.expand_path("#{nir_files_path}/all_nir_reports.json", __FILE__)

     allEmissionFactorsFile1 = File.read(json_path)
     data_hash = JSON.parse(allEmissionFactorsFile1)
     data_hash.each do |key, value|
       key.each do |k, v|
         if k.include? nir_report_year.to_s
           #  If the input argument 'Year' was selected equals to '2018' or '2019', and input argument 'NIR Report Year' was selected '2019' or '2020', Emission
           #  Factors will be calculated based on NIR Report '2021'
           puts "Working on NIR report : ".green + "#{k}".light_blue
           v.each do |k1, v1|
             k1.each do |loc, value|
               if loc == location
                 $electricity_EF = value[year.to_s]
                 puts "The EF for ".green + " #{loc}".light_blue + " is".green + " #{$electricity_EF}".light_blue
                 break
               end
             end
           end
         end
       end
     end

     else
      path = File.expand_path('../resources/ProjectionFactors.json', __FILE__)
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
    end



    $year = year
    $nir_report_year = nir_report_year

    puts "Year :".green + "#{year}".light_blue + "  NIR report year : ".green + " #{$nir_report_year}".light_blue + "  $electricity_EF".green + " #{$electricity_EF}".light_blue + " location".green + " #{location} ".light_blue

    puts ">>>>>> $electricity_EF #{$electricity_EF}"
    puts ">>>>>> $electricity_EF #{$naturalGas_EF}"
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
    @sections << ordered_section[2]
    @sections << ordered_section[3]
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
    html_out_path = "./#{@test_dir}/report.html"
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

    # Finally update the output variables
    runner.registerValue('co_2_e', $co_total.round(2), 'tCO2eq')

    return true
  end
end

# register the measure to be used by the application
NrcReportCarbonEmissions.new.registerWithApplication
