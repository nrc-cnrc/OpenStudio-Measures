require_relative 'common.rb'
include(TestCommon)

# Just the 2011 models.
class NrcCreateNECBPrototypeBuilding_Test

  def test_2011()
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