require_relative 'common.rb'
include(TestCommon)

# Just the 2017 models. Do warehouse for all editions.
class NrcCreateNECBPrototypeBuilding_Test

  # Most functionality is in the common.rb file.
  TestCommon.remove_old_test_results
  parallelize_me!

  # This is all meta code to define the test methods.
  # Set the version of NECB to use in this test.
  template = "NECB2017"
  puts "Testing  model creation for #{template}".blue

  weather_file_types = ["TDY"]
  locations = ["Corner.Brook", "Halifax", "Moncton-Greater"]
  building_types = ['Warehouse',
                           'LargeOffice',
                           'QuickServiceRestaurant',
                           'HighriseApartment']
  global_warmings = ["0.0"]

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