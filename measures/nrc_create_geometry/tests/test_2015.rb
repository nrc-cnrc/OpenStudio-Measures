require_relative 'common.rb'
include(TestCommon)

# Just the 2015 models.
class NrcCreateGeometry_Test

  # Most functionality is in the common.rb file.
  TestCommon.remove_old_test_results
  parallelize_me!

  # This is all meta code to define the test methods.
  # Set the version of NECB to use in this test.
  template = 'NECB2015'
  puts "Testing  model creation for #{template}".blue

  # Options. Limit to 16 cases to keep run time down.
  building_types = ["Warehouse", "RetailStripmall", "QuickServiceRestaurant"]
  locations = ["Thompson", "Winnipeg-Richardson", "Moncton-Greater"]
  building_shapes = ["Courtyard", "Rectangular"]
  total_floor_area = [20000.0]
  rotation = [10.0]
  above_grade_floors = [1]
  aspect_ratio = [1.0]
  global_warmings = ["3.0"]
  weather_file_types = ["EWY"]

  # Define all the cases in individual methods.
  building_types.each do |type|
    building_shapes.each do |shape|
      total_floor_area.each do |area|
        above_grade_floors.each do |floors|
          rotation.each do |rotat|
            locations.each do |location|
              weather_file_types.each do |weather_file_type|
                global_warmings.each do |global_warming|
                  aspect_ratio.each do |aspect|
                    test_name = "#{template}-#{type}-#{shape}-#{area}-#{floors}-#{rotat}-#{aspect}-#{location}-#{weather_file_type}-#{global_warming}-#{aspect}"
                    define_method(:"test_#{test_name}") {
                      run_test(template: template, building_type: type, building_shape: shape, total_floor_area: area, above_grade_floors: floors, rotation: rotat, location: location, weather_file_type: weather_file_type, global_warming: global_warming, aspect_ratio: aspect)
                    }
                  end
                end
              end
            end
          end
        end
      end
     end
  end
end