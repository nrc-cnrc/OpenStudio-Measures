

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

### OsLib_Reporting.model_summary_section(nil,nil,nil,true)[:title]

**Name:** model_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.server_summary_section(nil,nil,nil,true)[:title]

**Name:** server_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.building_construction_detailed_section(nil,nil,nil,true)[:title]

**Name:** building_construction_detailed_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.construction_summary_section(nil,nil,nil,true)[:title]

**Name:** construction_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.heat_gains_summary_section(nil,nil,nil,true)[:title]

**Name:** heat_gains_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.heat_loss_summary_section(nil,nil,nil,true)[:title]

**Name:** heat_loss_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.heat_gains_detail_section(nil,nil,nil,true)[:title]

**Name:** heat_gains_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.heat_losses_detail_section(nil,nil,nil,true)[:title]

**Name:** heat_losses_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.steadySate_conductionheat_losses_section(nil,nil,nil,true)[:title]

**Name:** steadySate_conductionheat_losses_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.thermal_zone_summary_section(nil,nil,nil,true)[:title]

**Name:** thermal_zone_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.hvac_summary_section(nil,nil,nil,true)[:title]

**Name:** hvac_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.air_loops_detail_section(nil,nil,nil,true)[:title]

**Name:** air_loops_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.plant_loops_detail_section(nil,nil,nil,true)[:title]

**Name:** plant_loops_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.zone_equipment_detail_section(nil,nil,nil,true)[:title]

**Name:** zone_equipment_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.hvac_airloops_detailed_section1(nil,nil,nil,true)[:title]

**Name:** hvac_airloops_detailed_section1,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.hvac_plantloops_detailed_section1(nil,nil,nil,true)[:title]

**Name:** hvac_plantloops_detailed_section1,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.hvac_zoneEquip_detailed_section1(nil,nil,nil,true)[:title]

**Name:** hvac_zoneEquip_detailed_section1,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.output_data_end_use_table(nil,nil,nil,true)[:title]

**Name:** output_data_end_use_table,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.serviceHotWater_summary_section(nil,nil,nil,true)[:title]

**Name:** serviceHotWater_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.interior_lighting_summary_section(nil,nil,nil,true)[:title]

**Name:** interior_lighting_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.interior_lighting_detail_section(nil,nil,nil,true)[:title]

**Name:** interior_lighting_detail_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.daylighting_summary_section(nil,nil,nil,true)[:title]

**Name:** daylighting_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.exterior_light_section(nil,nil,nil,true)[:title]

**Name:** exterior_light_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### OsLib_Reporting.shading_summary_section(nil,nil,nil,true)[:title]

**Name:** shading_summary_section,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false





## Outputs


















heating, cooling, electricity_consumption, natural_gas_consumption, district_heating, district_cooling, total_site_eui, eui
