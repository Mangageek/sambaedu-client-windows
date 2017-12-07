# sambaedu-client-windows
Installation et mise au domaine automatique des clients windows.


## Objectifs

Ce paquet permet l'installation totalement automatisée de Windows 10, la mise au domaine, ainsi que la préparation pré et post-clonage de Windows 7 à 10.

Il remplace le paquet se3-domscripts **qui ne doit plus être utilisé pour Windows 7 à 10**. Ce paquet n'est conservé temporairement que pour les XP survivants.


## Principe

Les opérations sont lancées à distance depuis l'interface SE3. Si nécessaire le nom de la machine sera demandé lors de l'installation.

La configuration windows installée est optimisée pour le cas d'usage d'un domaine se3. Il est possible de la personnaliser en modifiant les fichiers .xml soit manuellement soit avec les outils Windows de configuration d'image système.


## Intégration au domaine d'un poste déjà installé 7 et 10

*Il est possible d'intégrer un poste déjà installé. Néanmoins sysprep est assez chatouilleux, et donc le succès n'est pas garanti Il faut que le poste soit à jour*

- depuis l'interface se3, menu dhcp-> intégrer. Ne fonctionnera que si le poste a déjà l'UAC desactivée.
- sur le poste, en administrateur, connecter le lecteur `z:` à `\\se3\install` et lancer  `z:\os\netinst\rejointse3.cmd`, ou lancer directement `\\se3\install\os\netinst\rejointse3.cmd`
- il est possible renommer un poste déjà intégré : menu dhcp->renommer un poste windows. 


## prérequis pour une installation totalement automatique 10

- sources d'installation Windows installées dans z:\os\Win10
- pilotes reseau et disques injectés dans l'image wim : [préparation de l'image](preparation_image.md#préparation-de-limage-windows-dinstallation)
- postes provisionnés dans l'annuaire:  le triplet nom;ip;mac est renseigné et la machine appartient à un parc.
- BIOS configurés pour booter en PXE (pas d'UEFI)

*Si le poste n'a pas d'ip réservée, l'installation se fera avec le dernier nom connu.*


## prérequis pour une installation manuelle

- sources d'installation Windows installées dans z:\os\Win10
- pilotes reseau et disques injectés dans l'image wim [préparation de l'image](preparation_image.md#préparation-de-limage-windows-dinstallation)
- BIOS configurés pour booter en PXE (pas d'UEFI)
- démarrer en pxe et taper "i"


## Personnalisation du partitionnement :

 **Attention, pour le moment le paquet installe Windows sur tout le disque, en ecrasant tout !**
 
 Il est toutefois possible de modifier le partitionnement en se référant à la documentation suivante :  
 https://technet.microsoft.com/fr-fr/library/dd744365(v=ws.10).aspx
 
 Le fichier /var/unattend/install/os/netinst/unattend.xml devra être modifié en conséquence.
 

## solutions pour le clonage 7 et 10

- depuis l'interface clonage avec sysrescued+ntfsclone : choisir seven64, normalement cela doit fonctionner à tout les coups si l'installation initiale est faite par  ce paquet !
- clonezilla ou autres : non testé, mais il suffit de cloner le poste une fois qu'il a exécuté sysprep. Le retour au domaine sera automatique. Lancer `\\se3\install\os\netinst\rejointse3.cmd` avant le clonage, et lancer la solution de clonage une fois que le poste est préparé.
- il est possible de cloner des machines différentes, dans la mesure où l'image windows inclut les drivers réseau et disques correspondant aux différents hardwares


## À faire

- Il faudrait prévoir une page dans l'interface pour pouvoir définir un partitionnement personnalisé.
- La mise au domaine et le clonage via sysprep ne fonctionne que si le poste a été correctement installé au départ. Identifier les problèmes et proposer un script de réparation préalable ?
- Migrer le boot chaîné pxelinux->ipxe vers ipxe uniquement
- afficher en temps réel les infos sur les opérations d'installation et  de clonage en cours côté serveur
- gestion des clés de licences Windows dans le cas de migrations ?
- rendre la mise au domaine moins chatouilleuse.
- ajouter la possibilité d'ajouter des drivers OEM


