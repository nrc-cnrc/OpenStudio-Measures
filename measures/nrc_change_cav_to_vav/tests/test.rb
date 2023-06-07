# Standard openstudio requires for runnin test.
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper.
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test.
require 'fileutils'

class NrcChangeCAVToVAV_Test < Minitest::Test

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
    user_defined_spm = OpenStudio::StringVector.new
    user_defined_spm << "SPM_multizone_cooling_average"
    user_defined_spm << "SPM_multizone_heating_average" 
    user_defined_spm << "SPM_warmest"  
    user_defined_spm << "SPM_coldest"  
    user_defined_spm << "Default"

    @measure_interface_detailed = [
      {
        "name" => "airLoopSelected",
        "type" => "String",
        "display_name" => "Enter name of air loops (separated in commas) to switch from CAV to VAV, 'AllAirLoops', or 'SkipAllAirLoops'",
        "default_value" => "AllAirLoops",
        "is_required" => true
      },
      {
        "name" => "user_defined_spm",
        "type" => "Choice",
        "display_name" => "Enter a sepoint manager to be used",
        "default_value" => "Default",
        "choices" => user_defined_spm,
        "is_required" => true
      }      
      ]
      @good_input_arguments = {
        "airLoopSelected" => "AllAirLoops",
        "user_defined_spm" => "Default"
      }
  end



  def test_new_vav_sys_component()
    puts "Testing new vav system components".green
    @good_input_arguments
    
    # Define the output folder for this test (optional - default is the method name).
    output_file_path = NRCMeasureTestHelper.appendOutputFolder("test_new_vav_sys_component", @good_input_arguments)

    # Set standard to use.
    standard = Standard.build("NECB2017")

    # Create prototype model and update to follow standard rules (plus any sideload).
    model = standard.model_create_prototype_model(template: "NECB2017",
                                                  building_type: "RetailStripmall",
                                                  epw_file: "CAN_AB_Banff.CS.711220_CWEC2016.epw",
                                                  sizing_run_dir: output_file_path)

    # Create an instance of the measure
    runner = run_measure(@good_input_arguments, model)
    puts show_output(runner.result)
    assert(runner.result.value.valueName == 'Success')

    # Set local vars for arguments.
    airLoopSelected = @good_input_arguments['AllAirLoops']
    user_defined_spm = @good_input_arguments['Default']

    # Now check that the burner efficiency has been properly changed.
    model.getAirLoopHVACs.each do |airloop|
      puts "Air loop name:".green + " #{airloop.name}".light_blue
      airloop.supplyComponents.each do |comp|
        if comp.iddObject.name.include? "OS:Fan:ConstantVolume"
          assert_not(comp.iddObject.name.include? "OS:Fan:ConstantVolume")
          puts "comp.iddObject.name.include? const #{comp.iddObject.name.include? "OS:Fan:ConstantVolume"}"
        elsif comp.iddObject.name.include? "OS:Fan:VariableVolume"
          assert(comp.iddObject.name.include? "OS:Fan:VariableVolume")
          puts "vav fan #{comp.iddObject.name.include? "OS:Fan:VariableVolume"}"
        end
      end
      if not airloop.supplyOutletNode.to_Node.get.setpointManagers.empty?
        puts "airloop.supplyOutletNode.to_Node.get#{airloop.supplyOutletNode.to_Node.get.setpointManagers[1]}"
        puts "loop.supplyOutletNode.to_Node.get.setpointManagers[0].iddObject.name#{airloop.supplyOutletNode.to_Node.get.setpointManagers[0].iddObject.name}"
        assert(airloop.supplyOutletNode.to_Node.get.setpointManagers[0].iddObject.name.include? "SetpointManager:Warmest")
      else
        assert(airloop.supplyOutletNode.to_Node.get.setpointManagers.is_initialized)
      end
    end
    # Save the model to test output directory.
    output_path = "#{output_file_path}/test_output.osm"
    model.save(output_path, true)
    puts "Runner output #{show_output(runner.result)}".green
    assert(runner.result.value.valueName == 'Success')
  end  
end
