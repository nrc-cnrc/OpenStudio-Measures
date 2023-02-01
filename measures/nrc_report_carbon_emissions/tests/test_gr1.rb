require_relative 'test.rb'
include(TestCommon)

# Just some models.
class NrcReportCarbonEmissions_Test
  def test_gr11()
    building_types = ['Warehouse']#,
=begin
                      'SmallOffice',
                      'PrimarySchool',
                      'SecondarySchool',
                      'SmallOffice',
                      'MediumOffice',
                      'LargeOffice',
                      'SmallHotel']
=end

    building_types.each do |building_type|
      test_report(building_type: building_type)
    end
  end
end
