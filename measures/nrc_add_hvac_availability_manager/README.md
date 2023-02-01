

###### (Automatically generated documentation)

# Add HVAC Availability Manager

## Description
Adds the requested availability manager to the heating/cooling HVAC system.

## Modeler Description
Creates an availability manager and uses a outdoor air node as the sensed property.
            The "AvailabilityManagerLowTemperatureTurnOff" turns the system off if the temperature at the sensor node is below the specified setpoint temperature. Whereas the
            "AvailabilityManagerHighTemperatureTurnOff" turns the system off when the temperature at sensor node is higher than the specified setpoint temperature.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Apply to

**Name:** heatcool,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Turn off setpoint

**Name:** setPoint,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
