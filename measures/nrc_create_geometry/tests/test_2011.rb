require_relative 'common.rb'


# Just the 2011 models.
class NrcCreateGeometry_Test

def self.parallelize_me!
  include Minitest::Parallel::Test
  include Minitest::Parallel::Test::ClassMethods
end
  parallelize_me!
  # Most functionality is in the common.rb file.
  include(TestCommon)
  TestCommon.remove_old_test_results

# Metacode to create tests dynamically for each archetype.
#BUILDINGS.each do |attribute|
#  define_method(:"test_#{attribute}") {
#    model = autozone("#{attribute}")
#  }
#end


#  def test_2011()

    # Set the version of NECB to use in this test
    template = 'NECB2011'
    puts "Testing  model creation for #{template}".blue

    # Options. Limit to 16 cases to keep run time down.
    building_types = ["RetailStandalone", "SmallOffice"]
    building_shapes = ["Courtyard", "H-Shape"]
    total_floor_area = [20000.0, 15000.0]
    rotation = [90.0]
    above_grade_floors = [1]
    aspect_ratio = [1.25]
    weather_file_types = ["ECY"]
    locations = ["Charlottetown", "Saskatoon", "Dawson"]
    global_warmings = ["0.0"]

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
#  end
end