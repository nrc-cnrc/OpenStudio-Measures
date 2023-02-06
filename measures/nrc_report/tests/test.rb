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

# Core functionality for the tests. Individual test files speed up the testing.
module TestCommon

  class NrcReport_Test < Minitest::Test

    include(NRCReportingMeasureTestHelper)
    @use_json_package = false
    @use_string_double = true

    def setup()
      @use_json_package = false
      @use_string_double = false
      @measure_interface_detailed = [
        {
          "name" => "report_depth",
          "type" => "Choice",
          "display_name" => "Report detail level",
          "default_value" => "Summary",
          "choices" => ["Summary", "Detailed"],
          "is_required" => true
        }
      ]
      possible_sections.each do |method_name|
        @measure_interface_detailed << {
          "name" => method_name,
          "type" => "Bool",
          "display_name" => "OsLib_Reporting.#{method_name}(nil,nil,nil,true)[:title]",
          "default_value" => true,
          "is_required" => true
        }
      end
    end

    def possible_sections
      result = []
      # methods for sections in order that they will appear in report
      result << 'model_summary_section'
      result << 'server_summary_section'
      result << 'building_construction_detailed_section'
      result << 'construction_summary_section'
      result << 'heat_gains_summary_section'
      result << 'heat_loss_summary_section'
      result << 'heat_gains_detail_section'
      result << 'heat_losses_detail_section'
      result << 'steadySate_conductionheat_losses_section'
      result << 'thermal_zone_summary_section'
      result << 'hvac_summary_section'
      result << 'air_loops_detail_section'
      result << 'plant_loops_detail_section'
      result << 'zone_equipment_detail_section'
      result << 'hvac_airloops_detailed_section1'
      result << 'hvac_plantloops_detailed_section1'
      result << 'hvac_zoneEquip_detailed_section1'
      result << 'output_data_end_use_table'
      result << 'serviceHotWater_summary_section'
      result << 'interior_lighting_summary_section'
      result << 'interior_lighting_detail_section'
      result << 'daylighting_summary_section'
      result << 'exterior_light_section'
      result << 'shading_summary_section'
      result
    end

    def test_report(building_type:)
      puts "Testing  model creation for".green + " #{building_type}".light_blue
      puts "Testing directory: ".green + " #{test_dir}".light_blue
      # create an instance of the measure
      measure = NrcReport.new
      # create an instance of a runner
      runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

      template = "NECB2017"
      prototype_creator = Standard.build(template)
      model = prototype_creator.model_create_prototype_model(
        template: template,
        epw_file: 'CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw',
        sizing_run_dir: test_dir,
        debug: @debug,
        building_type: building_type)

      # Set input args. In this case the std matches the one used to create the test model.
      input_arguments = {
        "report_depth" => "Summary"
      }

      # Define the output folder for this test (optional - default is the method name).
      test_dir = NRCReportingMeasureTestHelper.appendOutputFolder("test_report/#{building_type}", input_arguments)

      # Create an instance of the measure
      run_measure(input_arguments, model)

      # Rename output file.
      #output_file = "report_no_diffs.html"
      #File.rename("#{NRCReportingMeasureTestHelper.outputFolder}/report.html", "#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}")

      # Check for differences between the current output and the regression report. Need to write regression file without CRTF endiings.
      #regression_file = IO.read("#{File.dirname(__FILE__)}/regression_reports/#{output_file}").gsub(/\r\n?/,"\n")
      #IO.write("#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}.reg", regression_file)
      #diffs = FileUtils.compare_file("#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}","#{NRCReportingMeasureTestHelper.outputFolder}/#{output_file}.reg")
      #assert(diffs, "There were differences to the regression files:\n")
    end
  end
end