# Start the measure
require 'openstudio-standards'
require_relative 'resources/NRCMeasureHelper'

class NrcCreateNECBPrototypeBuilding < OpenStudio::Measure::ModelMeasure

  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)
  # Define the name of the Measure.
  def name
    return 'NrcCreateNECBPrototypeBuilding'
  end

  # Human readable description
  def description
    return 'This measure creates an NECB prototype building from scratch and uses it as the base for an analysis.'
  end

  # Human readable description of modeling approach
  def modeler_description
    return 'This will replace the model object with a brand new model. It effectively ignores the seed model. If there are 
	updated tables/formulas to those in the standard they can be sideloaded into the standard definition - this new data will
	then be used to create the model.'
  end

  # Use the constructor to set global variables.
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false

    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    #@use_string_double = true
    @use_string_double = false

    # Make an argument for the building type
    building_type_chs = OpenStudio::StringVector.new
    building_type_chs << 'SecondarySchool'
    building_type_chs << 'PrimarySchool'
    building_type_chs << 'SmallOffice'
    building_type_chs << 'MediumOffice'
    building_type_chs << 'LargeOffice'
    building_type_chs << 'SmallHotel'
    building_type_chs << 'LargeHotel'
    building_type_chs << 'Warehouse'
    building_type_chs << 'RetailStandalone'
    building_type_chs << 'RetailStripmall'
    building_type_chs << 'QuickServiceRestaurant'
    building_type_chs << 'FullServiceRestaurant'
    building_type_chs << 'MidriseApartment'
    building_type_chs << 'HighriseApartment'
    building_type_chs << 'Hospital'
    building_type_chs << 'Outpatient'

    # Choice vector of locations.
    location_choice = OpenStudio::StringVector.new
    location_choice << 'AB_Calgary'
    location_choice << 'AB_Edmonton'
    location_choice << 'AB_Fort.McMurray'
    location_choice << 'BC_Kelowna'
    location_choice << 'BC_Vancouver'
    location_choice << 'BC_Victoria'
    location_choice << 'MB_Thompson'
    location_choice << 'MB_Winnipeg'
    location_choice << 'NB_Moncton'
    location_choice << 'NB_Saint.John'
    location_choice << 'NL_Corner.Brook'
    location_choice << 'NL_St.Johns'
    location_choice << 'NS_Halifax.Dockyard'
    location_choice << 'NS_Sydney'
    location_choice << 'NT_Inuvik'
    location_choice << 'NT_Yellowknife'
    location_choice << 'NU_Cambridge.Bay'
    location_choice << 'NU_Iqaluit'
    location_choice << 'NU_Rankin.Inlet'
    location_choice << 'ON_Ottawa'
    location_choice << 'ON_Sudbury'
    location_choice << 'ON_Toronto'
    location_choice << 'ON_Windsor'
    location_choice << 'PE_Charlottetown'
    location_choice << 'QC_Jonquiere'
    location_choice << 'QC_Montreal'
    location_choice << 'QC_Quebec'
    location_choice << 'SK_Prince.Albert'
    location_choice << 'SK_Regina'
    location_choice << 'SK_Saskatoon'
    location_choice << 'YT_Dawson.City'
    location_choice << 'YT_Whitehorse'

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "template",
        "type" => "Choice",
        "display_name" => "Template",
        "default_value" => "NECB2017",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020"],
        "is_required" => true
      },
      {
        "name" => "building_type",
        "type" => "Choice",
        "display_name" => "Building Type",
        "default_value" => "Warehouse",
        "choices" => building_type_chs,
        "is_required" => true
      },
      {
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "AB_Calgary",
        "choices" => location_choice,
        "is_required" => true
      },
      {
        "name" => "weather_file_type",
        "type" => "Choice",
        "display_name" => "Weather file type",
        "default_value" => "CWEC2020",
        "choices" => ["CWEC2016", "CWEC2020", "TMY", "TRY-average", "TRY-warm", "TRY-cold"],
        "is_required" => true
      },
      {
        "name" => "global_warming",
        "type" => "Choice",
        "display_name" => "Degree of global warming (for TMY/TRY options)",
        "default_value" => "0.0",
        "choices" => ["0.0", "3.0"],
        "is_required" => true
      },
      {
        "name" => "sideload",
        "type" => "Bool",
        "display_name" => "Check for sideload files (to overwrite standards info)?",
        "default_value" => false,
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run.
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)
    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    building_type = arguments['building_type']
    template = arguments['template']
    location = arguments['location']
    weather_file_type = arguments['weather_file_type']
    global_warming = arguments['global_warming']
    sideload = arguments['sideload']

    # Map arguments to an epw filename.
    epw_file = "CAN_#{location}"
    case weather_file_type
    when "CWEC2016"
      epw_file << "-CWEC2016"
    when "CWEC2020"
      epw_file << "-CWEC2020"
    when "TMY"
      epw_file << "-TMY"
    when "TRY-average"
      epw_file << "-TRY_AvgTemp"
    when "TRY-warm"
      epw_file << "-TRY_MaxTemp"
    when "TRY-cold"
      epw_file << "-TRY_MinTemp"
    end

    if ["TMY", "TRY"].any? {|txt| weather_file_type.include? txt} then
      case global_warming
      when "0.0"
        epw_file << "_GW0.0"
      when "3.0"
        epw_file << "_GW3.0"
      end
    end
    epw_file << ".epw"

    # Debugging.
    puts "  Weather file: ".green + " #{epw_file}".yellow
    #epw_file_test = "/var/gems/openstudio-standards/data/weather/#{epw_file}"
    #puts "  Weather file status: ".green + " #{File.exists?(epw_file_test)}".yellow
    #epwfile = OpenStudio::EpwFile.new(epw_file_test)

    # Turn debugging output on/off
    @debug = false

    # Open a channel to log info/warning/error messages
    @msg_log = OpenStudio::StringStreamLogSink.new
    if @debug
      @msg_log.setLogLevel(OpenStudio::Debug)
    else
      @msg_log.setLogLevel(OpenStudio::Info)
    end
    @start_time = Time.new
    @runner = runner

    # Create model
    building_name = "#{template}_#{building_type}"
    puts "Creating #{building_name}"
    standard = Standard.build(template)

    # Side load json files into standard.
    if sideload then
      json_sideload(standard)
    end

    # Create prototype model and update to follow standard rules (plus any sideload).
    sizing_folder = NRCMeasureTestHelper.outputFolder(arguments)
    puts "sizing run folder: #{sizing_folder}".yellow
    new_model = standard.model_create_prototype_model(template: template,
                                                      building_type: building_type,
                                                      epw_file: epw_file,
                                                      sizing_run_dir: sizing_folder)
    standard.model_replace_model(model, new_model)
    
    # Commented out as fails for testing in parallel (its an openstudio issue).
    #log_msgs
    return true
  end

  #end the run method

  # Get all the log messages and put into output
  # for users to see.
  def log_msgs
    @msg_log.logMessages.each do |msg|
      # DLM: you can filter on log channel here for now
      if /openstudio.*/.match(msg.logChannel) #/openstudio\.model\..*/
        # Skip certain messages that are irrelevant/misleading
        next if msg.logMessage.include?("Skipping layer") || # Annoying/bogus "Skipping layer" warnings
          msg.logChannel.include?("runmanager") || # RunManager messages
          msg.logChannel.include?("setFileExtension") || # .ddy extension unexpected
          msg.logChannel.include?("Translator") || # Forward translator and geometry translator
          msg.logMessage.include?("UseWeatherFile") # 'UseWeatherFile' is not yet a supported option for YearDescription

        # Report the message in the correct way
        if msg.logLevel == OpenStudio::Info
          @runner.registerInfo(msg.logMessage)
        elsif msg.logLevel == OpenStudio::Warn
          @runner.registerWarning("[#{msg.logChannel}] #{msg.logMessage}")
        elsif msg.logLevel == OpenStudio::Error
          @runner.registerError("[#{msg.logChannel}] #{msg.logMessage}")
        elsif msg.logLevel == OpenStudio::Debug && @debug
          @runner.registerInfo("DEBUG - #{msg.logMessage}")
        end
      end
    end
    @runner.registerInfo("Total Time = #{(Time.new - @start_time).round}sec.")
  end

  # Check for sideload files and update standards tables etc.
  def json_sideload(standard)
    path = "#{File.dirname(__FILE__)}/resources/data_sideload"
    raise ('Could not find data_sideload folder') unless Dir.exist?(path)
    files = Dir.glob("#{path}/*.json").select { |e| File.file? e }
    files.each do |file|
      @runner.registerInfo("Reading side load file: #{file}")
      data = JSON.parse(File.read(file))
      if not data["tables"].nil?
        data['tables'].keys.each do |table|
          @runner.registerInfo("Updating standard table: #{table}")
          @runner.registerInfo("Existing data: #{standard.standards_data[table]}")
          @runner.registerInfo("Replacement data: #{data['tables'][table]}")
        end
        standard.standards_data["tables"] = [*standard.standards_data["tables"], *data["tables"]].to_h
        standard.corrupt_standards_database
        data['tables'].keys.each do |table|
          @runner.registerInfo("Table: #{table}")
          @runner.registerInfo("Updated data: #{standard.standards_data[table]}")
        end
      elsif not data["formulas"].nil?
        data['formulas'].keys.each do |formula|
          @runner.registerInfo("Updating standard formula: #{formula}")
          @runner.registerInfo("Existing data   : #{standard.get_standards_formula(formula)}")
          @runner.registerInfo("Replacement data: #{data['formulas'][formula]['value']}")
        end
        standard.standards_data["formulas"] = [*standard.standards_data["formulas"], *data["formulas"]].to_h
        standard.corrupt_standards_database
        data['formulas'].keys.each do |formula|
          @runner.registerInfo("Formula: #{formula}")
          @runner.registerInfo("Updated data    : #{standard.get_standards_formula(formula)}")
        end
      else
        #standard.standards_data[data.keys.first] = data[data.keys.first]
      end
      @runner.registerWarning("Replaced default standard data with contents in #{file}")
    end
    return standard
  end

end

#end the measure

#this allows the measure to be use by the application
NrcCreateNECBPrototypeBuilding.new.registerWithApplication