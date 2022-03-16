require_relative 'common.rb'
include(TestCommon)

# Just the 2011 models.
class NrcCreateNECBPrototypeBuilding_Test

  remove_old_test_results

  def test_2011()
    #NRCMeasureTestHelper.removeOldOutputs
   
    template = 'NECB2011'

    building_types = ['Warehouse',
                      'PrimarySchool',
                      'SecondarySchool',
                      'SmallOffice',
                      'MediumOffice',
                      'SmallHotel']
    epw_files = ['AB_Banff',
                 'AB_Edmonton.Intl',
                 'QC_Montreal-Trudeau']

    # A new variable to count the number of osm models that are different than the ones in the regression folder
    $num_failed = 0

    # The forking sometimes fails. Add this logical so that it can be switched on/off easily.
    dofork = false

    # Define all the cases in individual sub-processes using fork.
    building_types.each do |building_type|
      epw_files.each do |epw_file|
        if dofork
          fork do
            run_test(necb_template: template, building_type_in: building_type, epw_file_in: epw_file)
          end
        else
          run_test(necb_template: template, building_type_in: building_type, epw_file_in: epw_file)
        end
      end
    end
    puts "Failure in #{$num_failed} models that are different from the ones in the regression models".blue

    # Now wait for the forked processes to all finish and figure out if there were any failures.
    # Would be good if we could capture the minitest output from each process and output them here.
    # This is a quick and dirty solution to identify something has failed.
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