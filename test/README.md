This folder contains the scripts used to run automated tests locally. Before submitting a merge request the test should be completed 
and all errors resolved!

### Requirements
As mentioned in the main readme the testing environment uses Docker containers. By default the testing uses 2/3 of the available cores 
on the host computer. 

### Usage
a) Variables are set in the env.sh file. These will be used by the subsequent scripts and you should not need to adjust them. 
b) The test environmnet is split into two parts: 
  1) Configure the Docker container (this puls the docker image for openstudio and sets up the docker container including downloads additional ruby gems).
  2) Run the tests (this checks for updates to the gems and then runs the tests).
c) When first configuring the environment run all three scripts in order. Once configured only script 2 needs to be used to re-run the tests.

Note the output from the tests. If a test fails read the output messages to determine why and update the measures.

______________________

## Openstudio Measures

- Quel est ce projet?
- Comment ça marche?
- Qui utilisera ce projet?
- Quel est le but de ce projet?

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
