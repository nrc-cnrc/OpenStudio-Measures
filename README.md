# OpenStudio-Measures
([Français](#openstudio-measures))

This repository is a collection of [OpenStudio measures](https://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/), testing and simulation environment. The tools are used by NRC research staff in various activities. By sharing these tools, we aim to increase transparency in the work we are conducting to support Canadian industry, accelerate the 
use of building simulation across the country, and hope they will prove to be useful for others further afield.

The primary project supporting the development of these measures is our support for decision makers in the [National Energy Code for 
Buildings](https://nrc.canada.ca/en/certifications-evaluations-standards/codes-canada/codes-canada-publications). We encourage those wanting to 
evaluate potential changes to the code to use and modify these measures, apply them to their models, etc to increase the evidence available for 
decision makers. 


Note: the measures *may* work in the default [OpenStudio and PAT apps](https://www.openstudio.net/downloads) from the official NREL site, however some functionality 
will require the specific version of OpenStudio-Server created by the ‘server’ scripts within this repository.

## How to use this repository
There are three main parts to this repository:

#### 1. Measures
Users interested in using the [measures](/measures) in this repository may directly apply them on their own machine using [OpenStudio Application](https://openstudiocoalition.org/) or [OpenStudio-PAT](https://github.com/NREL/OpenStudio-PAT/releases).

#### 2. OpenStudio-Server
In order to set up, configure, and deploy the OpenStudio-Server for large scale simulation, refer to the instructions [here](/openstudio-server).

#### 3. Testing environment
The environment is intended for developers to test their code before contributing it to the repository. Please refer to our [contribution guidelines](#how-to-contribute).

The content of this repository is maintained to be consistent, i.e. the measures will be maintained to work with the version of OpenStudio-Server that the repository creates. This way users can be sure that the measures will work on their projects.

#### 4. Additional information 
- This repository relies on other actively developed projects; therefore, updates to dependencies done periodically. More information is available in [MAINTENANCE.md](MAINTENANCE.md).
- More background information on this project, motivation, OpenStudio, and FAQ can be found in the wiki.

## Linkages to related projects
This repository builds on the functionality built into OpenStudio. This functionality has been expanded by other groups via various collections 
of ‘measures’, for example as contained in the [Building Component Library](https://bcl.nrel.gov/) and the [BTAP](https://github.com/canmet-energy/btap) initiative from 
NRCan. This repository contains measures from various sources:
-	Copied from the BCL. These copies are contained here for ease of use as PAT only refers to a single folder when searching for measures.
Their names are prefixed with ‘bcl_’. The standard BCL license is contained in the measure folder.
-	Copied from BTAP. These copies are contained here for ease of use as PAT only refers to a single folder when searching for measures.
Their names are prefixed with ‘btap_’. The standard BTAP license is contained in the measure folder.
-	Derived from BCL/BTAP. These measures have been modified from original versions to work with the version of openstudio-server or to provide
specific functionality. Additionally the measures have been modified to use the functionality of the template measure – this provides more
consistent and robust testing than is otherwise present in many BCL measures. Their names are prefixed with ‘nrc_’ and the original measure
is referenced in the ‘modeller info’ section of the measure.
-	Original content. These measures were created by NRC using the template measure. Their names are prefixed with ‘nrc_’.

The overall intent is to complement existing work in this area and provide additional support to industry and transparency in our work. To this 
end we are more than willing to discuss separate licensing arrangements in addition to the default LGPLv3 although we may be restricted by the 
original licensing for derived content. Specific restrictions relate to the use of the template measure (which is derived from LGPLv2 code in 
OpenStudio-Standards and BTAP measures which are licensed under GPLv2; in general BCL measures have a non-restrictive license although many have 
no specific license).

In addition the measures also make use of the [OpenStudio-Standards](https://github.com/NREL/openstudio-standards) repository. The ‘Canadian content’ 
in OpenStudio-Standards is maintained by NRCan with contributions from NRC and others. Specifically we use the [nrcan_nrc](https://github.com/NREL/openstudio-standards/tree/nrcan_nrc) branch in this repository 
which is branched off the nrcan branch. This allows us to test changes made to the nrcan branch before updating the nrcan_nrc branch to ensure that the 
measures in this repository still function as intended. The changes added to the nrcan branch are eventually merged into the master branch of 
OpenStudio-Standards (again NRCan conduct significant testing before updating their branch and committing changes to their branch).

## Support
There is no explicit support for use of this repository. However, if you plan on using the repository please contact us and we will endeavour to 
clarify/fix areas of confusion.
If you find a bug or a measure is not working please create an issue and submit via this website.

## How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Copyright

Unless otherwise noted, files in this project are covered under Crown Copyright,
Government of Canada:

```
Copyright (C) His Majesty the King in Right of Canada, as represented
by the National Research Council of Canada, 2020
```

## License

The source code in this project is distributed under the [LGPLv3 License](LICENSE),
which is an extension of the [GPLv3 License](https://www.gnu.org/licenses/gpl-3.0.html)

______________________

# Openstudio Measures

- Quel est ce projet?
- Comment ça marche?
- Qui utilisera ce projet?
- Quel est le but de ce projet?

### Comment contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md)

## Licence

Sauf indication contraire, le code source de ce projet est protégé par le droit d'auteur de
la Couronne du gouvernement du Canada et distribué sous la [licence LGPLv3](LICENSE).
