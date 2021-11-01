

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

### Climate File

**Name:** epw_file,
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




