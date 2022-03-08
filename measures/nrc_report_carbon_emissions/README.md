

###### (Automatically generated documentation)

# NrcReportCarbonEmissions

## Description
This reporting measure calculates the annual greenhouse gas emissions.

## Modeler Description
This measure calculates the GHG emissions expressed in tonnes CO2eq based on Emission Factors from NIR reports and Energy Star Portfolio Manager. User can select emission factors before year 2019 from one of 3 NIR reports (2019, 2020 and 2021).
            Emission Factors from 2019 NIR reports are till 2017, Emission Factors from 2020 NIR reports are till 2018, and Emission Factors from 2019 NIR reports are till 2020.
            If the input argument 'Year' was selected equals to '2018' or '2019', and input argument 'NIR Report Year' was selected '2019' or '2020', Emission
            Factors will be calculated based on NIR Report '2021'
            Future GHG factors till 2050 are created by Environment and Climate Change Canada.
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

**Name:** year,
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





## Outputs




co_2_e
