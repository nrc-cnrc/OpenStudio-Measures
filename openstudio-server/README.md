This folder contains the scripts used to create a local openstudio server.

### Requirements
The server will be configured to use 1/2 of the available cores on the host machine (or NCPU-5 whichever is less). The minimum number of 
cores required is eight but more is better, likewise with memory (at least 16 GB is recommended). 

### Usage
1) Variables are set in the env.sh file. These will be used by the subsequent scripts and you should not need to adjust them. 
2) Start the server using the *1-configure-start_server.sh* script.

If you need to stop the server use *2-stop_server.sh* and restart with *3-restart-server.sh*. To remove all the containers, images etc created 
by docker and these scripts use *0-remove-existing-server.sh*.

To link to the server from PAT:
1) If using PAT on the same machine as the server is running link to 'https://localhost/:8080'
2) If using PAT from remote machine (recommended) link to 'https:/IP_address_of_remote_machine/:8080'


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
