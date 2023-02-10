require_relative 'common.rb'
include(TestCommon)

# Just the 2017 models. Do warehouse for all editions.
class NrcCreateNECBPrototypeBuilding_Test

  remove_old_test_results

  def test_2017()

    template = "NECB2017"
    weather_file_types = ["TDY"]
    locations = ["Corner.Brook", "Halifax", "Moncton-Greater"]
    building_types = ['Warehouse',
                           'LargeOffice',
                           'QuickServiceRestaurant',
                           'HighriseApartment']
    global_warmings = ["0.0"]

    # A new variable to count the number of osm models that are different than the ones in the regression folder
    $num_failed = 0

    # The forking sometimes fails. Add this logical so that it can be switched on/off easily.
    dofork = false

    # Define all the cases in individual sub-processes using fork.

    locations.each do |location|
      weather_file_types.each do |weather_file_type|
        global_warmings.each do |global_warming|
          building_types.each do |building_type|
            if dofork
              fork do
                run_test(necb_template: template, building_type_in: building_type, location_in: location, weather_file_type_in: weather_file_type, global_warming_in: global_warming)
              end
            else
              run_test(necb_template: template, building_type_in: building_type, location_in: location, weather_file_type_in: weather_file_type, global_warming_in: global_warming)
            end
          end
        end
      end
    end

    puts "Failure in #{$num_failed} models that are different from the ones in the regression models".blue

    # Now wait for the forked processes to all finish and figure out if there were any failures.
    # Would be good if we could capture the minitest output from each process and output them here.
    # This is a quick solution to identify something has failed.
    if dofork
      success = true
      results = Process.waitall
      results.each do |result|
        success = success && result[1].success?
      end
      msg = "Failure in one or more models for test: #{__method__}"
      assert(success, msg)
    end
  end
end