

###### (Automatically generated documentation)

# NrcReportCarbonEmissions

## Description
This reporting measure calculates the annual greenhouse gas emissions.

## Modeler Description
This measure calculates the GHG emissions expressed in tonnes CO2eq based on Emission Factors from NIR reports and Energy Star Portfolio Manager. User can select emission factors before year 2019 from one of 3 NIR reports (2019, 2020 and 2021).
            NIR report 2019 has EFs till 2017 only, so if year 2018 or 2019 is selected, the EF will be calculated based on NIR Report '2021'. Emission factors for Natural Gas,
            Propane and Fuel Oils are obtained from NIR report 2022. The natural gas emission factors from the NIR report 2022 are till year 2020, so if any other year after
            that, the 2020 EF will be used.
            Future GHG factors till 2050 are created by Environment and Climate Change Canada.
            Emission factors from Energy Star Portfolio Manager are obtained from August 2022 Portfolio Manager at https://portfoliomanager.energystar.gov/pdf/reference/Emissions.pdf
            The natural gas emission factors for each province are calculated by Environment and Climate Change Canada.

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments


### Location

**Name:** location,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Year

**Name:** start_year,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Year

**Name:** end_year,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### NIR Report Year

**Name:** nir_report_year,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.ghg_NIR_summary_section(nil,nil,nil,true)[:title]

**Name:** ghg_NIR_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.ghg_energyStar_summary_section(nil,nil,nil,true)[:title]

**Name:** ghg_energyStar_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.model_summary_section(nil,nil,nil,true)[:title]

**Name:** model_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.emissionFactors_summary_section(nil,nil,nil,true)[:title]

**Name:** emissionFactors_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.nir_emissionFactors_summary_section(nil,nil,nil,true)[:title]

**Name:** nir_emissionFactors_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false





## Outputs




co_2_e
