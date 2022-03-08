require_relative 'test.rb'
include(TestCommon)

# Just the 2017 models.
class NrcReportCarbonEmissions_Test
  def test_gr2()
    building_types = ['Warehouse',
                      'RetailStandalone',
                      'RetailStripmall',
                      'Hospital',
                      'Outpatient']
    building_types.each do |building_type|
      test_report(building_type: building_type)
    end
  end
end
