# Standard openstudio requires for running test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCReportingMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

class NrcReportingMeasureStandard_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCReportingMeasureTestHelper)
  NRCReportingMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'] != ""
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  else
    start_time=Time.now
  end
  NRCReportingMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()

    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
        {
            "name" => "a_choice_argument",
            "type" => "Choice",
            "display_name" => "A Choice String Argument ",
            "default_value" => "choice_1",
            "choices" => ["choice_1", "choice_2"],
            "is_required" => true
		}
    ]

    @good_input_arguments = {
        "a_choice_argument" => "choice_1"
    }

  end

  def test_report()
    puts "Testing report on small Office model".blue
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
    }

    # Define the output folder for this test (optional - default is the method name). 
    output_folder = NRCReportingMeasureTestHelper.appendOutputFolder("smallOffice", input_arguments)
	
    # Load osm file
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model_file = "#{File.dirname(__FILE__)}/SmallOffice.osm"
    model = translator.loadModel(model_file)
    msg = "Loading model: #{model_file}"
    assert(!model.empty?, msg)
    model = model.get

    # Assign the local weather file (have to provide a full path to EpwFile).
	epw_path = File.expand_path("#{File.dirname(__FILE__)}/weather_files/CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw")
    epw = OpenStudio::EpwFile.new(epw_path)
    OpenStudio::Model::WeatherFile::setWeatherFile(model, epw)

    # Create an instance of the measure
	runner = run_measure(input_arguments, model)
	
	# Rename output file.
    #output_file = "report_no_diffs.html"
    #File.rename("#{output_folder}/report.html", "#{output_folder}/#{output_file}")

    # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
	#regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
	#IO.write("#{output_folder}/#{output_file}.reg", regression_file)
	#diffs = FileUtils.compare_file("#{output_folder}/#{output_file}","#{output_folder}/#{output_file}.reg")
	#assert(diffs, "There were differences to the regression files:\n")
  end

  def test_report_warehouse_prototype()
    puts "Testing report on small Office model".blue
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
    }

    # Define the output folder for this test (optional - default is the method name). 
    NRCReportingMeasureTestHelper.appendOutputFolder("warehouse", input_arguments)
	
    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "Warehouse",
                                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                                  sizing_run_dir: output_folder)

    
    # Create an instance of the measure
	runner = run_measure(input_arguments, model)
	
	# Rename output file.
    #output_file = "report_no_diffs.html"
    #File.rename("#{NRCReportingMeasureTestHelper.outputFolder}/report.html", "#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}")

    # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
	#regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
	#IO.write("#{output_folder}/#{output_file}.reg", regression_file)
	#diffs = FileUtils.compare_file("#{output_folder}/#{output_file}","#{output_folder}/#{output_file}.reg")
	#assert(diffs, "There were differences to the regression files:\n")
  end

  def test_report_warehouse_geom()
    puts "Testing report on small Office model".blue
	
    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
    }

    # Define the output folder for this test (optional - default is the method name). 
    output_folder = NRCReportingMeasureTestHelper.appendOutputFolder("WarehouseGeom", input_arguments)
	
    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Make an empty model.
    model = OpenStudio::Model::Model.new

    # Create model geometry.
    BTAP::Geometry::Wizards::create_shape_rectangle(model,
                                                      length = 100,
                                                      width = 80,
                                                      above_ground_storys = 1,
                                                      under_ground_storys = 0, # Set to 1, when modeling a basement
                                                      floor_to_floor_height = 4.7,
                                                      plenum_height = 0.0,
                                                      perimeter_zone_depth = 2.3,
                                                      initial_height = 0.0)

    # Need to set building level info
    building = model.getBuilding
    building_name = ("Warehouse")
    building.setName(building_name)
    building.setStandardsBuildingType("Warehouse")
    building.setStandardsNumberOfStories(1)
    building.setStandardsNumberOfAboveGroundStories(1)

    # Set design days
    OpenStudio::Model::DesignDay.new(model)

    # Get the space Type data from standards data
    space_type = OpenStudio::Model::SpaceType.new(model)
    space_type.setName("Warehouse WholeBuilding")
    space_type.setStandardsSpaceType("WholeBuilding")
    space_type.setStandardsBuildingType("Warehouse")
    building.setSpaceType(space_type)

    # Add internal loads
    standard.space_type_apply_internal_loads(space_type: space_type)

    # Schedules
    standard.space_type_apply_internal_load_schedules(space_type,
                                                      true,
                                                      true,
                                                      true,
                                                      true,
                                                      true,
                                                      true,
                                                      true)

    # Create thermal zones (these will get overwritten in the apply_standard method)
    standard.model_create_thermal_zones(model)

    # Set the start day
    model.setDayofWeekforStartDay("Sunday")

    # Apply standards ruleset to model (note this does a sizing run)
    standard.model_apply_standard(model: model,
                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                  sizing_run_dir: output_folder)
    
    # Create an instance of the measure
	runner = run_measure(input_arguments, model)
	
	# Rename output file.
    #output_file = "report_no_diffs.html"
    #File.rename("#{output_folder}/report.html", "#{output_folder}/#{output_file}")

    # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
	#regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
	#IO.write("#{output_folder}/#{output_file}.reg", regression_file)
	#diffs = FileUtils.compare_file("#{output_folder}/#{output_file}","#{output_folder}/#{output_file}.reg")
	#assert(diffs, "There were differences to the regression files:\n")
  end
end
