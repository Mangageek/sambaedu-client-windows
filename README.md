# sambaedu-client-windows
Installation et mise au domaine automatique des clients windows.

Ce paquet permet l'installation totalement automatisée de Windows 10, la mise au domaine, ainsi que la préparation pré et post-clonage. Il remplace le paquet se3-domscripts qui ne doit plus être utilisé pour Windows 10.

## Principe
Les opérations sont lancées à distance depuis l'interface SE3. Si nécessaire le nom de la machine sera demandé lors de l'installation.
La configuration windows installée est optimisée pour le cas d'usage d'un domaine se3. Il est possible de la personnaliser en modifiant les fichiers .xml soit manuellement soit avec les outils Windows de configuration d'image système.

## Intégration au domaine d'un poste déjà installé
*Il est possible d'intégrer un poste déjà installé. Néanmoins sysprep est assez chatouilleux, et donc le succès n'est pas garanti !*
- depuis l'interface se3, menu dhcp-> intégrer. Ne fonctionnera que si le poste a déjà l'UAC desactivée.
- sur le poste, en administrateur, connecter le lecteur `z:` à `\\se3\install` et lancer  `z:\os\netinst\rejointse3.cmd`, ou lancer directement `\\se3\install\os\netinst\rejointse3.cmd`
- il est possible renommer un poste déjà intégré : menu dhcp->renommer un poste windows. 

## prérequis pour une installation totalement automatique
- sources d'installation Windows installées dans z:\os\Win10
- pilotes reseau et disques injectés dans l'image wim https://github.com/SambaEdu/sambaedu-client-windows/blob/master/preparation_image.md
- postes provisionnés dans l'annuaire:  le triplet nom;ip;mac est renseigné et la machine appartient à un parc.
- BIOS configurés pour booter en PXE (pas d'UEFI)

*Si le poste n'a pas d'ip réservée, l'installation se fera avec le dernier nom connu.*
## prérequis pour une installation manuelle

- sources d'installation Windows installées dans z:\os\Win10
- pilotes reseau et disques injectés dans l'image wim  https://github.com/SambaEdu/sambaedu-client-windows/blob/master/preparation_image.md
- BIOS configurés pour booter en PXE (pas d'UEFI)
- démarrer en pxe et taper "i"



## solutions pour le clonage
- depuis l'interface clonage avec sysrescued+ntfsclone : choisir seven64, normalement cela doit fonctionner à tout les coups si l'installation initiale est faite par  ce paquet !
- clonezilla ou autres : non testé, mais il suffit de cloner le poste une fois qu'il a exécuté sysprep. Le retour au domaine sera automatique. Lancer `z:\os\netinst\se3sysprep.cmd` 
- il est possible de cloner des machines différentes, dans la mesure où l'image windows inclut les drivers réseau et disques correspondant aux différents hardwares

## A faire

- **Attention, pour le moment le paquet installe Windows sur tout le disque, en ecrasant tout !** Il faudrait prévoir une page dans l'interface pour pouvoir définir un partitionnement.
- La mise au domaine et le clonage via sysprep ne fonctionne que si le poste a été correctement installé au départ. Identifier les problèmes et proposer un script de réparation préalable ?
- Migrer le boot chaîné pxelinux->ipxe vers ipxe uniquement
- afficher en temps réel les infos sur les opérations d'installation et  de clonage en cours côté serveur
- gestion des clés de licences Windows dans le cas de migrations ?
- rendre la mise au domaine moins chatouilleuse.
- ajouter la possibilité d'ajouter des drivers OEM


