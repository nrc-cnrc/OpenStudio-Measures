require_relative 'common.rb'
include(TestCommon)

# Just the 2015 models.
class NrcCreateGeometry_Test

  def test_2015()
    # Delay the start of this test so that the 2011 case can initialise the output folder.
    sleep(20)

    # Set the version of NECB to use in this test
    template = 'NECB2015'
    puts "Testing  model creation for #{template}".blue

	# Options. Limit to 16 cases to keep run time down.
    building_types = ["RetailStripmall", "QuickServiceRestaurant"]
    epw_files = ['CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw', 'CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw']
    building_shapes = ["Courtyard", "Rectangular", "U-Shape"]
    total_floor_area = [20000.0]
    rotation = [10.0]
    above_grade_floors = [1]
    aspect_ratio = [1.0]

    building_types.each do |type|
      building_shapes.each do |shape|
        total_floor_area.each do |area|
          above_grade_floors.each do |floors|
            rotation.each do |rotat|
              epw_files.each do |epw_file|
                aspect_ratio.each do |aspect|
                  run_test(template: template, building_type: type, building_shape: shape, total_floor_area: area, above_grade_floors: floors, rotation: rotat, epw_file: epw_file, aspect_ratio: aspect)
                end
              end
            end
          end
        end
      end
    end
  end
end