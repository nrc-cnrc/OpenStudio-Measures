

###### (Automatically generated documentation)

# nrc_set_srr

## Description
This measure sets the Skylight to Roof Ratio (SRR) according to the selected action.

## Modeler Description
The measure has a dropdown list to select specific pre-defined options. The options are :
    •	Remove the skylights
    •	Set skylights to match max SRR from NECB
    •	Don't change skylights
    •	Reduce existing skylight size to meet maximum NECB SRR limit
    •	Set specific SRR
    The Specific SRR argument is only used if the 'Set specific SRR' option is selected.
	
    This measure sets the SRR according to the NECB rules.
	
    The measure will detect the version of NECB automatically (default is NECB 2017).

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Select an option for SRR

**Name:** srr_options,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Set specific SRR (if option is selected above). Please enter a number greater than or equal to 0.0 and less than or equal to 1.0

**Name:** srr,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md). 
