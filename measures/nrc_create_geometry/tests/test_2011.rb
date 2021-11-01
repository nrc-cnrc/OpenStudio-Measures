require_relative 'common.rb'
include(TestCommon)

# Just the 2011 models.
class NrcCreateGeometry_Test

  def test_2011()
    template = 'NECB2011'
    puts "Testing  model creation for #{template}".blue
    building_types = ["RetailStandalone", "RetailStripmall", "SmallOffice"]
    epw_files = ['CAN_NT_Yellowknife.AP.719360_CWEC2016.epw', 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw']
    building_shapes = ["Courtyard", "H-Shape"]
    total_floor_area = [20000.0, 1500.0]
    above_grade_floors = [1]
    rotation = [90.0]
    aspect_ratio = [1.25]

    building_types.each do |type|
      building_shapes.each do |shape|
        total_floor_area.each do |area|
          above_grade_floors.each do |floors|
            rotation.each do |rotat|
              epw_files.each do|epw_file|
              aspect_ratio.each do |aspect|
                 run_test(template: template, building_type: type, building_shape: shape, total_floor_area: area, above_grade_floors: floors, rotation: rotat,epw_file: epw_file, aspect_ratio: aspect)
                end
              end
            end
          end
        end
      end
    end
  end
end