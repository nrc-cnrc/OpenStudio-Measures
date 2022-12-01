require_relative 'test.rb'
include(TestCommon)

# Just some models.
class NrcReportCarbonEmissions_Test
  def test_gr111()
    #building_types = ['Warehouse','MediumOffice','MidriseApartment']
    #epw_files = ['CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw','CAN_BC_Kamloops.AP.718870_CWEC2016.epw','CAN_MB_Winnipeg-Richardson.Intl.AP.718520_CWEC2016.epw','CAN_NB_Fredericton.Intl.AP.717000_CWEC2016.epw','CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw','CAN_NT_Yellowknife.AP.719360_CWEC2016.epw','CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw','CAN_ON_Windsor.Intl.AP.715380_CWEC2016.epw', 'CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw','CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw']

    building_types = ['Warehouse']
    epw_files = ['CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw']
    building_types.each do |building_type|
      epw_files.each do |epw_file|
        puts ">>>>>>>building_type #{building_type}  epw_file #{epw_file}  ".green
        test_report(building_type: building_type, epw_file: epw_file)
      end
    end
  end
end
