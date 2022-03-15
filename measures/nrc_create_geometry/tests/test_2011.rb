require_relative 'common.rb'
include(TestCommon)

# Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
#  If so then use it to determine what old results are (if not use now)
start_time=Time.now
if ARGV.length == 1

  # We have a time. It will be in seconds since the epoch. Update our start_time.
  start_time=Time.at(ARGV[0].to_i)
end
NRCMeasureTestHelper::removeOldOutputs(before: start_time)
NRCMeasureTestHelper::appendOutputFolder("NECB2011")

# Just the 2011 models.
class NrcCreateGeometry_Test

  def test_2011()
    # Remove the existing outputs. Only need to do this here.
    #NRCMeasureTestHelper.removeOldOutputs
  
    # Set the version of NECB to use in this test
    template = 'NECB2011'
    puts "Testing  model creation for #{template}".blue
	
	# Options. Limit to 16 cases to keep run time down.
    building_types = ["RetailStandalone", "SmallOffice"]
    epw_files = ['CAN_NT_Yellowknife.AP.719360_CWEC2016.epw', 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw']
    building_shapes = ["Courtyard", "H-Shape"]
    total_floor_area = [20000.0, 1500.0]
    rotation = [90.0]
    above_grade_floors = [1]
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