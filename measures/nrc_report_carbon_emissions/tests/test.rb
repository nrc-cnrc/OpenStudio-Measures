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

class NrcReportCarbonEmissions_Test < Minitest::Test

  # Brings in helper methods to simplify argument testing of json and standard argument methods
  # and set standard output folder.
  include(NRCReportingMeasureTestHelper)
  NRCReportingMeasureTestHelper.setOutputFolder("#{self.name}")

  # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
  #  If so then use it to determine what old results are (if not use now).
  if ENV['OS_MEASURES_TEST_TIME'].nil?
    start_time=Time.now
  else
    start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
  end
  NRCReportingMeasureTestHelper.removeOldOutputs(before: start_time)


  def setup()
    @use_json_package = false
    @use_string_double = true

    @measure_interface_detailed = [
      {
        "name" => "location",
        "type" => "Choice",
        "display_name" => "Location",
        "default_value" => 'Ontario',
        "choices" => ['Get From the Model', 'Canada', 'Newfoundland and Labrador', 'Prince Edward Island', 'Nova Scotia', 'New Brunswick', 'Quebec', 'Ontario', 'Manitoba',
                      'Saskatchewan', 'Alberta', 'British Columbia', 'Yukon', 'Northwest Territories', 'Nunavut'],
        "is_required" => true
      },
      {
        "name" => "start_year",
        "type" => "Choice",
        "display_name" => "Year",
        "default_value" => '2015',
        "choices" => ['1990', '2000', '2005', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035', '2036', '2037', '2038', '2039',
                      '2040', '2041', '2042', '2043', '2044', '2045', '2046', '2047', '2048', '2049', '2050'],
        "is_required" => true
      },
      {
        "name" => "end_year",
        "type" => "Choice",
        "display_name" => "Year",
        "default_value" => '2025',
        "choices" => ['1990', '2000', '2005', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035', '2036', '2037', '2038', '2039',
                      '2040', '2041', '2042', '2043', '2044', '2045', '2046', '2047', '2048', '2049', '2050'],
        "is_required" => true
      },
      {
        "name" => "nir_report_year",
        "type" => "Choice",
        "display_name" => "NIR Report Year",
        "default_value" => '2021',
        "choices" => ['2019', '2020', '2021'],
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
    result << 'ghg_NIR_summary_section'
    result << 'ghg_energyStar_summary_section'
    result << 'model_summary_section'
    result << 'emissionFactors_summary_section'
    result << 'nir_emissionFactors_summary_section'
    result
  end

  def test_report(building_type: "Warehouse")
    puts "Testing  model creation for".green + " #{building_type}".light_blue

    # Set input args. In this case the std matches the one used to create the test model.
    input_arguments = {
      "location" => "Yukon",
      "start_year" => "2015",
      "end_year" => "2025",
      "nir_report_year" => "2019",
      "ghg_NIR_summary_section" => true,
      "ghg_energyStar_summary_section" => true,
      "model_summary_section" => true,
      "emissionFactors_summary_section" => true,
      "nir_emissionFactors_summary_section" => true
    }

    # Define the output folder for this test. Set a local var for use later.
    test_dir = NRCReportingMeasureTestHelper.appendOutputFolder("report_#{building_type}", input_arguments)
    puts "Testing directory: ".green + " #{test_dir}".light_blue

    # Create standard.
    template = "NECB2017"
    prototype_creator = Standard.build(template)

    # Create model.
    model = prototype_creator.model_create_prototype_model(
        template: template,
        epw_file: 'CAN_ON_Ottawa-CWEC2020.epw',
        sizing_run_dir: test_dir,
        building_type: building_type)

    # Create an instance of the measure and run it. Check tha it ran successfully.
    runner = run_measure(input_arguments, model)
    assert(runner.result.value.valueName == 'Success')

    # Check outputs...
  end
end
