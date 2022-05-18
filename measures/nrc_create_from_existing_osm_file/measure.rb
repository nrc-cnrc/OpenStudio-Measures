require_relative 'resources/NRCMeasureHelper'
require 'openstudio-standards'
# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class NrcCreateFromExistingOsmFile < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  $all_osm_files = []
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NRC Create From Existing Osm File'
  end

  # human readable description
  def description
    return "The measure searches a folder for a user defined osm file name and updates version of code"
  end

  # human readable description of modeling approach
  def modeler_description
    return "The measure searches a folder (input_osm_files) in the measure folder for a user defined osm file name.
            There's a Boolean option to update to match version of code, If the bool is true then user can select one of 4 options of the code version. Options: NECB 2011, 2015, 2017 and 2020"
  end

  # Search for all osm files in the "input_osm_files" folder and add them to an array
  def find_osm_files
    osm_files_path = File.expand_path("#{File.expand_path(__dir__)}/input_osm_files/")
    files = Dir.entries(osm_files_path)
    files.each do |file_name|
      next unless File.extname(file_name) == '.osm'
      $all_osm_files.push(file_name.to_s) unless $all_osm_files.include?(file_name.to_s)
    end
    return $all_osm_files
  end


  #Use the constructor to set global variables
  def initialize()
    super()
    find_osm_files()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false

    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "upload_osm_file",
        "type" => "Choice",
        "display_name" => "Upload OSM File",
        "default_value" => $all_osm_files[0],
        "choices" => $all_osm_files,
        "is_required" => true
      },
      {
        "name" => "update_code_version",
        "type" => "Bool",
        "display_name" => "Update to match version of code?",
        "default_value" => true,
        "is_required" => true
      },
      {
        "name" => "template",
        "type" => "Choice",
        "display_name" => "template",
        "default_value" => "NECB2017",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020"],
        "is_required" => true
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    #Runs parent run method.
    super(model, runner, user_arguments)

    @runner = runner
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    upload_osm_file = arguments['upload_osm_file']
    update_code_version = arguments['update_code_version']
    template = arguments['template']

    puts "Upload_osm_file".green + " #{upload_osm_file}".light_blue
    puts "Update_code_version".green + " #{update_code_version}".light_blue
    puts "Template".green + " #{template}".light_blue

    puts "List of all OSM files:".green + " #{$all_osm_files}".light_blue

    # Load osm file
    translator = OpenStudio::OSVersion::VersionTranslator.new
    osm_file_path = File.expand_path("#{File.expand_path(__dir__)}/input_osm_files/#{upload_osm_file}")
    model = translator.loadModel(osm_file_path)

    if !model.empty?
      puts "Loading model at :".green + " #{osm_file_path}".light_blue
    else
      puts "Couldn't load the model".red
    end
    model = model.get
    if update_code_version
      puts "Updating code version to ".green + "#{template}".light_blue
      model = update_code_template(template, model)
      # Set building name
      building = model.getBuilding
      building_type = building.standardsBuildingType
      puts "Building_type".green + " #{building_type}".light_blue
      building_name = ("#{building_type}_#{template}")
      building.setName(building_name)
      # Save the model to test output directory
      output_path = "outputMeasure_file_path/test_output_#{template}.osm"
    else
      # If user selected not to update_code_version, then get the template from the model itself
      template = model.getBuilding.standardsTemplate
      # Save the model to test output directory
      output_path = "output_file_path/test_output_#{template}.osm"
    end
    model.save(output_path, true)
    return true
  end

  # Update the Standards with the code version
  def update_code_template(template, model)
    # Define version of NECB to use
    standard = Standard.build(template)
    # Get the weather file from the model
    weatherFile_path = model.weatherFile.get.path.get #./weather/CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw
    epw_file = weatherFile_path.to_s.split('/')[2] #CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw

    # Apply standards ruleset to model
    model = standard.model_apply_standard(model: model,
                                          epw_file: epw_file,
                                          sizing_run_dir: Dir.pwd)

    return model
  end

end

# register the measure to be used by the application
NrcCreateFromExistingOsmFile.new.registerWithApplication
