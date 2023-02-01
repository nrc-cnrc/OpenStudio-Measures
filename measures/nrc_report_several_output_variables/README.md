

###### (Automatically generated documentation)

# Nrc Report Several Output Variables

## Description
This measure displays csv files for output variables.

## Modeler Description
The measure creates CSV files for output variables entered by the user. The output variables have to be entered in the format :
    OutputVariable1 : Key Name1,OutputVariable2 : Key Name2,OutputVariable3 : Key Name3,...etc
    Also the measures creates hourly data for meter outputs ("Electricity:Facility", "Gas:Facility", "NaturalGas:Facility")

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments


### Reporting Frequency

**Name:** reporting_frequency,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["Hourly", "Timestep"]


### Please Enter the Output Variables in the format 'OutputVariable1 : Key Name1,OutputVariable2 : Key Name2,OutputVariable3 : Key Name3'   

**Name:** output_variables,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false






