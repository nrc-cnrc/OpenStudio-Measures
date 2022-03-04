

###### (Automatically generated documentation)

# NrcCreateGeometry

## Description
Create standard building shapes and define spaces. The total floor area, and number of floors are specified. The building is assumed to be in thirds (thus for the courtyard the middle third is the void)

## Modeler Description
Defines the geometry of the building based on the given inputs. Uses BTAP::Geometry::Wizards::create_shape_* methods

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Building shape

**Name:** building_shape,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### template

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

### Weather file

**Name:** epw_file,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Total building area (m2)

**Name:** total_floor_area,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Aspect ratio (width/length; width faces south before rotation)

**Name:** aspect_ratio,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Rotation (degrees clockwise)

**Name:** rotation,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Number of above grade floors

**Name:** above_grade_floors,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Floor to floor height (m)

**Name:** floor_to_floor_height,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Plenum height (m), or Enter '0.0' for No Plenum

**Name:** plenum_height,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Check for sideload files (to overwrite standards info)?

**Name:** sideload,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
