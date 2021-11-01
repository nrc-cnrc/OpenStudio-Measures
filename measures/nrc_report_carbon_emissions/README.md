

###### (Automatically generated documentation)

# NrcReportCarbonEmissions

## Description
This reporting measure calculates the annual greenhouse gas emissions.

## Modeler Description
This measure calculates the GHG emissions expressed in tonnes CO2eq. Annual electricity intensity factors used in this reporting measure
             are defined in 'NATIONAL INVENTORY REPORT 1990 2018: GREENHOUSE GAS SOURCES AND SINKS IN CANADA CANADA’S SUBMISSION TO
            THE UNITED NATIONS FRAMEWORK CONVENTION ON CLIMATE CHANGE(http://publications.gc.ca/collections/collection_2020/eccc/En81-4-2018-3-eng.pdf)'
            A default value of 47.1 g CO2eq/MJ is used as defined in: https://unfccc.int/sites/default/files/resource/br4_final_en.pdf page #145.
            There are no electricity emission factors for Nunavut for the following years : 1990, 2000, and 2005.

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

### model_summary_section

**Name:** model_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### endUse_summary_section

**Name:** endUse_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false





## Outputs




co_2_e
