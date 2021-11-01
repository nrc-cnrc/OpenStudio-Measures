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
	then be used to create the model.
'
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

    #Drop down selector for Canadian weather files.
    epw_files_chs = OpenStudio::StringVector.new
    ['AB_Banff',
     'AB_Calgary',
     'AB_Edmonton.Intl',
     'AB_Edmonton.Stony.Plain',
     'AB_Fort.McMurray',
     'AB_Grande.Prairie',
     'AB_Lethbridge',
     'AB_Medicine.Hat',
     'BC_Abbotsford',
     'BC_Comox.Valley',
     'BC_Crankbrook-Canadian.Rockies',
     'BC_Fort.St.John-North.Peace',
     'BC_Hope',
     'BC_Kamloops',
     'BC_Port.Hardy',
     'BC_Prince.George',
     'BC_Smithers',
     'BC_Summerland',
     'BC_Vancouver',
     'BC_Victoria',
     'MB_Brandon.Muni',
     'MB_The.Pas',
     'MB_Winnipeg-Richardson',
     'NB_Fredericton',
     'NB_Miramichi',
     'NB_Saint.John',
     'NL_Gander',
     'NL_Goose.Bay',
     'NL_St.Johns',
     'NL_Stephenville',
     'NS_CFB.Greenwood',
     'NS_CFB.Shearwater',
     'NS_Halifax',
     'NS_Sable.Island.Natl.Park',
     'NS_Sydney-McCurdy',
     'NS_Truro',
     'NS_Yarmouth',
     'NT_Inuvik-Zubko',
     'NT_Yellowknife',
     'ON_Armstrong',
     'ON_CFB.Trenton',
     'ON_Dryden',
     'ON_London',
     'ON_Moosonee',
     'ON_Mount.Forest',
     'ON_North.Bay-Garland',
     'ON_Ottawa',
     'ON_Sault.Ste.Marie',
     'ON_Timmins.Power',
     'ON_Toronto',
     'ON_Windsor',
     'PE_Charlottetown',
     'QC_Kuujjuaq',
     'QC_Kuujuarapik',
     'QC_Lac.Eon',
     'QC_Mont-Joli',
     'QC_Montreal-Mirabel',
     'QC_Montreal-St-Hubert.Longueuil',
     'QC_Montreal-Trudeau',
     'QC_Quebec',
     'QC_Riviere-du-Loup',
     'QC_Roberval',
     'QC_Saguenay-Bagotville',
     'QC_Schefferville',
     'QC_Sept-Iles',
     'QC_Val-d-Or',
     'SK_Estevan',
     'SK_North.Battleford',
     'SK_Saskatoon',
     'YT_Whitehorse'].each do |epw_file|
      epw_files_chs << epw_file
    end

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
        "name" => "epw_file",
        "type" => "Choice",
        "display_name" => "Climate File",
        "default_value" => "AB_Banff",
        "choices" => epw_files_chs,
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
    # return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    building_type = arguments['building_type']
    template = arguments['template']
    epw_file1 = arguments['epw_file']
    sideload = arguments['sideload']
    epw_file = find_epwFile(epw_file1)

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
    new_model = standard.model_create_prototype_model(template: template,
                                                      building_type: building_type,
                                                      epw_file: epw_file,
                                                      sizing_run_dir: NRCMeasureTestHelper.outputFolder)
    standard.model_replace_model(model, new_model)
    log_msgs
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

  def find_epwFile(epw_file1)
    if epw_file1 == 'AB_Banff'
      epw_file = 'CAN_AB_Banff.CS.711220_CWEC2016.epw'
    elsif epw_file1 == 'AB_Calgary'
      epw_file = 'CAN_AB_Calgary.Intl.AP.718770_CWEC2016.epw'
    elsif epw_file1 == 'AB_Edmonton.Intl'
      epw_file = 'CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw'
    elsif epw_file1 == 'AB_Edmonton.Stony.Plain'
      epw_file = 'CAN_AB_Edmonton.Stony.Plain.AP.711270_CWEC2016.epw'
    elsif epw_file1 == 'AB_Fort.McMurray'
      epw_file = 'CAN_AB_Fort.McMurray.AP.716890_CWEC2016.epw'
    elsif epw_file1 == 'AB_Grande.Prairie'
      epw_file = 'CAN_AB_Grande.Prairie.AP.719400_CWEC2016.epw'
    elsif epw_file1 == 'AB_Lethbridge'
      epw_file = 'CAN_AB_Lethbridge.AP.712430_CWEC2016.epw'
    elsif epw_file1 == 'AB_Medicine.Hat'
      epw_file = 'CAN_AB_Medicine.Hat.AP.710260_CWEC2016.epw'
    elsif epw_file1 == 'BC_Abbotsford'
      epw_file = 'CAN_BC_Abbotsford.Intl.AP.711080_CWEC2016.epw'
    elsif epw_file1 == 'BC_Comox.Valley'
      epw_file = 'CAN_BC_Comox.Valley.AP.718930_CWEC2016.epw'
    elsif epw_file1 == 'BC_Crankbrook-Canadian.Rockies'
      epw_file = 'CAN_BC_Crankbrook-Canadian.Rockies.Intl.AP.718800_CWEC2016.epw'
    elsif epw_file1 == 'BC_Fort.St.John-North.Peace'
      epw_file = 'CAN_BC_Fort.St.John-North.Peace.Rgnl.AP.719430_CWEC2016.epw'
    elsif epw_file1 == 'BC_Hope'
      epw_file = 'CAN_BC_Hope.Rgnl.Airpark.711870_CWEC2016.epw'
    elsif epw_file1 == 'BC_Kamloops'
      epw_file = 'CAN_BC_Kamloops.AP.718870_CWEC2016.epw'
    elsif epw_file1 == 'BC_Port.Hardy'
      epw_file = 'CAN_BC_Port.Hardy.AP.711090_CWEC2016.epw'
    elsif epw_file1 == 'BC_Prince.George'
      epw_file = 'CAN_BC_Prince.George.Intl.AP.718960_CWEC2016.epw'
    elsif epw_file1 == 'BC_Smithers'
      epw_file = 'CAN_BC_Smithers.Rgnl.AP.719500_CWEC2016.epw'
    elsif epw_file1 == 'BC_Summerland'
      epw_file = 'CAN_BC_Summerland.717680_CWEC2016.epw'
    elsif epw_file1 == 'BC_Vancouver'
      epw_file = 'CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw'
    elsif epw_file1 == 'BC_Victoria'
      epw_file = 'CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw'
    elsif epw_file1 == 'MB_Brandon.Muni'
      epw_file = 'CAN_MB_Brandon.Muni.AP.711400_CWEC2016.epw'
    elsif epw_file1 == 'MB_The.Pas'
      epw_file = 'CAN_MB_The.Pas.AP.718670_CWEC2016.epw'
    elsif epw_file1 == 'MB_Winnipeg-Richardson'
      epw_file = 'CAN_MB_Winnipeg-Richardson.Intl.AP.718520_CWEC2016.epw'
    elsif epw_file1 == 'NB_Fredericton'
      epw_file = 'CAN_NB_Fredericton.Intl.AP.717000_CWEC2016.epw'
    elsif epw_file1 == 'NB_Miramichi'
      epw_file = 'CAN_NB_Miramichi.AP.717440_CWEC2016.epw'
    elsif epw_file1 == 'NB_Saint.John'
      epw_file = 'CAN_NB_Saint.John.AP.716090_CWEC2016.epw'
    elsif epw_file1 == 'NL_Gander'
      epw_file = 'CAN_NL_Gander.Intl.AP-CFB.Gander.718030_CWEC2016.epw'
    elsif epw_file1 == 'NL_Goose.Bay'
      epw_file = 'CAN_NL_Goose.Bay.AP-CFB.Goose.Bay.718160_CWEC2016.epw'
    elsif epw_file1 == 'NL_St.Johns'
      epw_file = 'CAN_NL_St.Johns.Intl.AP.718010_CWEC2016.epw'
    elsif epw_file1 == 'NL_Stephenville'
      epw_file = 'CAN_NL_Stephenville.Intl.AP.718150_CWEC2016.epw'
    elsif epw_file1 == 'NS_CFB.Greenwood'
      epw_file = 'CAN_NS_CFB.Greenwood.713970_CWEC2016.epw'
    elsif epw_file1 == 'NS_CFB.Shearwater'
      epw_file = 'CAN_NS_CFB.Shearwater.716010_CWEC2016.epw'
    elsif epw_file1 == 'NS_Halifax'
      epw_file = 'CAN_NS_Halifax.Dockyard.713280_CWEC2016.epw'
    elsif epw_file1 == 'NS_Sable.Island.Natl'
      epw_file = 'CAN_NS_Sable.Island.Natl.Park.716000_CWEC2016.epw'
    elsif epw_file1 == 'NS_Sydney-McCurdy'
      epw_file = 'CAN_NS_Sydney-McCurdy.AP.717070_CWEC2016.epw'
    elsif epw_file1 == 'NS_Truro'
      epw_file = 'CAN_NS_Truro.713980_CWEC.epw'
    elsif epw_file1 == 'NS_Yarmouth'
      epw_file = 'CAN_NS_Yarmouth.Intl.AP.716030_CWEC2016.epw'
    elsif epw_file1 == 'NT_Inuvik-Zubko'
      epw_file = 'CAN_NT_Inuvik-Zubko.AP.719570_CWEC2016.epw'
    elsif epw_file1 == 'NT_Yellowknife'
      epw_file = 'CAN_NT_Yellowknife.AP.719360_CWEC2016.epw'
    elsif epw_file1 == 'ON_Armstrong'
      epw_file = 'CAN_ON_Armstrong.AP.718410_CWEC2016.epw'
    elsif epw_file1 == 'ON_CFB.Trenton'
      epw_file = 'CAN_ON_CFB.Trenton.716210_CWEC2016.epw'
    elsif epw_file1 == 'ON_Dryden'
      epw_file = 'CAN_ON_Dryden.Rgnl.AP.715270_CWEC2016.epw'
    elsif epw_file1 == 'ON_London'
      epw_file = 'CAN_ON_London.Intl.AP.716230_CWEC2016.epw'
    elsif epw_file1 == 'ON_Moosonee'
      epw_file = 'CAN_ON_Moosonee.AP.713980_CWEC2016.epw'
    elsif epw_file1 == 'ON_Mount.Forest'
      epw_file = 'CAN_ON_Mount.Forest.716310_CWEC2016.epw'
    elsif epw_file1 == 'ON_North.Bay-Garland'
      epw_file = 'CAN_ON_North.Bay-Garland.AP.717310_CWEC2016.epw'
    elsif epw_file1 == 'ON_Ottawa'
      epw_file = 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw'
    elsif epw_file1 == 'ON_Sault.Ste.Marie'
      epw_file = 'CAN_ON_Sault.Ste.Marie.AP.712600_CWEC2016.epw'
    elsif epw_file1 == 'ON_Timmins.Power'
      epw_file = 'CAN_ON_Timmins.Power.AP.717390_CWEC2016.epw'
    elsif epw_file1 == 'ON_Toronto'
      epw_file = 'CAN_ON_Toronto.Pearson.Intl.AP.716240_CWEC2016.epw'
    elsif epw_file1 == 'ON_Windsor'
      epw_file = 'CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw'
    elsif epw_file1 == 'PE_Charlottetown'
      epw_file = 'CAN_PE_Charlottetown.AP.717060_CWEC2016.epw'
    elsif epw_file1 == 'QC_Kuujjuaq'
      epw_file = 'CAN_QC_Kuujjuaq.AP.719060_CWEC2016.epw'
    elsif epw_file1 == 'QC_Kuujuarapik'
      epw_file = 'CAN_QC_Kuujuarapik.AP.719050_CWEC2016.epw'
    elsif epw_file1 == 'QC_Lac.Eon'
      epw_file = 'CAN_QC_Lac.Eon.AP.714210_CWEC2016.epw'
    elsif epw_file1 == 'QC_Mont-Joli'
      epw_file = 'CAN_QC_Mont-Joli.AP.717180_CWEC2016.epw'
    elsif epw_file1 == 'QC_Montreal-Mirabel'
      epw_file = 'CAN_QC_Montreal-Mirabel.Intl.AP.719050_CWEC2016.epw'
    elsif epw_file1 == 'QC_Montreal-St-Hubert'
      epw_file = 'CAN_QC_Montreal-St-Hubert.Longueuil.AP.713710_CWEC2016.epw'
    elsif epw_file1 == 'QC_Montreal-Trudeau'
      epw_file = 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw'
    elsif epw_file1 == 'QC_Quebec'
      epw_file = 'CAN_QC_Quebec-Lesage.Intl.AP.717140_CWEC2016.epw'
    elsif epw_file1 == 'QC_Riviere-du-Loup'
      epw_file = 'CAN_QC_Riviere-du-Loup.717150_CWEC2016.epw'
    elsif epw_file1 == 'QC_Roberval'
      epw_file = 'CAN_QC_Roberval.AP.717280_CWEC2016.epw'
    elsif epw_file1 == 'QC_Saguenay-Bagotville'
      epw_file = 'CAN_QC_Saguenay-Bagotville.AP-CFB.Bagotville.717270_CWEC2016.epw'
    elsif epw_file1 == 'QC_Schefferville'
      epw_file = 'CAN_QC_Schefferville.AP.718280_CWEC2016.epw'
    elsif epw_file1 == 'QC_Sept-Iles'
      epw_file = 'CAN_QC_Sept-Iles.AP.718110_CWEC2016.epw'
    elsif epw_file1 == 'QC_Val-d-Or'
      epw_file = 'CAN_QC_Val-d-Or.Rgnl.AP.717250_CWEC2016.epw'
    elsif epw_file1 == 'SK_Estevan'
      epw_file = 'CAN_SK_Estevan.Rgnl.AP.718620_CWEC2016.epw'
    elsif epw_file1 == 'SK_North.Battleford'
      epw_file = 'CAN_SK_North.Battleford.AP.718760_CWEC2016.epw'
    elsif epw_file1 == 'SK_Saskatoon'
      epw_file = 'CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw'
    elsif epw_file1 == 'YT_Whitehorse'
      epw_file = 'CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw'
    end
    return epw_file
  end
end

#end the measure

#this allows the measure to be use by the application
NrcCreateNECBPrototypeBuilding.new.registerWithApplication
