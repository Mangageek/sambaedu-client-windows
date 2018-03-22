# Préparation de l'image Windows d'installation

### Prérequis : 
- Un poste Windows 10, si possible au domaine, théoriquement il est aussi possible de faire la procédure depuis un Windows7 64, mais on n'a pas testé.
- être connecté en administrateur local sur le poste, ou en admin du domaine (compte admin).
- si il n'est pas déjà connecté,  connecter `Z:` sur `\\se3\install` avec le compte `admin`. Attention adminse3 n'a pas les droits suffisants !
- un accès rapide à internet ou l'iso W10 déjà téléchargée.

## Téléchargement
Depuis un poste Windows 10, télécharger l'iso Windows 10 avec l'assistant de creation d'iso et la copier sur y:\os\iso. 
Lancer  en terminal root sur le se3 :
```
install-win-iso.sh nom_de_iso.iso
``` 
Il est également possible de copier directement les fichiers du DVD sur `Z:\os\Win10\`, mais il faut faire attention à bien copier les fichiers cachés et système.

## Injection des pilotes

Une fois l'arborescence de l'iso copiée sur le partage du se3, l'ajout de drivers à l'image se fait depuis un poste W10 64Bits. Aucun outil n'est nécessaire. 
On ajoute uniquement les drivers indispensables pour l'installation (controleurs disques et réseau).

Il faut juste lancer un invite de commande en Administrateur dans lequel on montera au préalable le lecteur z: avec la commande
```
net use Z: \\se3\install
```
**Attention** ceci doit être fait avec un compte admin du se3 (il faut avoir les droits d'écriture sur install). Le compte adminse3 ne fonctionne pas !

1 vérification de l'index du winpe
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

2 montage de l'image
-------------------------

```
md %temp%\wim
Dism /Mount-Image /ImageFile:z:\os\Win10\sources\boot.wim /index:1 /MountDir:%temp%\wim
```

3 liste des drivers
--------------------
```
Dism /image:%temp%\wim /get-drivers
```

4 ajout de drivers
---
```
Dism /image:%temp%\wim /Add-Driver /Driver:c:\drivers /Recurse
```
attention le chemin indiqué ne doit contenir que les drivers nécessaires sinon l'image va grossir très vite. Indiquer juste le dossier 64 bits contenant le .inf !  Répéter l'opération pour tous les drivers utiles (en général Intel broadcom et Realtek).

5 Démontage de l'image
----
```
Dism /Unmount-Image /MountDir:%temp%\wim /Commit
```


Normalement il n'est pas utile de répéter les opérations pour l'index 2 pour les drivers que vous voulez avoir en phase 2 (windows setup), et donc dans l'installation finale. 

**NOTE :** 
Sur certaines machines (ex: Lenovo M710S), le driver doit cependant être injecté sur l'index 2 de l'image afin que l'installation automatique puisse se faire.

Vu que le réseau est accessible ensuite on peut aussi passer directement des drivers depuis un partage réseau en utilisant unattended.xml, ce qui évite de charger l'image wim. 
 
## FAQ
 - le poste reboote  juste après winpeini.shl : les drivers réseau ne sont pas bons. Attention à ne pas en injecter trop, certains sont incompatibles entre eux et vont empêcher le chargement. Il doit y avoir une seule version du driver pour un modèle de carte. Si vous avez un poste du même modèle déjà installé en 7 ou 10, il est possible avec dism de regarder les drivers effectivement chargés : 
 ```
 DISM.exe /Online /get-drivers
 ```
 
 
