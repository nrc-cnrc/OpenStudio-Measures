

###### (Automatically generated documentation)

# Nrc Set AMY Weather File

## Description
The measure sets an AMY weather file to a model and updates its calendar year.

## Modeler Description
The measure sets one of 3 hourly weather file locations. Locations options are: Ottawa, Toronto, and Windsor.
            Also sets the calendar year to the years related to the available hourly weather files (2016, 2017 and 2018). 

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Location

**Name:** location,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["ON_Ottawa", "ON_Toronto", "ON_Windsor"]


### Location

**Name:** year,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["2016", "2017", "2018"]






