* Example NECB PAT project

This folder contains an example PAT project that is configured to run all the NECB archetype models in 
a broad range of Canadian locations. The purpose of this model is two fold:
1. To provide an example of using the repo's measures and functionality
2. To provide a method to test the effects on outputs when the Openstudio/EnergyPlus tool
chain is updated.

** How to use
To run the model first you need to start an instance of the openstudio-server contained in this
repository. 

Once the server instance is running open PAT (use the default version from NREL) and open the 
model contained in tis folder. Select the option to run the analysis on a remote server (even if 
the server instance is on the same physical comupter as PAT is running on) and point it to the IP 
address reported when the server is initialized.

Everything should run (it will take a few hours).

** Regression testing notes

*** Openstudio-Standards version 3.0.1
This repository was iinitially developed using v 3.0.1 as the baseline. Results from running this PAT model are
contained in OS-3.0.1-results.xlsx.

*** Openstudio-Standards version 3.2.1
Updating to v 3.2.1 resulted in significant differences in results for the medium office archetype model. This was traced
to a bug fix in EnergyPlus in the fan model (for details see https://github.com/NREL/EnergyPlus/pull/8401). 
Full results are i the file OS-3.2.1-results.xlsx and the analysis between the two versions in analysis.xlsx.

*** Openstudio-Standards version 3.2.1
Updating to v 3.2.1.a resulted in minor differences in results for the majority of models. Known changes in this update 
relate to the completion of the NECB2020 ruleset (several rules were corrected to match the published code). The largest 
differences observed are related to the MURB model. It is believed this is due to changes in the archetype definition made by NRCan. 
Full results are i the file OS-3.2.1.a-results.xlsx and the analysis between the two versions in analysis.xlsx.