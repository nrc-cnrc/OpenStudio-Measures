# Standard openstudio requires for running test.
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper.
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'
require_relative '../resources/compare_models.rb'

# Specific requires for this test.
require 'fileutils'

class NrcAlterRefStandard_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCMeasureTestHelper)
  NRCMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'].nil?
    start_time=Time.now
  else
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  end
  NRCMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()

    # These three variables should match the definitions in the measure itself (unfortunately it has to be copied and
    #   cannot be referenced.
    @use_json_package = false
    @use_string_double = true
    @measure_interface_detailed = [
      {
        "name" => "lighting",
        "type" => "Choice",
        "display_name" => "Lighting vintage",
        "default_value" => "NECB2020",
        "choices" => ["No change", "NECB2011", "NECB2015", "NECB2017", "NECB2020", "BTAPPRE1980", "BTAP1980TO2010"],
        "is_required" => true
      }
    ]

    # Must have @good_input_arguments defined for standard BTAP checking to work.
    @good_input_arguments = {
      "lighting" => "NECB2015"
    }
  end

  # Using a prototype model.
  def test_NECB2020()
    puts "Testing changing lighting_to_NECB2020".green

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = {
      "lighting" => "NECB2020"
    }

    # Define the output folder for this test. This is used as the folder name and in the test README.md file as the
    #  section name. The arguments are used to store the path in a hash for when we have multiple test methods in a class.
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Lighting_to_NECB2020", input_arguments)

    # Set standard to use.
    template = "NECB2011"
    standard = Standard.build(template)

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: template,
                                                  building_type: "SmallOffice",
                                                  epw_file: "CAN_AB_Edmonton-CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Remember the initial model.
    initial_model = model.clone.to_Model
    output_path = "#{output_file_path}/initial_model.osm"
    initial_model.save(output_path, true)

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    output_path = "#{output_file_path}/final_model.osm"
    model.save(output_path, true)

    # Compare the two models (using method in standards)
    diffs = compare_osm_files(initial_model, model)
    puts "#{diffs}".pink

    # Not sure purging helps.
    #model.purgeUnusedResourceObjects
    #initial_model.purgeUnusedResourceObjects
    #diffs = compare_osm_files(initial_model, model)
    #puts "#{diffs}".yellow

    # Write out diff or error message (make sure an old file does not exist).
    diff_file = "#{output_file_path}/model_diffs.json"
    FileUtils.rm(diff_file) if File.exists?(diff_file)
    if diffs.size > 0
      File.write(diff_file, JSON.pretty_generate(diffs))
      puts "There were #{diffs.size} differences/errors in ****".red
    end

    # Check the stored outputs. This requires the output to be defined in the measure.
    #output_object = runner.result.stepValues.find {|item| item.name.eql?'name_of_output'}
    #value = output_object.valueAsDouble
    #assert_in_delta(value.signif(2), 5.2, 0.01, "Error in example checking on an output value") # Use for comparing doubles.

    # In a real measure add tests that are specific to the measure here.
  end

  # Using a prototype model. This should result in no changes.
  def test_NECB2017()
    puts "Testing changing lighting_to_NECB2011".green

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = {
      "lighting" => "NECB2017"
    }

    # Define the output folder for this test. This is used as the folder name and in the test README.md file as the
    #  section name. The arguments are used to store the path in a hash for when we have multiple test methods in a class.
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("Lighting_to_NECB2017", input_arguments)

    # Set standard to use.
    template = "NECB2017"
    standard = Standard.build(template)

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: template,
                                                  building_type: "SmallOffice",
                                                  epw_file: "CAN_AB_Edmonton-CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Remember the initial model.
    output_path = "#{output_file_path}/initial_model.osm"
    model.save(output_path, true)
    initial_model = model.clone.to_Model

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Compare the two models (using method in standards)
    diffs = compare_osm_files(initial_model, model)
    puts "#{diffs}".pink

    # Not sure purging helps.
    #model.purgeUnusedResourceObjects
    #initial_model.purgeUnusedResourceObjects
    #diffs = compare_osm_files(initial_model, model)
    #puts "#{diffs}".yellow

    # Write out diff or error message (make sure an old file does not exist).
    diff_file = "#{output_file_path}/model_diffs.json"
    FileUtils.rm(diff_file) if File.exists?(diff_file)
    if diffs.size > 0
      File.write(diff_file, JSON.pretty_generate(diffs))
      puts "There were #{diffs.size} differences/errors in ****".red
    end

    # Check the stored outputs. This requires the output to be defined in the measure.
    #output_object = runner.result.stepValues.find {|item| item.name.eql?'name_of_output'}
    #value = output_object.valueAsDouble
    #assert_in_delta(value.signif(2), 5.2, 0.01, "Error in example checking on an output value") # Use for comparing doubles.

    # In a real measure add tests that are specific to the measure here.
  end

  # Using a prototype model.
  def te_st_no_change()
    puts "Testing no change in Lighting".green

    # Set up your argument list to test. Or use @good_input_arguments
    input_arguments = {
      "lighting" => "No change"
    }

    # Define the output folder for this test. This is used as the folder name and in the test README.md file as the
    #  section name. The arguments are used to store the path in a hash for when we have multiple test methods in a class.
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("No_change", input_arguments)

    # Set standard to use.
    template = "NECB2017"
    standard = Standard.build(template)

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: template,
                                                  building_type: "SmallOffice",
                                                  epw_file: "CAN_AB_Edmonton-CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Remember the initial model.
    initial_model = model
    output_path = "#{output_file_path}/initial_model.osm"
    initial_model.save(output_path, true)

    # Run the measure. This saves the updated model to "#{output_file_path}/test_output.osm".
    runner = run_measure(input_arguments, model)

    # Check that it ran successfully.
    assert(runner.result.value.valueName == 'Success', "Error in running measure.")

    # Compare the two models (using method in standards)
    diffs = compare_osm_files(initial_model, model)
    puts "#{diffs}".pink

    # Write out diff or error message (make sure an old file does not exist).
    diff_file = "#{output_file_path}/model_diffs.json"
    FileUtils.rm(diff_file) if File.exists?(diff_file)
    if diffs.size > 0
      File.write(diff_file, JSON.pretty_generate(diffs))
      puts "There were #{diffs.size} differences/errors in ****".red
    end

    # Check the stored outputs. This requires the output to be defined in the measure.
    #output_object = runner.result.stepValues.find {|item| item.name.eql?'name_of_output'}
    #value = output_object.valueAsDouble
    #assert_in_delta(value.signif(2), 5.2, 0.01, "Error in example checking on an output value") # Use for comparing doubles.

    # In a real measure add tests that are specific to the measure here.
  end

end
