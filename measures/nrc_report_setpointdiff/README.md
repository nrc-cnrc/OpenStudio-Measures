

###### (Automatically generated documentation)

# NrcReportSetPointDiff

## Description
This measure reports statistics on how well the model has controlled to the various set points.

## Modeler Description
The measure scans through the models for set points. For each location found the results of the controlled variable are saved.
	The measure then calculates, on an hourly basis, deviations from the set point.

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments


### Time Step

**Name:** timeStep,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Create detailed hourly excel files

**Name:** detail,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.model_summary_section(nil,nil,nil,true)[:title]

**Name:** model_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.temperature_detailed_section(nil,nil,nil,true)[:title]

**Name:** temperature_detailed_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.temp_diff_summary_section(nil,nil,nil,true)[:title]

**Name:** temp_diff_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




