

###### (Automatically generated documentation)

# NRC Create From Existing Osm File

## Description
The measure searches a folder for a user defined osm file name and updates version of code

## Modeler Description
The measure searches a folder (input_osm_files) in the measure folder for a user defined osm file name.
            There's a Boolean option to update version of code, If the Bool is true then user can select one of 4 options of the code version. Options are: NECB 2011, 2015, 2017 and 2020

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Upload OSM File

**Name:** upload_osm_file,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["smallOffice_Victoria.osm", "smallOffice_Windsor.osm"]


### Update to match version of code?

**Name:** update_code_version,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### template

**Name:** template,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["NECB2011", "NECB2015", "NECB2017", "NECB2020"]






