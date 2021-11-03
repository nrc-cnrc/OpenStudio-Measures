require_relative 'common.rb'
include(TestCommon)

# Just the 2015 models. Do warehouse for all editions.
class NrcCreateNECBPrototypeBuilding_Test

  def test_2015()

    # Delay the start of this test so that the 2011 case can initialise the output folder.
    sleep(20)

    template = 'NECB2015'

    building_types = ['Warehouse',
                      'LargeOffice',
                      'RetailStripmall',
                      'FullServiceRestaurant',
                      'Outpatient']
    epw_files = ['AB_Banff',
                 'BC_Vancouver',
                 'ON_Toronto']
    # Multithreading is used to run the tests.
    threads = []
    $num_failed = 0

    building_types.each do |building_type|
      epw_files.each do |epw_file|
        threads << Thread.new {
          puts "Creating new thread for #{building_type} and #{epw_file}".blue
          run_test(necb_template: template, building_type_in: building_type, epw_file_in: epw_file)
        }
        threads.each(&:join) # To ensure that all the processes are finished
      end
    end

    puts "Failure in #{$num_failed} models that are different from the ones in the regression models".blue
  end
end