

###### (Automatically generated documentation)

# NrcReport

## Description
This measure generates a report  of the model supplied in html format.
     The report provides either summary or detailed view depending on the users choice.

## Modeler Description
This reporting measure generates an output report based on model information and EnergyPlus outputs.
     It provides general summary and detailed information on the building. Output includes construction and envelope
     description and details. Also, includes both an annual summary and monthly detailed heat gains and losses tables.
     In addition, the report provides high level tables of thermal zones and HVAC air loops.
     In this measure, windows areas will only be included in the calculations for fenestration door wall ratio,
     as there are no doors in the models.
     The heat loss and gain section is modified from BCL measure (https://bcl.nrel.gov/node/84747) to use si units.
     The HVAC detailed section is based on OpenStudio Results measure (https://bcl.nrel.gov/node/82918).
     The End Use table is modified from OpenStudio Results measure to create tables instead of charts

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments


### Report detail level

**Name:** report_depth,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include model_summary_section

**Name:** model_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include building_construction_detailed_section

**Name:** building_construction_detailed_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include construction_summary_section

**Name:** construction_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include heat_gains_summary_section

**Name:** heat_gains_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include heat_loss_summary_section

**Name:** heat_loss_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include heat_gains_section

**Name:** heat_gains_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include heat_losses_section

**Name:** heat_losses_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include steadySate_conductionheat_losses_section

**Name:** steadySate_conductionheat_losses_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include thermal_zone_summary_section

**Name:** thermal_zone_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include hvac_summary_section

**Name:** hvac_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include air_loops_detail_section

**Name:** air_loops_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include plant_loops_detail_section

**Name:** plant_loops_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include zone_equipment_detail_section

**Name:** zone_equipment_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include hvac_airloops_detailed_section1

**Name:** hvac_airloops_detailed_section1,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include hvac_plantloops_detailed_section1

**Name:** hvac_plantloops_detailed_section1,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Include hvac_zoneEquip_detailed_section1

**Name:** hvac_zoneEquip_detailed_section1,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false





## Outputs


















heating, cooling, electricity_consumption, natural_gas_consumption, district_heating, district_cooling, total_site_eui, eui
