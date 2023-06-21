# Openstudio Measures

 🇫🇷 [Français](#mesures-openstudio)

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

### 1. Measures
Users interested in using the [measures](/measures) in this repository may directly apply them on their own machine using [OpenStudio Application](https://openstudiocoalition.org/) or [OpenStudio-PAT](https://github.com/NREL/OpenStudio-PAT/releases).

### 2. OpenStudio-Server
In order to set up, configure, and deploy the OpenStudio-Server for large scale simulation, refer to the instructions [here](/openstudio-server).

### 3. Testing environment
The environment is intended for developers to test their code before contributing it to the repository. Please refer to our [contribution guidelines](#how-to-contribute).

The content of this repository is maintained to be consistent, i.e. the measures will be maintained to work with the version of OpenStudio-Server that the repository creates. This way users can be sure that the measures will work on their projects.

### 4. Additional information
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

# Mesures OpenStudio

Ce dépôt regroupe des mesures OpenStudio, ainsi qu'un environnement de test et de simulation. Elles sont utilisées par notre équipe de recherche du CNRC dans diverses activités, et nous les partageons avec l'espoir qu'elles pourront être utiles à d'autres au Canada et au-delà. En partageant ces mesures, nous voulons rendre notre travail plus transparent et soutenir l'industrie canadienne en accélérant l'utilisation de la simulation de bâtiments à travers le pays.

**Remarque:** ces mesures *peuvent* fonctionner avec les [applications OpenStudio et PAT](https://www.openstudio.net/downloads) de NREL, par défaut. Cependant, certaines fonctionnalités nécessitent une version spécifique d'`openstudio-server` créée par les scripts `server` dans ce dépôt.

Le projet principal qui soutient le développement de ces mesures est notre support aux décideurs impliqués dans le [Code national de l'énergie pour Bâtiments](https://nrc.canada.ca/fr/certifications-evaluations-normes/codes-canada/publications-codes-canada). Nous invitons ceux qui souhaitent évaluer d'éventuels changements au *Code* à utiliser ces mesure dans leurs modèles, à les modifier, les varier, etc., afin  de recueillir davantage de données probantes à l'intention des décideurs.

Nous entretenons ce dépôt de manière cohérente, c'est-à-dire de manière à ce que les mesures fonctionnent avec la version d'`openstudio-server` générée ici. Ainsi, les utilisateurs peuvent se fier au fait que les mesures demeureront compatibles avec leurs projets respectifs.


### Contexte et liens avec des projets connexes

Ce référentiel s'appuie sur les fonctionnalités intégrées à OpenStudio. Cette fonctionnalité a été étendue par d'autres groupes via diverses collections de "mesures", par exemple celles contenues dans la [Building Component Library](https://bcl.nrel.gov/) et l'initiative [BTAP](https://github.com/canmet-energy/btap) de RNCan. Ce référentiel contient des mesures provenant de diverses sources:

- Copié de la BCL. Ces copies sont contenues ici pour faciliter l'utilisation car PAT ne fait référence qu'à un seul dossier lors de la recherche de mesures. Leurs noms débutent par `bcl_`. La licence BCL standard est contenue dans le dossier de mesure.

- Copié depuis BTAP. Ces copies sont contenues ici pour faciliter l'utilisation car PAT ne fait référence qu'à un seul dossier lors de la recherche de mesures. Leurs noms débutent par `btap_`. La licence BTAP standard est contenue dans le dossier de mesure.

- Dérivé de BCL/BTAP. Ces mesures ont été modifiées par rapport aux versions originales pour fonctionner avec la version d'`openstudio-server` ou pour fournir une fonctionnalité spécifique. De plus, les mesures ont été modifiées pour utiliser la fonctionnalité de la mesure modèle – cela fournit plus des tests cohérents et robustes que ceux qui sont autrement présents dans de nombreuses mesures BCL. Leurs noms débutent par `nrc_` et la mesure d'origine est citée dans la section "infos sur le modélisateur" de la mesure.

- Contenu original. Ces mesures ont été créées par le CNRC à l'aide du modèle de mesure. Leurs noms débutent par `nrc_`.

L'intention générale est de compléter les travaux existants dans ce domaine et de fournir un soutien supplémentaire à l'industrie et la transparence de notre travail. À cette fin, nous sommes disposés à discuter d'accords de licence distincts en plus de la LGPLv3 par défaut, bien que nous puissions être limités par le licence originale pour le contenu dérivé. Des restrictions spécifiques concernent l'utilisation du modèle de mesure (qui est dérivé du code LGPLv2 dans les normes openstudio et les mesures BTAP sous licence GPLv2; en général, les mesures BCL ont une licence non restrictive bien que beaucoup n'aient pas de licence spécifique).

De plus, la bibliothèque utilise le référentiel [openstudio-standards](https://github.com/NREL/openstudio-standards). Le "contenu canadien" dans les normes openstudio est maintenu par RNCan avec des contributions du CNRC et d'autres. Plus précisément, nous utilisons la branche `nrcan_nrc` dans ce référentiel qui est dérivé de la branche `nrcan`. Cela nous permet de tester les modifications apportées à la branche `nrcan` avant de mettre à jour la branche `nrcan_nrc` pour nous assurer que les mesures de ce référentiel fonctionnent toujours comme prévu. Les changements ajoutés à la branche `nrcan` sont finalement fusionnés dans la branche `master` de openstudio-standards (encore une fois, RNCan effectue des tests importants avant de mettre à jour sa branche et d'y apporter des modifications).

### Exigences

Nous utilisons tortoise git pour installer la fonctionnalité git, puis utilisons le shell git bash pour interagir avec ce référentiel – nous vous recommandons de le faire le même. Nous travaillons également sur le système d'exploitation Windows 10 (nous avons des scripts plus anciens qui fonctionnaient sur Win7 mais ne les maintenons plus). L'environnement de test et de simulation est construit sur des conteneurs Docker (vous devrez télécharger [Docker Desktop](https://www.docker.com/)). Le les scripts des dossiers testing et server doivent être exécutés dans un shell git bash. Ils téléchargeront et installeront les conteneurs nécessaires et exécutez les applications nécessaires - suivez les instructions de chaque dossier pour configurer [exécuter les tests](test/README.md) ou [le serveur](openstudio-server/README.md).


## Support technique

Il n'y a pas de support explicite pour l'utilisation de ce dépôt. Si vous prévoyez l'utiliser, veuillez nous contacter et nous nous efforcerons d'éclaircir ou de corriger les aspects portant à confusion. Si vous trouvez un bogue ou si une fonctionnalité ne fonctionne pas comme prévu, veuillez le signaler au moyen d'un [*Issue*](https://github.com/nrc-cnrc/OpenStudio-Measures/issues).

## Comment contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md)

## Licence

Sauf indication contraire, le code source de ce projet est protégé par le droit d'auteur de
la Couronne du gouvernement du Canada et distribué sous la [licence LGPLv3](LICENSE).
