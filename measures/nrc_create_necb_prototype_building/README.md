

###### (Automatically generated documentation)

# NrcCreateNECBPrototypeBuilding

## Description
This measure creates an NECB prototype building from scratch and uses it as the base for an analysis.

## Modeler Description
This will replace the model object with a brand new model. It effectively ignores the seed model. If there are 
	updated tables/formulas to those in the standard they can be sideloaded into the standard definition - this new data will
	then be used to create the model.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Template

**Name:** template,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Building Type

**Name:** building_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Location

**Name:** location,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Weather Type

**Name:** weather_file_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Global Warming

**Name:** global_warming,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Check for sideload files (to overwrite standards info)?

**Name:** sideload,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
