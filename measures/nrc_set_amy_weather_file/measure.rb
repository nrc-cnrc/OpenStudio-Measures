# Start the measure
require 'openstudio-standards'
require_relative 'resources/NRCMeasureHelper'

class NrcSetAmyWeatherFile < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double

  #Adds helper functions to make life a bit easier and consistent.
  include(NRCMeasureHelper)

  # Define the name of the Measure.
  def name
    # Measure name should be the title case of the class name.
    return 'Nrc Set AMY Weather File'
  end

  # Human readable description
  def description
    return 'The measure sets an AMY weather file to a model and updates its calendar year.'
  end

  # Human readable description of modeling approach
  def modeler_description
    return 'The measure sets one of 3 hourly weather file locations. Locations options are: Ottawa, Toronto, and Windsor.
            Also sets the calendar year to the years related to the available hourly weather files (2016, 2017 and 2018). '
  end

  # Use the constructor to set global variables
  def initialize()
    super()

    #Set to true if you want to package the arguments as json.
    @use_json_package = false

    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    location_choice = OpenStudio::StringVector.new
    location_choice << 'ON_Ottawa'
    location_choice << 'ON_Toronto'
    location_choice << 'ON_Windsor'
    
    # Put in this array of hashes all the input variables that you need in your measure. Your choice of types are Sting, Double,
    # StringDouble, and Choice. Optional fields are valid strings, max_double_value, and min_double_value. This will
    # create all the variables, validate the ranges and types you need,  and make them available in the 'run' method as a hash after
    # you run 'arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)'
    @measure_interface_detailed = [
      {
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "ON_Toronto",
        "choices" => location_choice,
        "is_required" => true
      },
      {
        "name" => "year",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => "2016",
        "choices" => ["2016", "2017", "2018"],
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)
    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    location = arguments['location']
    year = arguments['year']

    # Map arguments to an epw filename.
    epw_file = "CAN_#{location}-AMY-#{year}.epw"

    puts "Weather file".green + " #{epw_file}".light_blue

    # Assign the local weather file (have to provide a full path to EpwFile).
    epw_full_file = OpenStudio::EpwFile.new("#{File.dirname(__FILE__)}/weather/#{epw_file}")
    OpenStudio::Model::WeatherFile::setWeatherFile(model, epw_full_file)

    # Set the year.
    model.getYearDescription.setCalendarYear(year.to_i)

    return true
  end
end

# Register the measure to be used by the application
NrcSetAmyWeatherFile.new.registerWithApplication
