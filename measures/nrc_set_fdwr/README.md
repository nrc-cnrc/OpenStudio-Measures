

###### (Automatically generated documentation)

# Set FDWR

## Description
This measure sets the FDWR according to the selected rule.

## Modeler Description
The measure has a dropdown list to select specific pre-defined options. The options are :
    •	Remove the windows
    •	Set windows to match max FDWR from NECB
    •	Don't change windows
    •	Reduce existing window size to meet maximum NECB FDWR limit
    •	Set specific FDWR
    Specific FDWR is only used if the 'Set specific FDWR' option is selected.
    The measure will select the standards template from the model, but in case it was undefined a default value of 'NECB2017' will be used.
    The measure sets the FDWR according to NECB section 3.2.1.4 (2017 version)

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Select an option for FDWR

**Name:** fdwr_options,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Set specific FDWR (if option is selected above). Please enter a number greater than or equal to 0.0 and less than 1.0

**Name:** fdwr,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
