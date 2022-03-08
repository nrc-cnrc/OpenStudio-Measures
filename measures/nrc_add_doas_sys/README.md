

###### (Automatically generated documentation)

# NrcAddDOASSys

## Description
This measure sets dedicated outdoor air system (DOAS) for HVAC airloops.

## Modeler Description
The measure loops through supply components of HVAC airloops, sets up DOAS for the zones served by the air loop.
             Also it checks if it has a doas (erv), then it won't add a doas. This measure is skipped for office and highrise buildings

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Choose which zones to add DOAS to

**Name:** zonesselected,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
