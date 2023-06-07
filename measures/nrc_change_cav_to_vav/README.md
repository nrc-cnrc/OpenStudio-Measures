

###### (Automatically generated documentation)

# NrcChangeCAVToVAV

## Description
This measure turns constant air volume (CAV) to variable air volume (VAV) systems. This measure will automatically skip air loops
            that already contain a VAV fan.

## Modeler Description
This measure loops through every AirLoopHVAC object and replaces the CAV fan with a VAV fan (OS default efficiency), and sets a new setpoint:warmest
             if the original air loop uses a scheduled or SingleZoneReheat setpoint manager (or other managers as selected by the user)

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Enter name of air loops (separated in commas) to switch from CAV to VAV, 'AllAirLoops', or 'SkipAllAirLoops'

**Name:** airLoopSelected,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Enter a sepoint manager to be used

**Name:** user_defined_spm,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
