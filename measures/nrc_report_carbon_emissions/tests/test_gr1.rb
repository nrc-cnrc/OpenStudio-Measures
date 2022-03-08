require_relative 'test.rb'
include(TestCommon)

# Just some models.
class NrcReportCarbonEmissions_Test
  def test_gr1()
    building_types = ['Warehouse',
                      'SmallOffice',
                      'PrimarySchool',
                      'SecondarySchool',
                      'SmallOffice',
                      'MediumOffice',
                      'LargeOffice',
                      'SmallHotel']

    building_types.each do |building_type|
      test_report(building_type: building_type)
    end
  end
end
