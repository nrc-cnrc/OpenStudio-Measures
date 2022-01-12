

###### (Automatically generated documentation)

# Report Utility Costs

## Description
This measure calculates utility costs for Canadian locations. By default a simple $/kWh tarrif can be applied but for 
	    several locations more complex rules are enabled.
		Peak values are reported averaged over the hour (the default LEED table produced by E+ reports the PEAK timestep value).

## Modeler Description
The measure creates a simple csv file and html output. The annual costs are available as output metrics for PAT.

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments


### Utility cost choice

**Name:** calc_choice,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Electricity rate ($/kWh)

**Name:** electricity_cost,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Natural gas rate ($/m3)

**Name:** gas_cost,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false





## Outputs












total_site_energy, annual_electricity_use, annual_natural_gas_use, annual_electricity_cost, annual_natural_gas_cost
