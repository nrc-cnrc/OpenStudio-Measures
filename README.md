([Français](#openstudio-measures))

This repository is a collection of [OpenStudio measures](https://www.openstudio.net/), testing and simulation environment. The measures are used by 
NRC research staff in various activities and are shared in the hope that they will prove to be useful for others in Canada and potentially further 
afield. By sharing these measures we hope to increase transparency in the work we are conducting to support Canadian industry and accelerate the 
use of building simulation across the country.

Note: the measures *may* work in the default [OpenStudio and PAT apps](https://www.openstudio.net/downloads) from NREL, however some functionality 
will require the specific version of openstudio-server created by the ‘server’ scripts in this repository.

The primary project supporting the development of these measures is our support for decision makers in the [National Energy Code for 
Buildings](https://nrc.canada.ca/en/certifications-evaluations-standards/codes-canada/codes-canada-publications). We encourage those wanting to 
evaluate potential changes to the code to use and modify these measures, apply them to their models, etc to increase the evidence available for 
decision makers. 

The content of this repository is maintained to be consistent, i.e. the measures will be maintained to work with the version of openstudio-server 
that the repository creates. This way users can be sure that the measures will work on their projects.

### Background and linkages to related projects
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
openstudio-standards and BTAP measures which are licensed under GPLv2; in general BCL measures have a non-restrictive license although many have 
no specific license).

In addition the library makes use of the [openstudio-standards](https://github.com/NREL/openstudio-standards) repository. The ‘Canadian content’ 
in openstudio-standards is maintained by NRCan with contributions from NRC and others. Specifically we use the nrcan_nrc branch in this repository 
which is branched off the nrcan branch. This allows us to test changes nade to the nrcan branch before updating the nrcan_nrc branch to ensure that the 
measures in this repository still function as intended. The changes added to the nrcan branch are eventually merged into the master branch of 
openstudio-standards (again NRCan conduct significant testing before updating their branch and committing changes to their branch).

### Requirements
We use tortoise git to install the git functionality and then use the git bash shell to interact with this repository – we recommend that you do 
the same. We also work on Windows 10 operating system (we have older scripts that worked on Win7 but no longer maintain these). 
The testing and simulation environment is built on Docker containers (you will need to download [Docker Desktop](https://www.docker.com/) ). The 
scripts in the testing and server folders should be executed in a git bash shell. They will download and set up the necessary containers and 
execute the necessary applications – follow the instructions in each folder to configure to [run the tests](test/README.md) or [the server](openstudio-server/README.md).

### Usage
The measures are designed and maintained to be used with the [OpenStudio tool PAT](https://www.openstudio.net/downloads) using the specific 
version of openstudio-server created by the scripts in the server folder.

### Install Docker and WSL2
Follow the instructions [here](./install_Docker_WSL2.md)

### Support
There is no explicit support for use of this repository. However, if you plan on using the repository please contact us and we will endeavour to 
clarify/fix area of confusion.
If you find a bug or a measure is not working please create an issue and submit via this website.

### How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md)

### License

Unless otherwise noted, the source code of this project is covered under Crown Copyright, 
Government of Canada, and is distributed under the [LGPLv3 License](LICENSE).

The Canada wordmark and related graphics associated with this distribution are protected under 
trademark law and copyright law. No permission is granted to use them outside the parameters of 
the Government of Canada's corporate identity program. For more information, 
see [Federal identity requirements](https://www.canada.ca/en/treasury-board-secretariat/topics/government-communications/federal-identity-requirements.html).

______________________

## Openstudio Measures

- Quel est ce projet?
- Comment ça marche?
- Qui utilisera ce projet?
- Quel est le but de ce projet?

### Installer Docker et WSL2
Suivez les instructions [ici](./install_Docker_WSL2.md)

### Comment contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md)

### Licence

Sauf indication contraire, le code source de ce projet est protégé par le droit d'auteur de 
la Couronne du gouvernement du Canada et distribué sous la [licence LGPLv3](LICENSE).

Le mot-symbole « Canada » et les éléments graphiques connexes liés à cette distribution sont 
protégés en vertu des lois portant sur les marques de commerce et le droit d'auteur. Aucune 
autorisation n'est accordée pour leur utilisation à l'extérieur des paramètres du programme 
de coordination de l'image de marque du gouvernement du Canada. Pour obtenir davantage de 
renseignements à ce sujet, veuillez consulter 
les [Exigences pour l'image de marque](https://www.canada.ca/fr/secretariat-conseil-tresor/sujets/communications-gouvernementales/exigences-image-marque.html).
