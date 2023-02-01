require_relative 'test.rb'
include(TestCommon)

# Just the 2017 models.
class NrcReportCarbonEmissions_Test
  def test_gr3()
    building_types = ['QuickServiceRestaurant',
                      'FullServiceRestaurant',
                      'MidriseApartment',
                      'HighriseApartment']
    building_types.each do |building_type|
      test_report(building_type: building_type)
    end
  end
end
