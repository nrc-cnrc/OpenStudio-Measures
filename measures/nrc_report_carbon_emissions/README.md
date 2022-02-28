

###### (Automatically generated documentation)

# NrcReportCarbonEmissions

## Description
This reporting measure calculates the annual greenhouse gas emissions.

## Modeler Description
This measure calculates the GHG emissions expressed in tonnes CO2eq based on Emission Factors from NIR report and Energy Star Portfolio Manager. Regarding the emission factors from NIR report, the annual electricity intensity factors before year 2019 are defined in 'NATIONAL INVENTORY REPORT 1990 2018: GREENHOUSE GAS SOURCES AND SINKS IN CANADA CANADAâ€™S SUBMISSION TO
THE UNITED NATIONS FRAMEWORK CONVENTION ON CLIMATE CHANGE(http://publications.gc.ca/collections/collection_2020/eccc/En81-4-2018-3-eng.pdf)'.
Whereas annual electricity intensity factors after year 2019 and also future GHG factors till 2050 are created by Environment and Climate Change Canada.
There are no electricity emission factors for Nunavut for the following years : 1990, 2000, and 2005.
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
