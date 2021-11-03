require_relative 'common.rb'
include(TestCommon)

# Just the 2020 models.
class NrcCreateGeometry_Test

  def test_2020()
    # Delay the start of this test so that the 2011 case can initialise the output folder.
    sleep(40)

    # Set the version of NECB to use in this test
    template = 'NECB2020'
    puts "Testing  model creation for #{template}".blue

	# Options. Limit to 4 cases to keep run time down (as these models take time to simulate).
    building_types = ["LargeOffice", "HighriseApartment"]
    epw_files = ['CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw']
    building_shapes = ["L-Shape", "Rectangular"]
    total_floor_area = [40000.0]
    rotation = [10.0]
    above_grade_floors = [12]
    aspect_ratio = [2.0]

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