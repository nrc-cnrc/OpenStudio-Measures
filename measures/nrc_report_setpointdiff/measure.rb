# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'openstudio-standards'
require "#{File.dirname(__FILE__)}/resources/os_lib_reporting"
require "#{File.dirname(__FILE__)}/resources/os_lib_schedules"
require "#{File.dirname(__FILE__)}/resources/os_lib_helper_methods"
require_relative 'resources/NRCReportingMeasureHelper'

require 'erb'
require 'json'
require 'zlib'
require 'base64'

#require 'bundler/inline'

# start the measure
class NrcReportSetPointDiff < OpenStudio::Measure::ReportingMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCReportingMeasureHelper)

  def name
    return "NrcReportSetPointDiff"
  end

  # Human readable description.
  def description
    return "This measure reports statistics on how well the model has controlled to the various set points."
  end

  # Human readable description of modeling approach.
  def modeler_description
    return "The measure scans through the models for set points. For each location found the results of the controlled variable are saved.
	The measure then calculates, on an hourly basis, deviations from the set point."
  end

  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false
    @measure_interface_detailed = [
      {
        "name" => "timeStep",
        "type" => "Choice",
        "display_name" => "Time Step",
        "default_value" => "Hourly",
        "choices" => ["Hourly", "Daily", "Zone Timestep"],
        "is_required" => true
      },
      {
        "name" => "detail",
        "type" => "Choice",
        "display_name" => "Create detailed hourly Excel files?",
        "default_value" => "Yes",
        "choices" => ["Yes", "No"],
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
    result << 'temperature_detailed_section'
    result << 'temp_diff_summary_section'
    result
  end

  # Return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # Warning: Do not change the name of this method to be snake_case. The method must be lowerCamelCase.
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return result
    end

    model = runner.lastOpenStudioModel

    # Parse the model for setpoints and add to  the requested outputs.
    if not model.empty? then
      model = model.get
      setPoints = model.getSetpointManagers
      runner.registerInfo("Setpoints object count: #{setPoints.size}".red)
      setPoints.each do |setPoint|
        runner.registerInfo("#{setPoint.controlVariable}".light_blue)
        runner.registerInfo("#{setPoint.setpointNode.get.name}".light_blue)
        variable = setPoint.controlVariable
        node = setPoint.setpointNode.get.name
        result << OpenStudio::IdfObject.load("Output:Variable,#{node},System Node #{variable},Hourly;").get
        result << OpenStudio::IdfObject.load("Output:Variable,#{node},System Node Setpoint #{variable},Hourly;").get
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

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    #get arguments
    $timeStep = runner.getStringArgumentValue("timeStep", user_arguments)
    $detail = runner.getStringArgumentValue("detail", user_arguments)

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
    @sections << ordered_section[2]
    @sections << ordered_section[1] unless $detail != "Yes"

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
NrcReportSetPointDiff.new.registerWithApplication

