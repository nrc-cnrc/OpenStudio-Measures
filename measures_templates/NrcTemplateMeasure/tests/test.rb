# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcModelMeasure_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods.
  include(NRCMeasureTestHelper)

  def setup()

    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [

      {
        "name" => "a_string_argument",
        "type" => "String",
        "display_name" => "A String Argument (string)",
        "default_value" => "The Default Value",
        "is_required" => false
      },
      {
        "name" => "a_double_argument",
        "type" => "Double",
        "display_name" => "A Double numeric Argument (double)",
        "default_value" => 0,
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "is_required" => false
      },
      {
        "name" => "a_string_double_argument",
        "type" => "StringDouble",
        "display_name" => "A String Double numeric Argument (double)",
        "default_value" => 23.0,
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "valid_strings" => ["NA"],
        "is_required" => false
      },
      {
        "name" => "a_choice_argument",
        "type" => "Choice",
        "display_name" => "A Choice String Argument ",
        "default_value" => "choice_1",
        "choices" => ["choice_1", "choice_2"],
        "is_required" => false
      },
      {
        "name" => "a_bool_argument",
        "type" => "Bool",
        "display_name" => "A Boolean Argument ",
        "default_value" => false,
        "is_required" => true
      }

    ]

    @good_input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 50.0,
      "a_string_double_argument" => "50.0",
      "a_choice_argument" => "choice_1",
      "a_bool_argument" => true
    }

  end

  def test_sample_1()
    puts "Testing  model creation 1".green
    ####### Test Model Creation######
    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_sample_1")

    #You'll need a seed model to test against. You have a few options.
    # If you are only testing arguments, you can use an empty model like I am doing here.
    # Option 1: Model CreationCreate Empty Model object and start doing things to it. Here I am creating an empty model
    # and adding surface geometry to the model
    model = OpenStudio::Model::Model.new
    # and adding surface geometry to the model using the wizard.
    BTAP::Geometry::Wizards.create_shape_rectangle(model,
                                                   length = 100.0,
                                                   width = 100.0,
                                                   above_ground_storys = 3,
                                                   under_ground_storys = 1,
                                                   floor_to_floor_height = 3.8,
                                                   plenum_height = 1,
                                                   perimeter_zone_depth = 4.57,
                                                   initial_height = 0.0)
    # If we wanted to apply some aspects of a standard to our model we can by using a factory method to bring the
    # standards we want into our tests. So to bring the necb2011 we write.
    necb2011_standard = Standard.build('NECB2011')

    # could add some example contructions if we want. This method will populate the model with some
    # constructions and apply it to the model
    necb2011_standard.model_clear_and_set_example_constructions(model)

    # While debugging and testing, it is sometimes nice to make a copy of the model as it was.
    before_measure_model = copy_model(model)

    # save the model to test output directory
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
    #We can even call the standard methods to apply to the model.
    necb2011_standard.model_add_design_days_and_weather_file(model, 'NECB HDD Method', 'CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw')

    puts BTAP::FileIO.compare_osm_files(before_measure_model, model)
    necb2011_standard.apply_standard_construction_properties(model: model) # standards candidate

    # Set up your argument list to test.
    input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 10.0,
      "a_string_double_argument" => 75.3,
      "a_choice_argument" => "choice_1"
    }

    # Create an instance of the measure
    runner = run_measure(input_arguments, model)
    show_output(runner.result)

    assert(runner.result.value.valueName == 'Success')
  end

  def test_sample_2()
    puts "Testing  model creation 2".green

    ####### Test Model Creation######
    # Define the output folder for this test (optional - default is the method name).
    NRCMeasureTestHelper.appendOutputFolder("test_sample_2")

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "SmallOffice",
                                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                                  sizing_run_dir: NRCMeasureTestHelper.appendOutputFolder("test_sample_2"))

    # Set up your argument list to test.
    input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 10.0,
      "a_string_double_argument" => 75.3,
      "a_choice_argument" => "choice_1"
    }

    # Create an instance of the measure
    runner = run_measure(input_arguments, model)
    show_output(runner.result)

    assert(runner.result.value.valueName == 'Success')
  end

  # Another simple way is to Load osm file.
  def test_sample_3()
    puts "Testing  model creation 3".green
    # Define the output folder for this test (optional - default is the method name).
    NRCMeasureTestHelper.appendOutputFolder("test_sample_3")

    # Load osm file
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model_file = "#{File.dirname(__FILE__)}/SmallOffice.osm"
    model = translator.loadModel(model_file)
    msg = "Loading model: #{model_file}"
    assert(!model.empty?, msg)
    model = model.get

    # Assign the local weather file (have to provide a full path to EpwFile).
    epw = OpenStudio::EpwFile.new("#{File.dirname(__FILE__)}/weather_files/CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw")
    OpenStudio::Model::WeatherFile::setWeatherFile(model, epw)

    # Set up your argument list to test.
    input_arguments = {
      "a_string_argument" => "MyString",
      "a_double_argument" => 10.0,
      "a_string_double_argument" => 75.3,
      "a_choice_argument" => "choice_1"
    }

    # Create an instance of the measure
    runner = run_measure(input_arguments, model)
    show_output(runner.result)

    assert(runner.result.value.valueName == 'Success')
  end
end
