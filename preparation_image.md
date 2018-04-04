# Préparation de l'image Windows d'installation

### Prérequis : 
- Un poste Windows 10, si possible au domaine, théoriquement il est aussi possible de faire la procédure depuis un Windows7 64, mais on n'a pas testé.
- Si le poste de préparation est déjà au domaine, se connecter en admin du domaine (compte admin). Sinon se connecter en administrateur local.
- si il n'est pas déjà connecté,  connecter `Z:` sur `\\se3\install` avec le compte `admin`. Attention adminse3 n'a pas les droits suffisants !
- un accès rapide à internet ou l'iso W10 déjà téléchargée.

## Téléchargement
Télécharger l'iso Windows 10 avec l'assistant de creation d'iso et la copier sur z:\os\iso. 
Lancer  en terminal root sur le se3 :
```
install-win-iso.sh nom_de_iso.iso
``` 
Il est également possible de copier directement les fichiers du DVD sur `Z:\os\Win10\`, mais il faut faire attention à bien copier les fichiers cachés et système.

_A ce stade il est possible de tester le bon fonctionnement de l'installation automatique. si elle échoue au moment du lancement de Windows Setup depuis le réseau, c'est qu'il faut injecter les pilotes réseau dans l'image._

## Injection des pilotes réseau si nécessaire

Il est à noter que cette étape n'est pas toujours nécessaire. En effet, les pilotes fournis par W10 étant assez nombreux, il y a de fortes chances que même sur des machines récentes, ces derniers suffisent. **En résumé, il faut tester une installation et vérifier si l'injection de pilotes supplémentaires est nécessaire ou pas !** 

Si vous êtes dans le cas ou vous devez ajouter des pilotes, voici la procédure :
Une fois l'arborescence de l'iso copiée sur le partage du se3, l'ajout de drivers à l'image se fait depuis un poste W10 64Bits. Aucun outil n'est nécessaire. 
On ajoute **uniquement** le driver indispensable pour l'installation (carte réseau la plupart du temps).

Il faut juste lancer un invite de commande en Administrateur pour lequel on montera au préalable le lecteur z: avec la commande
```
net use Z: \\se3\install
```
**Attention** ceci doit être fait avec un compte admin du se3 (il faut avoir les droits d'écriture sur install). Le compte adminse3 ne fonctionne pas !

1- vérification de l'index du winpe
--------------------------------

```
Dism /Get-ImageInfo /ImageFile:y:\os\Win10\sources\boot.wim
```
```
Outil Gestion et maintenance des images de déploiement
Version : 10.0.15063.0
Détails pour l’image : Z:\os\Win10\sources\boot.wim
Index : 1
Nom : Microsoft Windows PE (x64)
Description : Microsoft Windows PE (x64)
Taille : 1 680 843 005 octets
Index : 2
Nom : Microsoft Windows Setup (x64)
Description : Microsoft Windows Setup (x64)
Taille : 1 821 696 047 octets
```
Dans ce cas, deux indexes, si on fait une installation, seul WinPE est indispensable. On choisit donc l'index 1

2- montage de l'image
-------------------------

```
md %temp%\wim
Dism /Mount-Image /ImageFile:z:\os\Win10\sources\boot.wim /index:1 /MountDir:%temp%\wim
```

3- liste des drivers
--------------------
```
Dism /image:%temp%\wim /get-drivers
```
Sur l'image fraîchement téléchargée, cette commande doit renvoyer "aucun pilote"

4- ajout de drivers
---
Pour l'installation, Windows Setup a besoin de pouvoir monter le lecteur réseau pour accéder aux sources. Il faut donc ajouter les pilotes correspondant à la carte réseau. 

* Si le poste est fourni déjà installé, le plus simple est de regarder quels pilotes sont installés sur le poste avec le gestionnaire de périphériques. Sinon on peut booter SysRescueCD en PXE et regarder quels drivers Linux installe...
* télécharger les dernières versions des pilotes réseau chez les constructeurs (Intel, Broadcom, Realtek), ou éventuellement chez HP, Lenovo, Dell... Les liens de téléchargement changeant tout le temps faire une recherche avec votre moteur de recherche préféré...

* décompresser le pilote, et repérer le dossier 64 bits contenant le .inf
 et le copier dans un dossier temporaire (par exemple `c:\drivers\mon_driver`)
* intégrer le driver :
```
Dism /image:%temp%\wim /Add-Driver /Driver:c:\drivers\mon_driver /Recurse
```
_attention le chemin indiqué à la commande Dism ne doit contenir que les drivers nécessaires sinon l'image va grossir très vite. Indiquer juste le dossier 64 bits contenant le .inf identifié précédemment !_  

* Répéter l'opération pour toutes les machines différentes (en général 3 pilotes suffisent, Intel broadcom et Realtek).

5- Démontage de l'image
----
```
Dism /Unmount-Image /MountDir:%temp%\wim /Commit
```


Normalement il n'est pas utile de répéter les opérations pour l'index 2 pour les drivers que vous voulez avoir en phase 2 (windows setup), et donc dans l'installation finale. 

**NOTE :** 
Sur certaines machines (ex: Lenovo M710S), le driver doit cependant être injecté sur l'index 2 de l'image afin que l'installation automatique puisse se faire.

6- Autres drivers
---
Vu que le réseau est accessible ensuite on peut passer les drivers pour le reste du matériel (carte vidéo, son, chipset...) depuis le partage réseau  `z:\os\drivers`. 
La procédure est la suivante : 
* Si le poste est fourni déjà installé le plus simple est de regarder quels pilotes sont installés sur le poste. Sinon on peut booter SysRescueCD et regarder quels drivers Linux installe...
* télécharger les dernières versions des pilotes chez les constructeurs (Intel, AMD, Nvidia), ou éventuellement chez HP, Lenovo, Dell...
* décompresser le pilote dans un dossier temporaire, et repérer le dossier 64 bits contenant le .inf
* copier ce dossier dans `z:\os\drivers`
_attention le dossier ne doit contenir que les drivers nécessaires sinon l'image va grossir très vite. Indiquer juste le dossier 64 bits contenant le .inf identifié précédemment !_  

* Répéter l'opération pour toutes les machines différentes.

 
## FAQ
 - le poste reboote  juste après winpeini.shl : les drivers réseau ne sont pas bons. Attention à ne pas en injecter trop, certains sont incompatibles entre eux et vont empêcher le chargement. Il doit y avoir une seule version du driver pour un modèle de carte. Si vous avez un poste du même modèle déjà installé en 7 ou 10, il est possible avec dism de regarder les drivers effectivement chargés : 
 ```
 DISM.exe /Online /get-drivers
 ```
 - dans certains cas très particuliers, il faut injecter les pilotes des contrôleurs disques. 
 
