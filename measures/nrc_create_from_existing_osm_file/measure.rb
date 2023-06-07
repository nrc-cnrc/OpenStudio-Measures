require_relative 'resources/NRCMeasureHelper'
require 'openstudio-standards'
# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# Start the measure
class NrcCreateFromExistingOsmFile < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # Create an array for all the osm files in the "input_osm_files" folder
  $all_osm_files = []
  # Human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'NRC Create From Existing Osm File'
  end

  # Human readable description
  def description
    return "The measure searches a folder for a user defined osm file name and updates version of code"
  end

  # Human readable description of modeling approach
  def modeler_description
    return "The measure searches a folder (input_osm_files) in the measure folder for a user defined osm file name.
            There's a Boolean option to update version of code, If the Bool is true then user can select one of 4 options of the code version. Options are: NECB 2011, 2015, 2017 and 2020"
  end

  # Search for all osm files in the "input_osm_files" folder and add them to an array.
  def find_osm_files
    osm_files_path = File.expand_path("#{File.expand_path(__dir__)}/input_osm_files/")
    files = Dir.entries(osm_files_path)
    files.each do |file_name|
      next unless File.extname(file_name) == '.osm'
      $all_osm_files.push(file_name.to_s) unless $all_osm_files.include?(file_name.to_s)
    end
    return $all_osm_files
  end

  # Use the constructor to set global variables
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
        "name" => "necb_template",
        "type" => "Choice",
        "display_name" => "Building vintage",
        "default_value" => "NECB2020",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020", "BTAPPRE1980", "BTAP1980TO2010"],
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run
  def run(model, runner, user_arguments)

    # Runs parent run method.
    super(model, runner, user_arguments)

    @runner = runner
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    upload_osm_file = arguments['upload_osm_file']
    update_code_version = arguments['update_code_version']
    template = arguments['necb_template']

    # Report the initial template for the uploaded model
    initial_template = model.getBuilding.standardsTemplate
    runner.registerInitialCondition("Uploaded model had initial template :".green + " #{initial_template}".light_blue)

    puts "Upload_osm_file".green + " #{upload_osm_file}".light_blue
    puts "Update_code_version".green + " #{update_code_version}".light_blue
    puts "Template".green + " #{template}".light_blue
    puts "List of all OSM files:".green + " #{$all_osm_files}".light_blue

    # Load osm file.
    translator = OpenStudio::OSVersion::VersionTranslator.new
    osm_file_path = File.expand_path("#{File.expand_path(__dir__)}/input_osm_files/#{upload_osm_file}")
    new_model = translator.loadModel(osm_file_path.to_s).get
    standard = Standard.build(template)
    standard.model_replace_model(model, new_model)

    if update_code_version
      puts "Updating code version to ".green + "#{template}".light_blue

      # Get the weather file from the model
      weatherFile_path = model.weatherFile.get.path.get #./weather/CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw
      epw_file = weatherFile_path.to_s.split('/')[2] #CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw

      # Apply standards ruleset to model.
      sizing_folder = NRCMeasureTestHelper.outputFolder(arguments)
      updated_model = standard.model_apply_standard(model: model,
                                                    epw_file: epw_file,
                                                    sizing_run_dir: sizing_folder)

      # Set building name.
      building = updated_model.getBuilding
      building_type = building.standardsBuildingType
      puts "Building_type".green + " #{building_type}".light_blue
      building_name = ("#{building_type}_#{template}")
      building.setName(building_name)
      runner.registerFinalCondition("Model's template has changed to: ".green + "#{template}".light_blue)
    end
    return true
  end
end

# Register the measure to be used by the application
NrcCreateFromExistingOsmFile.new.registerWithApplication
