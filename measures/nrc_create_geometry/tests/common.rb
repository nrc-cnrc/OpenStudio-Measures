# Standard openstudio requires for runnin test
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'openstudio-standards'
require 'minitest/autorun'

# Require the measure and test helper
require_relative '../measure.rb'
require_relative '../resources/NRCMeasureHelper.rb'

# Specific requires for this test
require 'fileutils'

# Core functionality for the tests. Individual test files speed up the testing.
module TestCommon

  def self.remove_old_test_results()

    # Check to see if an overall start time was passed (it should be if using one of the test scripts in the test folder). 
    #  If so then use it to determine what old results are (if not use now).
    if ENV['OS_MEASURES_TEST_TIME'] != ""
      start_time=Time.at(ENV['OS_MEASURES_TEST_TIME'].to_i)
    else
      start_time=Time.now
    end
    NRCMeasureTestHelper.removeOldOutputs(before: start_time)
  end

  class NrcCreateGeometry_Test < Minitest::Test

    # Brings in helper methods to simplify argument testing of json and standard argument methods
    # and set standard output folder.
    include(NRCMeasureTestHelper)
    folder = "#{self.name}"
    folder.slice!("TestCommon::")
    NRCMeasureTestHelper.setOutputFolder("#{folder}")


    def setup()
      # Copied from measure.
      @use_json_package = false
      @use_string_double = true

      epw_files = ["CAN_AB_Calgary.Intl.AP.718770_ECY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_ECY-3.0.epw", "CAN_AB_Calgary.Intl.AP.718770_EWY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_EWY-3.0.epw",
                   "CAN_AB_Calgary.Intl.AP.718770_TDY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_TDY-3.0.epw", "CAN_AB_Calgary.Intl.AP.718770_TMY-0.0.epw", "CAN_AB_Calgary.Intl.AP.718770_TMY-3.0.epw",
                   "CAN_AB_Edmonton.Intl.AP.711230_ECY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_ECY-3.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_EWY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_EWY-3.0.epw",
                   "CAN_AB_Edmonton.Intl.AP.711230_TDY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_TDY-3.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_TMY-0.0.epw", "CAN_AB_Edmonton.Intl.AP.711230_TMY-3.0.epw",
                   "CAN_AB_Fort.McMurray.AP.716890_ECY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_ECY-3.0.epw", "CAN_AB_Fort.McMurray.AP.716890_EWY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_EWY-3.0.epw",
                   "CAN_AB_Fort.McMurray.AP.716890_TDY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_TDY-3.0.epw", "CAN_AB_Fort.McMurray.AP.716890_TMY-0.0.epw", "CAN_AB_Fort.McMurray.AP.716890_TMY-3.0.epw",
                   "CAN_BC_Kelowna.Intl.AP.712030_ECY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_ECY-3.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_EWY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_EWY-3.0.epw",
                   "CAN_BC_Kelowna.Intl.AP.712030_TDY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_TDY-3.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_TMY-0.0.epw", "CAN_BC_Kelowna.Intl.AP.712030_TMY-3.0.epw",
                   "CAN_BC_Vancouver.Intl.AP.718920_ECY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_ECY-3.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_EWY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_EWY-3.0.epw",
                   "CAN_BC_Vancouver.Intl.AP.718920_TDY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_TDY-3.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_TMY-0.0.epw", "CAN_BC_Vancouver.Intl.AP.718920_TMY-3.0.epw",
                   "CAN_BC_Victoria.Intl.AP.717990_ECY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_ECY-3.0.epw", "CAN_BC_Victoria.Intl.AP.717990_EWY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_EWY-3.0.epw",
                   "CAN_BC_Victoria.Intl.AP.717990_TDY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_TDY-3.0.epw", "CAN_BC_Victoria.Intl.AP.717990_TMY-0.0.epw", "CAN_BC_Victoria.Intl.AP.717990_TMY-3.0.epw",
                   "CAN_MB_Thompson.AP.710790_ECY-0.0.epw", "CAN_MB_Thompson.AP.710790_ECY-3.0.epw", "CAN_MB_Thompson.AP.710790_EWY-0.0.epw", "CAN_MB_Thompson.AP.710790_EWY-3.0.epw",
                   "CAN_MB_Thompson.AP.710790_TDY-0.0.epw", "CAN_MB_Thompson.AP.710790_TDY-3.0.epw", "CAN_MB_Thompson.AP.710790_TMY-0.0.epw", "CAN_MB_Thompson.AP.710790_TMY-3.0.epw",
                   "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_ECY-0.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_ECY-3.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_EWY-0.0.epw",
                   "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_EWY-3.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TDY-0.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TDY-3.0.epw",
                   "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TMY-0.0.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_TMY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_ECY-0.0.epw",
                   "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_ECY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_EWY-0.0.epw",
                   "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_EWY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TDY-0.0.epw",
                   "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TDY-3.0.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TMY-0.0.epw",
                   "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_TMY-3.0.epw", "CAN_NB_Saint.John.AP.716090_ECY-0.0.epw", "CAN_NB_Saint.John.AP.716090_ECY-3.0.epw",
                   "CAN_NB_Saint.John.AP.716090_EWY-0.0.epw", "CAN_NB_Saint.John.AP.716090_EWY-3.0.epw", "CAN_NB_Saint.John.AP.716090_TDY-0.0.epw", "CAN_NB_Saint.John.AP.716090_TDY-3.0.epw",
                   "CAN_NB_Saint.John.AP.716090_TMY-0.0.epw", "CAN_NB_Saint.John.AP.716090_TMY-3.0.epw", "CAN_NL_Corner.Brook.719730_ECY-0.0.epw", "CAN_NL_Corner.Brook.719730_ECY-3.0.epw",
                   "CAN_NL_Corner.Brook.719730_EWY-0.0.epw", "CAN_NL_Corner.Brook.719730_EWY-3.0.epw", "CAN_NL_Corner.Brook.719730_TDY-0.0.epw", "CAN_NL_Corner.Brook.719730_TDY-3.0.epw",
                   "CAN_NL_Corner.Brook.719730_TMY-0.0.epw", "CAN_NL_Corner.Brook.719730_TMY-3.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_ECY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_ECY-3.0.epw",
                   "CAN_NL_St.Johns.Intl.AP.718010_EWY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_EWY-3.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_TDY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_TDY-3.0.epw",
                   "CAN_NL_St.Johns.Intl.AP.718010_TMY-0.0.epw", "CAN_NL_St.Johns.Intl.AP.718010_TMY-3.0.epw", "CAN_NS_Halifax.Intl.AP.713950_ECY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_ECY-3.0.epw",
                   "CAN_NS_Halifax.Intl.AP.713950_EWY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_EWY-3.0.epw", "CAN_NS_Halifax.Intl.AP.713950_TDY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_TDY-3.0.epw",
                   "CAN_NS_Halifax.Intl.AP.713950_TMY-0.0.epw", "CAN_NS_Halifax.Intl.AP.713950_TMY-3.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_ECY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_ECY-3.0.epw",
                   "CAN_NS_Sydney-McCurdy.AP.717070_EWY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_EWY-3.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_TDY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_TDY-3.0.epw",
                   "CAN_NS_Sydney-McCurdy.AP.717070_TMY-0.0.epw", "CAN_NS_Sydney-McCurdy.AP.717070_TMY-3.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_ECY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_ECY-3.0.epw",
                   "CAN_NT_Inuvik-Zubko.AP.719570_EWY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_EWY-3.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_TDY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_TDY-3.0.epw",
                   "CAN_NT_Inuvik-Zubko.AP.719570_TMY-0.0.epw", "CAN_NT_Inuvik-Zubko.AP.719570_TMY-3.0.epw", "CAN_NT_Yellowknife.AP.719360_ECY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_ECY-3.0.epw",
                   "CAN_NT_Yellowknife.AP.719360_EWY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_EWY-3.0.epw", "CAN_NT_Yellowknife.AP.719360_TDY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_TDY-3.0.epw",
                   "CAN_NT_Yellowknife.AP.719360_TMY-0.0.epw", "CAN_NT_Yellowknife.AP.719360_TMY-3.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_ECY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_ECY-3.0.epw",
                   "CAN_NU_Cambridge.Bay.AP.719250_EWY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_EWY-3.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_TDY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_TDY-3.0.epw",
                   "CAN_NU_Cambridge.Bay.AP.719250_TMY-0.0.epw", "CAN_NU_Cambridge.Bay.AP.719250_TMY-3.0.epw", "CAN_NU_Iqaluit.AP.719090_ECY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_ECY-3.0.epw",
                   "CAN_NU_Iqaluit.AP.719090_EWY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_EWY-3.0.epw", "CAN_NU_Iqaluit.AP.719090_TDY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_TDY-3.0.epw",
                   "CAN_NU_Iqaluit.AP.719090_TMY-0.0.epw", "CAN_NU_Iqaluit.AP.719090_TMY-3.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_ECY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_ECY-3.0.epw",
                   "CAN_NU_Rankin.Inlet.AP.710830_EWY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_EWY-3.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_TDY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_TDY-3.0.epw",
                   "CAN_NU_Rankin.Inlet.AP.710830_TMY-0.0.epw", "CAN_NU_Rankin.Inlet.AP.710830_TMY-3.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_ECY-0.0.epw",
                   "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_ECY-3.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_EWY-0.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_EWY-3.0.epw",
                   "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TDY-0.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TDY-3.0.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TMY-0.0.epw",
                   "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_TMY-3.0.epw", "CAN_ON_Sudbury.AP.717300_ECY-0.0.epw", "CAN_ON_Sudbury.AP.717300_ECY-3.0.epw", "CAN_ON_Sudbury.AP.717300_EWY-0.0.epw",
                   "CAN_ON_Sudbury.AP.717300_EWY-3.0.epw", "CAN_ON_Sudbury.AP.717300_TDY-0.0.epw", "CAN_ON_Sudbury.AP.717300_TDY-3.0.epw", "CAN_ON_Sudbury.AP.717300_TMY-0.0.epw",
                   "CAN_ON_Sudbury.AP.717300_TMY-3.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_ECY-0.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_ECY-3.0.epw",
                   "CAN_ON_Toronto.Pearson.Intl.AP.716240_EWY-0.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_EWY-3.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_TDY-0.0.epw",
                   "CAN_ON_Toronto.Pearson.Intl.AP.716240_TDY-3.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_TMY-0.0.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_TMY-3.0.epw",
                   "CAN_PE_Charlottetown.AP.717060_ECY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_ECY-3.0.epw", "CAN_PE_Charlottetown.AP.717060_EWY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_EWY-3.0.epw",
                   "CAN_PE_Charlottetown.AP.717060_TDY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_TDY-3.0.epw", "CAN_PE_Charlottetown.AP.717060_TMY-0.0.epw", "CAN_PE_Charlottetown.AP.717060_TMY-3.0.epw",
                   "CAN_QC_Jonquiere.716170_ECY-0.0.epw", "CAN_QC_Jonquiere.716170_ECY-3.0.epw", "CAN_QC_Jonquiere.716170_EWY-0.0.epw", "CAN_QC_Jonquiere.716170_EWY-3.0.epw",
                   "CAN_QC_Jonquiere.716170_TDY-0.0.epw", "CAN_QC_Jonquiere.716170_TDY-3.0.epw", "CAN_QC_Jonquiere.716170_TMY-0.0.epw", "CAN_QC_Jonquiere.716170_TMY-3.0.epw",
                   "CAN_QC_Montreal-Trudeau.Intl.AP.716270_ECY-0.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_ECY-3.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_EWY-0.0.epw",
                   "CAN_QC_Montreal-Trudeau.Intl.AP.716270_EWY-3.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TDY-0.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TDY-3.0.epw",
                   "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TMY-0.0.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_TMY-3.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_ECY-0.0.epw",
                   "CAN_QC_Quebec-Lesage.Intl.AP.717140_ECY-3.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_EWY-0.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_EWY-3.0.epw",
                   "CAN_QC_Quebec-Lesage.Intl.AP.717140_TDY-0.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_TDY-3.0.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_TMY-0.0.epw",
                   "CAN_QC_Quebec-Lesage.Intl.AP.717140_TMY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_ECY-0.0.epw", "CAN_SK_Regina.Intl.AP.715140_ECY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_EWY-0.0.epw",
                   "CAN_SK_Regina.Intl.AP.715140_EWY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_TDY-0.0.epw", "CAN_SK_Regina.Intl.AP.715140_TDY-3.0.epw", "CAN_SK_Regina.Intl.AP.715140_TMY-0.0.epw",
                   "CAN_SK_Regina.Intl.AP.715140_TMY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_ECY-0.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_ECY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_EWY-0.0.epw",
                   "CAN_SK_Saskatoon.Intl.AP.718660_EWY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_TDY-0.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_TDY-3.0.epw", "CAN_SK_Saskatoon.Intl.AP.718660_TMY-0.0.epw",
                   "CAN_SK_Saskatoon.Intl.AP.718660_TMY-3.0.epw", "CAN_YT_Dawson.719660_ECY-0.0.epw", "CAN_YT_Dawson.719660_ECY-3.0.epw", "CAN_YT_Dawson.719660_EWY-0.0.epw",
                   "CAN_YT_Dawson.719660_EWY-3.0.epw", "CAN_YT_Dawson.719660_TDY-0.0.epw", "CAN_YT_Dawson.719660_TDY-3.0.epw", "CAN_YT_Dawson.719660_TMY-0.0.epw", "CAN_YT_Dawson.719660_TMY-3.0.epw",
                   "CAN_YT_Whitehorse.Intl.AP.719640_ECY-0.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_ECY-3.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_EWY-0.0.epw",
                   "CAN_YT_Whitehorse.Intl.AP.719640_EWY-3.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_TDY-0.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_TDY-3.0.epw",
                   "CAN_YT_Whitehorse.Intl.AP.719640_TMY-0.0.epw", "CAN_YT_Whitehorse.Intl.AP.719640_TMY-3.0.epw",
                   "CAN_AB_Calgary.Intl.AP.718770_CWEC2016.epw", "CAN_AB_Edmonton.Intl.AP.711230_CWEC2016.epw", "CAN_AB_Fort.McMurray.AP.716890_CWEC2016.epw", "CAN_BC_Vancouver.Intl.AP.718920_CWEC2016.epw",
                   "CAN_BC_Victoria.Intl.AP.717990_CWEC2016.epw", "CAN_MB_Winnipeg-Richardson.Intl.AP.718520_CWEC2016.epw", "CAN_NB_Saint.John.AP.716090_CWEC2016.epw",
                   "CAN_NL_St.Johns.Intl.AP.718010_CWEC2016.epw", "CAN_NS_Halifax.Dockyard.713280_CWEC2016.epw", "CAN_NS_Sydney-McCurdy.AP.717070_CWEC2016.epw", "CAN_NT_Inuvik-Zubko.AP.719570_CWEC2016.epw",
                   "CAN_NT_Yellowknife.AP.719360_CWEC2016.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_CWEC2016.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_CWEC2016.epw",
                   "CAN_PE_Charlottetown.AP.717060_CWEC2016.epw", "CAN_QC_Montreal-Trudeau.Intl.AP.716270_CWEC2016.epw", "CAN_QC_Quebec-Lesage.Intl.AP.717140_CWEC2016.epw",
                   "CAN_SK_Saskatoon.Intl.AP.718660_CWEC2016.epw", "CAN_YT_Whitehorse.Intl.AP.719640_CWEC2016.epw",
                   "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_16.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_17.epw", "CAN_ON_Ottawa-Macdonald-Cartier.Intl.AP.716280_18.epw",
                   "CAN_ON_Toronto.Pearson.Intl.AP.716240_16.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_17.epw", "CAN_ON_Toronto.Pearson.Intl.AP.716240_18.epw",
                   "CAN_ON_Windsor.Intl.AP.715380_16.epw", "CAN_ON_Windsor.Intl.AP.715380_17.epw", "CAN_ON_Windsor.Intl.AP.715380_18.epw", "CAN_BC_Kelowna.Intl.AP.712030_CWEC2016.epw",
                   "CAN_MB_Thompson.AP.710790_CWEC2016.epw", "CAN_NB_Moncton-Greater.Moncton.LeBlanc.Intl.AP.717050_CWEC2016.epw",
                   "CAN_NL_Corner.Brook.719730_CWEC2016.epw", "CAN_NU_Cambridge.Bay.AP.719250_CWEC2016.epw", "CAN_NU_Iqaluit.AP.719090_CWEC2016.epw",
                   "CAN_NU_Rankin.Inlet.AP.710830_CWEC2016.epw", "CAN_ON_Sudbury.AP.717300_CWEC2016.epw", "CAN_QC_Jonquiere.716170_CWEC2016.epw",
                   "CAN_SK_Prince.Albert.AP.718690_CWEC2016.epw", "CAN_SK_Regina.Intl.AP.715140_CWEC2016.epw", "CAN_YT_Dawson.719660_CWEC2020.epw"]

      @measure_interface_detailed =
        [
          {
            "name" => "building_shape",
            "type" => "Choice",
            "display_name" => "Building shape",
            "default_value" => "Rectangular",
            "choices" => ["Courtyard", "H-Shape", "L-Shape", "Rectangular", "T-Shape", "U-Shape"],
            "is_required" => true
          },
          {
            "name" => "template",
            "type" => "Choice",
            "display_name" => "template",
            "default_value" => "NECB2011",
            "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020"],
            "is_required" => true
          },
          {
            "name" => "building_type",
            "type" => "Choice",
            "display_name" => "Building Type ",
            "default_value" => "SmallOffice",
            "choices" => ["SecondarySchool", "PrimarySchool", "SmallOffice", "MediumOffice", "LargeOffice", "SmallHotel", "LargeHotel", "Warehouse", "RetailStandalone", "RetailStripmall", "QuickServiceRestaurant", "FullServiceRestaurant", "MidriseApartment", "HighriseApartment" "MidriseApartment", "Hospital", "Outpatient"],
            "is_required" => true
          },
          {
            "name" => "location",
            "type" => "Choice",
            "display_name" => "Location",
            "default_value" => "Calgary",
            "choices" => ["Calgary", "Edmonton", "Fort.McMurray", "Kelowna", "Vancouver", "Victoria", "Thompson", "Winnipeg-Richardson", "Moncton-Greater", "Saint.John", "Corner.Brook", "St.Johns", "Halifax", "Sydney-McCurdy", "Inuvik-Zubko", "Yellowknife", "Cambridge.Bay", "Iqaluit", "Rankin.Inlet", "Ottawa-Macdonald-Cartier", "Sudbury", "Toronto.Pearson", "Charlottetown", "Jonquiere", "Montreal-Trudeau", "Quebec-Lesage", "Regina", "Saskatoon", "Dawson", "Whitehorse", "Prince.Albert", "Windsor"],
            "is_required" => true
          },
          {
            "name" => "weather_file_type",
            "type" => "Choice",
            "display_name" => "Weather Type",
            "default_value" => "ECY",
            "choices" => ["ECY", "EWY", "TDY", "TMY", "CWEC2016"],
            "is_required" => true
          },
          {
            "name" => "global_warming",
            "type" => "Choice",
            "display_name" => "Global Warming",
            "default_value" => "0.0",
            "choices" => ["0.0", "3.0"],
            "is_required" => true
          },
          {
            "name" => "total_floor_area",
            "type" => "Double",
            "display_name" => "Total building area (m2)",
            "default_value" => 50000.0,
            "max_double_value" => 10000000.0,
            "min_double_value" => 10.0,
            "is_required" => true
          },
          {
            "name" => "aspect_ratio",
            "type" => "Double",
            "display_name" => "Aspect ratio (width/length; width faces south before rotation)",
            "default_value" => 1.0,
            "max_double_value" => 10.0,
            "min_double_value" => 0.1,
            "is_required" => true
          },
          {
            "name" => "rotation",
            "type" => "Double",
            "display_name" => "Rotation (degrees clockwise)",
            "default_value" => 0.0,
            "max_double_value" => 360.0,
            "min_double_value" => 0.0,
            "is_required" => true
          },
          {
            "name" => "above_grade_floors",
            "type" => "Integer",
            "display_name" => "Number of above grade floors",
            "default_value" => 3,
            "max_integer_value" => 200,
            "min_integer_value" => 1,
            "is_required" => true
          },
          {
            "name" => "floor_to_floor_height",
            "type" => "Double",
            "display_name" => "Floor to floor height (m)",
            "default_value" => 3.8,
            "max_double_value" => 10.0,
            "min_double_value" => 2.0,
            "is_required" => false
          },
          {
            "name" => "plenum_height",
            "type" => "Double",
            "display_name" => "Plenum height (m), or Enter '0.0' for No Plenum",
            "default_value" => 0.0,
            "max_double_value" => 2.0,
            "is_required" => false
          },
          {
            "name" => "sideload",
            "type" => "Bool",
            "display_name" => "Check for sideload files (to overwrite standards info)?",
            "default_value" => false,
            "is_required" => true
          }
        ]

      @good_input_arguments = {
        "building_shape" => "Rectangular",
        "template" => "NECB2017",
        "building_type" => "SmallOffice",
        "location" => "Calgary",
        "weather_file_type" => "ECY",
        "global_warming" => "0.0",
        "total_floor_area" => 50000.0,
        "aspect_ratio" => 0.5,
        "rotation" => 30.0,
        "above_grade_floors" => 2,
        "floor_to_floor_height" => 3.2,
        "plenum_height" => 1.0,
        "sideload" => false
      }
    end

    def run_test(template: 'NECB2017', building_type: 'Warehouse', building_shape: 'Rectangular', total_floor_area: 20000, above_grade_floors: 3, rotation: 0, location: "Calgary", weather_file_type: "ECY", global_warming: "0.0", aspect_ratio: 1)

      ####### Test Model Creation ######
      puts "  Testing for arguments:".green
      puts "  Building type: ".green + " #{building_type}".light_blue
      puts "  Building shape: ".green + " #{building_shape}".light_blue
      puts "  Code version: ".green + " #{template}".light_blue
      puts "  Total floor area:".green + " #{total_floor_area}".light_blue
      puts "  Above grade floors: ".green + " #{above_grade_floors}".light_blue
      puts "  Rotation: ".green + " #{rotation}".light_blue
      puts "  Aspect_ratio: ".green + " #{aspect_ratio}".light_blue
      puts "  Location: ".green + " #{location}".light_blue
      puts "  Weather Type: ".green + " #{weather_file_type}".light_blue
      puts "  Global Warming: ".green + " #{global_warming}".light_blue

      # Make an empty model.
      model = OpenStudio::Model::Model.new

      input_arguments = {
        "building_shape" => building_shape,
        "template" => template,
        "building_type" => building_type,
        "location" => location,
        "weather_file_type" => weather_file_type,
        "global_warming" => global_warming,
        "total_floor_area" => total_floor_area,
        "aspect_ratio" => aspect_ratio,
        "rotation" => rotation,
        "above_grade_floors" => above_grade_floors,
        "floor_to_floor_height" => 3.2,
        "plenum_height" => 0.0,
        "sideload" => false
      }

      # Define specific output folder for this test. In this case use the tempalet and the model name as this combination is unique.
      model_name = "#{building_shape}-#{building_type}-#{template}-#{rotation.to_int}-#{above_grade_floors}-#{total_floor_area.to_int}-#{aspect_ratio}_#{location}_#{weather_file_type}_#{global_warming.to_i}"
      output_file_path = NRCMeasureTestHelper.appendOutputFolder("#{model_name}", input_arguments)
      puts "Output folder ".green + "#{output_file_path}".light_blue

      # Create an instance of the measure with good values
      runner = run_measure(input_arguments, model)

      # Test the model is correctly defined.
      assert_in_delta(total_floor_area.to_f.round(2), model.getBuilding.floorArea.to_f.round(2), 0.1)
      assert_includes(model.getBuilding.standardsTemplate.to_s, input_arguments['template'].to_s, 'code version')
      assert_includes(model.getBuilding.standardsBuildingType.to_s, input_arguments['building_type'].to_s, 'building type')
      assert(runner.result.value.valueName == 'Success')

      # Save the model to test output directory.
      output_file = "#{output_file_path}.osm"
      model.save(output_file, true)
    end
  end
end