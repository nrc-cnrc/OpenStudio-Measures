

###### (Automatically generated documentation)

# Set Infiltration Rate

## Description
This measures allows setting the infiltration to a specific value at a given reference pressure. The flow rate is 
       converted to the flow at 5 Pa for above grade surfaces as per the assumption in the NECB.

## Modeler Description
The measure sets space infiltration according to PCF 1414, section 8.4.2.9(2), page 7
            Infiltration_5Pa = C × I_75Pa × (S/A)
            Infiltration_5Pa : Air leakage rate of the building envelope at 5 Pa, in L/(s·m2)
            C = (5 Pa / 75 Pa)n , where n = flow exponent
            I_75Pa : Normalized air leakage rate at 75 Pa, in L/(s·m2)
            S = total area of the building envelope (the lowest floor area + below-ground and above-ground walls area + roof area (including
                vertical fenestration and skylights) , in m2
            A = total area of above-grade walls, in m2
            To neglect the surface area adjustment enter two identical numers for above grage and total surface area.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Space Infiltration Flow per Exterior Envelope Surface Area L/s/m2 at reference pressure

**Name:** flow_rate,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Reference pressure

**Name:** reference_pressure,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Flow exponent

**Name:** flow_exponent,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Total surface area (m2), please type 0.0 to use value from model

**Name:** total_surface_area,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Above grade wall surface area (m2), please type 0.0 to use value from model

**Name:** above_grade_wall_surface_area,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false





## Outputs




calculated_infiltration_rate


## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
