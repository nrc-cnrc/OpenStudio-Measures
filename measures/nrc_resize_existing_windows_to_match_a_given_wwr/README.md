

###### (Automatically generated documentation)

# Nrc Resize Existing Windows To Match A Given WWR

## Description
This measure aims to resize all of the existing windows in order to produce a specified, user-input, window to wall ratio.
The windows will be resized around their centroid.
It should be noted that this measure should work in all cases when DOWNSIZING the windows (which is often the need given the 40% WWR imposed as baseline by ASHRAE Appendix G).
If you aim to increase the area, please note that this could result in subsurfaces being larger than their parent surface

## Modeler Description
This measure is measure was retrieved from - https://bcl.nrel.gov/ (original author Julien Marrec ) and was modified by the NRC.
NRC modifications : cz_#_fdwr variables,remove_skylight variable,  set checkwall variable to default 'false', check model climate zone file before placing cz_#fdwr into variable 'wwr_after', loop to remove skylights
Added test.rb
The measure works in several steps:

1. Find the current Window to Wall Ratio (WWR).
This will compute the WWR by taking into account all of the surfaces that have all of the following characteristics:
- They are walls
- They have the outside boundary condition as 'Outdoors' (aims to not take into account the adiabatic surfaces)
- They are SunExposed (could be removed...)

2. Resize all of the existing windows by re-setting the vertices: scaled centered on centroid.


## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Remove skylights?

**Name:** remove_skylight,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate zone 4 FDWR

**Name:** cz_4_fdwr,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate zone 5 FDWR

**Name:** cz_5_fdwr,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate zone 6 FDWR

**Name:** cz_6_fdwr,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate zone 7A FDWR

**Name:** cz_7A_fdwr,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate zone 7B FDWR

**Name:** cz_7B_fdwr,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate zone 8 FDWR

**Name:** cz_8_fdwr,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Only affect surfaces that are 'walls'?

**Name:** check_wall,
**Type:** Boolean,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Only affect surfaces that have boundary condition = "Outdoor"?

**Name:** check_outdoors,
**Type:** Boolean,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Only affect surfaces that are "SunExposed"?

**Name:** check_sunexposed,
**Type:** Boolean,
**Units:** ,
**Required:** false,
**Model Dependent:** false






## Automated Testing
A summary of the arguments and values used in the automated testing of this measure is [here](./tests/README.md).
