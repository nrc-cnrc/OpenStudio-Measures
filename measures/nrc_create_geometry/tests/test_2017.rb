require_relative 'common.rb'
include(TestCommon)

# Just the 2017 models.
class NrcCreateGeometry_Test

  remove_old_test_results

  def test_2017()

    # Set the version of NECB to use in this test
    template = 'NECB2017'
    puts "Testing  model creation for #{template}".blue

    # Options. Limit to 16 cases to keep run time down.
    building_types = ["PrimarySchool", "MediumOffice"]
    locations = ['Toronto.Pearson', 'Halifax', 'Vancouver']
    building_shapes = ["U-Shape"]
    total_floor_area = [20000.0, 10000.0]
    rotation = [40.0]
    above_grade_floors = [1, 3]
    global_warmings = ["0.0"]
    weather_file_types = ["TDY"]
    aspect_ratio = [1.5]

    building_types.each do |type|
      building_shapes.each do |shape|
        total_floor_area.each do |area|
          above_grade_floors.each do |floors|
            rotation.each do |rotat|
              locations.each do |location|
                weather_file_types.each do |weather_file_type|
                  global_warmings.each do |global_warming|
                    aspect_ratio.each do |aspect|
                      run_test(template: template, building_type: type, building_shape: shape, total_floor_area: area, above_grade_floors: floors, rotation: rotat, location: location, weather_file_type: weather_file_type, global_warming: global_warming, aspect_ratio: aspect)
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
end