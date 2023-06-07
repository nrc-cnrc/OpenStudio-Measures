

###### (Automatically generated documentation)

# NrcReportHourlyGhgEmissions

## Description
This reporting measure calculates the hourly GHG emissions.

## Modeler Description
The measure only calculates the hourly GHG emissions related to electrical use. Only the hourly emission factors for electricity
            in Ottawa, Toronto, and Windsor for 3 years ( 2016, 2017 and 2018) are available.
            One flat yearly natural gas emission factor of 0.18 kgCO2e/kWh is used, or it could be updated by the user.
            The stat weather files were obtained from 'https://climate.onebuilding.org/WMO_Region_4_North_and_Central_America/CAN_Canada/index.html'.
            In order to use this measure, the 'nrc_set_hourly_weather_file' measure has to be used first to set the hourly weather files.
            The units of emission factors in the 'hourlyEmissionsFactors.csv' file are in 'gCO2eq/kWh', the units of EUI consumption in the output file '*_hourly_eui_baseLoad.csv'
            are all in 'kWh', and the units of emissions in the output file '*_hourly_emissions_baseLoad.csv' are all in 'tCO2eq'.

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments


### Natural gas emission factor (kg CO2e/kWh)

**Name:** ng_emissionFactor,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false




