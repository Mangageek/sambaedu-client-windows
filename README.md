# sambaedu-client-windows
Installation et mise au domaine automatique des clients windows.


## Objectifs

Ce paquet permet l'installation totalement automatisée de Windows 10, la mise au domaine, ainsi que la préparation pré et post-clonage de Windows 7 à 10.

Il remplace le paquet se3-domscripts **qui ne doit plus être utilisé pour Windows 7 à 10**. Ce paquet n'est conservé temporairement que pour les XP survivants.


## Principe

Les opérations sont lancées à distance depuis l'interface SE3. Si nécessaire le nom de la machine sera demandé lors de l'installation.

La configuration windows installée est optimisée pour le cas d'usage d'un domaine se3. Il est possible de la personnaliser en modifiant les fichiers .xml soit manuellement soit avec les outils Windows de configuration d'image système.


## Intégration au domaine d'un poste déjà installé 7 et 10

*Il est possible d'intégrer un poste déjà installé. Néanmoins il est préférable dans la mesure du possible de refaire une installation automatique afin d'être sûr à 100% de la configuration installée.*

__Attention__ il faut absolument utiliser un "vrai" compte administrateur. Après une installation manuelle, le compte administrateur est désactivé, et donc l'intégration ne fonctionnera pas car le compte créé lors de l'installation n'a pas tous les privilèges requis. Il faudra donc commencer par réactiver le compte administrateur... Si vous ne savez pas faire faites une installation automatique !

- depuis l'interface se3, menu dhcp-> intégrer. __Attention__ Ne fonctionnera que si le poste a déjà l'UAC et les firewalls desactivés.
- sur le poste, en administrateur local, lancer directement `\\se3\install\os\netinst\rejointse3.cmd`. Le compte à utiliser de préférence pour connecter le lecteur réseau est `adminse3` 
- lors de l'installation, le script propose un nom de machine, et optionnellement d'utiliser sysprep. Si le poste est issu d'un master région tout juste déballé du carton, c'est normalement inutile. En revanche si le poste a déjà servi, c'est conseillé pour bien réinitialiser les comptes locaux et les droits. Si sysprep échoue, vous pouvez recommencer avec l'autre méthode !  

- il est possible renommer à distance un poste déjà intégré : menu dhcp->renommer un poste windows. 


## Installation automatique 10

Avec les Windows 10 récents, il s'agit de la seule façon fiable et reproductible d'installer des postes qui pourront être facilement clonés ensuite. En voulant gagner du temps à réutiliser une installation faite manuellement vous allez en perdre beaucoup à comprendre pourquoi cela ne fonctionne pas... Si vous voulez cloner ensuite, l'installation automatique est vivement conseillée car le Sysprep nécessaire lors du clonage ne fonctionnera pas tant que le poste ne se sera pas totalement mis à jour, ce qui peut être très long !

### Prérequis pour une installation totalement automatique à distance

- sources d'installation Windows installées dans z:\os\Win10
- pilotes reseau et disques injectés dans l'image wim : [préparation de l'image](preparation_image.md#préparation-de-limage-windows-dinstallation)
- postes provisionnés dans l'annuaire:  le triplet nom;ip;mac est renseigné et la machine appartient à un parc.
- BIOS configurés pour booter en PXE (pas d'UEFI)

*Si le poste n'a pas d'ip réservée, l'installation se fera avec le dernier nom connu.*


### prérequis pour une installation automatique devant le poste

- sources d'installation Windows installées dans z:\os\Win10
- pilotes reseau et disques injectés dans l'image wim [préparation de l'image](preparation_image.md#préparation-de-limage-windows-dinstallation)
- BIOS configurés pour booter en PXE (pas d'UEFI)
- démarrer en pxe et taper "i"


## Personnalisation du partitionnement :

 **Attention, pour le moment le paquet installe Windows sur tout le disque, en ecrasant tout !**
 
 Il est toutefois possible de modifier le partitionnement en se référant à la documentation suivante :  
 https://technet.microsoft.com/fr-fr/library/dd744365(v=ws.10).aspx
 
 Le fichier /var/unattend/install/os/netinst/unattend.xml devra être modifié en conséquence.
 
## Pilotes

les pilotes vidéo, son, etc. Peuvent être installés automatiquement lors de l'installation. Il suffit pour cela de les copier dans `z:\\se3\install\os\drivers`. Attention, il ne faut copier QUE les drivers 64  bits Windows 10, c'est à dire le dossier contenant le fichier `.inf`. Les utilitaires divers ne seront pas installés de cette manière.

## solutions pour le clonage 7 et 10

- depuis l'interface clonage avec sysrescued+ntfsclone : choisir seven64, normalement cela doit fonctionner à tout les coups si l'installation initiale est faite par  ce paquet !
- clonezilla ou autres : non testé, mais il suffit de cloner le poste une fois qu'il a exécuté sysprep. Le retour au domaine sera automatique. Lancer `\\se3\install\os\netinst\rejointse3.cmd` avant le clonage, et lancer la solution de clonage une fois que le poste est préparé.
- si le poste a été préparé avec sysprep (par défaut pour Windows 10), il est possible de cloner des machines différentes, dans la mesure où l'image windows inclut les drivers réseau et disques correspondant aux différents hardwares


## À faire

- Il faudrait prévoir une page dans l'interface pour pouvoir définir un partitionnement personnalisé.
- Migrer le boot chaîné pxelinux->ipxe vers ipxe uniquement
- afficher en temps réel les infos sur les opérations d'installation et  de clonage en cours côté serveur
- gestion des clés de licences Windows dans le cas de migrations ?
- ajouter la possibilité d'ajouter des drivers OEM


