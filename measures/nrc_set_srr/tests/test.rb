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

class NrcSetSrr_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'] != ""
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  else
    start_time=Time.now
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "srr_options",
        "type" => "Choice",
        "display_name" => "Select an option for SRR",
        "default_value" => "Set specific SRR",
        "choices" => ["Remove the skylights", "Set skylights to match max SRR from NECB", "Don't change skylights", "Reduce existing skylight size to meet maximum NECB SRR limit", "Set specific SRR"],
        "is_required" => true
      },
      {
        "name" => "srr",
        "type" => "Double",
        "display_name" => 'Set specific SRR (if option is selected above). Please enter a number greater than or equal to 0.0 and less than or equal to 1.0',
        "default_value" => 0.4,
        "is_required" => false
      }
    ]
  end

  # Loop through all input arguments to test all possibilities
  def test_inputArguments
    puts "Testing measure dropdown options".green

    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/resources/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get
    standard = Standard.build("NECB2017") # Need this for the checks below, must match the model.
	
    # Loop through all surfaces used in the model to get the initial srr before running the measure.
    initial_srr = 0.0
    model.getSpaces.sort.each do |space|
      space.surfaces.sort.each do |surface|
        if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "RoofCeiling"
          initial_srr = surface.skylightToRoofRatio.round(2)
        end
      end
    end
	
	# Test the dropdown options.
    all_srr_options = ["Remove the skylights", "Set skylights to match max SRR from NECB", "Don't change skylights", "Reduce existing skylight size to meet maximum NECB SRR limit", "Set specific SRR"]
    all_srr_options.each do |srr_options|
      puts "################# Testing".green + " #{srr_options}".light_blue + " #################".green

      # get arguments
      input_arguments = {
        "srr_options" => srr_options,
        "srr" => 0.0
      }
      srr = input_arguments['srr']
      srr_options = input_arguments['srr_options']
      srr_options_noSpaces = srr_options.gsub(/[[:space:]]/, '_') # Replace spaces by '_'
      test_name = "#{srr_options_noSpaces}"

      # Define the output folder for this test (optional - default is the method name).
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{test_name}")

      # Set argument values to good values and run the measure on model with spaces.
      runner = run_measure(input_arguments, model)
      result = runner.result
      assert(result.value.valueName == 'Success')

      if (srr_options == "Remove the skylights")
        expected_srr = 0.0
      elsif (srr_options == "Set skylights to match max SRR from NECB")
        max_standard_srr = standard.get_standards_constant('skylight_to_roof_ratio_max_value')
        standard.apply_max_srr_nrcan(model: model, srr_lim: max_standard_srr.to_f)
        expected_srr = (max_standard_srr)
      elsif (srr_options == "Don't change skylights")
        expected_srr = initial_srr
      elsif (srr_options == "Reduce existing skylight size to meet maximum NECB SRR limit")
        max_standard_srr = standard.get_standards_constant('skylight_to_roof_ratio_max_value')
        standard.apply_max_srr_nrcan(model: model, srr_lim: max_standard_srr.to_f)
        expected_srr = (max_standard_srr)
      elsif (srr_options == "Set specific SRR")
        expected_srr = srr
      end
      
	  # A test to check if the measure has successfully set the required srr.
      # The test will loop through all subsurfaces and calculate the srr.
      skylight_area_total = 0.0
      model.getBuilding.roofs.each do |surface|
        surface.subSurfaces.each do |subsurf|
          area = subsurf.netArea
          skylight_area_total += area
        end
      end

      srr_calculated = calculateSRR(model)
      assert_equal(srr_calculated.round(3), expected_srr.round(3), "Skylights did not change correctly")
      puts "SRR".green + " #{srr_calculated.round(3)}".light_blue + "; expected SRR ".green + "#{expected_srr.round(3)}".light_blue
      
	  # Test if the measure would grab the correct number and value of input argument.
      assert_equal(2, input_arguments.size)

      # Save the model to test output directory.
      output_path = "#{output_file_path}/test_output.osm"
      model.save(output_path, true)
      puts "Runner output #{show_output(runner.result)}".green
      assert(runner.result.value.valueName == 'Success')
    end
  end
  
  
  # Loop through various SRR values
  def test_specificSRRvalues
    puts "Testing specific SRR values".green

    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/resources/Warehouse-NECB2017-ON_Ottawa.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # Loop through all surfaces used in the model to get the initial srr before running the measure.
    initial_srr = 0.0
    model.getSpaces.sort.each do |space|
      space.surfaces.sort.each do |surface|
        if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "RoofCeiling"
          initial_srr = surface.skylightToRoofRatio.round(2)
        end
      end
    end


    all_srr_options = [0.15, 0.20, 0.22, 0.35, 0.60]
    all_srr_options.each do |srr_options|

      puts "################# Testing".green + " #{srr_options}".light_blue + " #################".green

      # get arguments
      input_arguments = {
        "srr_options" => "Set specific SRR",
        "srr" => srr_options
      }
      srr = input_arguments['srr']
      srr_options = input_arguments['srr_options']
      srr_options_noSpaces = srr_options.gsub(/[[:space:]]/, '_') # Replace spaces by '_'
      test_name = "#{srr_options_noSpaces}"


      # Define the output folder for this test (optional - default is the method name).
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{test_name}")

      # Set argument values to good values and run the measure on model with spaces.
      runner = run_measure(input_arguments, model)
      result = runner.result
      assert(result.value.valueName == 'Success')

      # A test to check if the measure has successfully set the required srr.
      # The test will loop through all subsurfaces and calculate the srr
      skylight_area_total = 0.0
      model.getBuilding.roofs.each do |surface|
        surface.subSurfaces.each do |subsurf|
          area = subsurf.netArea
          skylight_area_total += area
        end
      end

      srr_calculated = calculateSRR(model)
      assert_equal(srr_calculated.round(3), srr.round(3), "Skylights did not change correctly")
      puts "SRR".green + " #{srr_calculated.round(3)}".light_blue + "; expected SRR ".green + "#{srr.round(3)}".light_blue
      
	  # Test if the measure would grab the correct number and value of input argument.
      assert_equal(2, input_arguments.size)

      # Save the model to test output directory
      output_path = "#{output_file_path}/test_output.osm"
      model.save(output_path, true)
      puts "Runner output #{show_output(runner.result)}".green
      assert(runner.result.value.valueName == 'Success')
    end
  end

  def calculateSRR(model)
    skylight_area_total = 0.0
    model.getBuilding.roofs.each do |surface|
      surface.subSurfaces.each do |subsurf|
        area = subsurf.netArea
        skylight_area_total += area
      end
    end

    roof_area = model.getBuilding.exteriorSurfaceArea - model.getBuilding.exteriorWallArea
    srr_calculated = skylight_area_total / roof_area
    return srr_calculated
  end

end
