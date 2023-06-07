require_relative 'common.rb'
include(TestCommon)

# Just the 2015 models. Do warehouse for all editions.
class NrcCreateNECBPrototypeBuilding_Test

  # Most functionality is in the common.rb file.
  TestCommon.remove_old_test_results
  parallelize_me!

  # This is all meta code to define the test methods.
  # Set the version of NECB to use in this test.
  template = "NECB2015"
  puts "Testing  model creation for #{template}".blue

  building_types = ['Warehouse',
                      'LargeOffice',
                      'RetailStripmall',
                      'Outpatient']
  locations = ["MB_Thompson", "MB_Winnipeg", "NB_Moncton"]
  weather_file_types = ["CWEC2016"]
  global_warmings = ["3.0"]

  # Define all the cases in individual methods.
  locations.each do |location|
    weather_file_types.each do |weather_file_type|
      global_warmings.each do |global_warming|
        building_types.each do |building_type|
          test_name = "#{template}-#{building_type}-#{location}-#{weather_file_type}-#{global_warming}"
          define_method(:"test_#{test_name}") {
            run_test(necb_template: template, building_type_in: building_type, location_in: location, weather_file_type_in: weather_file_type, global_warming_in: global_warming)
          }
        end
      end
    end
  end
end