# Préparation de l'image Windows d'installation
## Téléchargement
Depuis un poste Windows 10, télécharger l'iso Windows 10 avec l'assistant de creation d'iso et la copier sur z:\os\iso. 
Lancer depuis l'interface se3 le script de configuration *TODO*, ou en terminal :
```
install-win-iso.sh nom_de_iso.iso
``` 
## Injection des pilotes

Une fois l'arborescence de l'iso copiée sur le partage du se3, l'ajout de drivers à l'image se fait depuis un poste W10 64Bits. Aucun outil n'est nécessaire. 
On ajoute uniquement les drivers indispensables pour l'installation (controleurs disques et réseau).

1 recherche de l'index du winpe
--------------------------------

```
Dism /Get-ImageInfo /ImageFile:z:\os\Win10\sources\boot.wim
```
```
Outil Gestion et maintenance des images de déploiement
Version : 10.0.15063.0
Détails pour l’image : z:\os\Win10\sources\boot.wim
Index : 1
Nom : Microsoft Windows PE (x64)
Description : Microsoft Windows PE (x64)
Taille : 1 680 843 005 octets
Index : 2
Nom : Microsoft Windows Setup (x64)
Description : Microsoft Windows Setup (x64)
Taille : 1 821 696 047 octets
```
Dans ce cas deux indexes, si on fait une installation, seul WinPE est indispensable. On choisit donc l'index 1

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
attention le chemin indiqué ne doit contenir que les drivers nécessaires sinon l'image va grossir très vite. Indiquer juste le dossier 64 bits contenant le .inf !  Répéter l'opération pour tous les drivers utiles (en général Intel et Realtek).

5 Démontage de l'image
----
```
Dism /Unmount-Image /MountDir:%temp%\wim /Commit
```


Normalement il n'est pas utile de répéter les opérations pour l'index 2 pour les drivers que vous voulez avoir en phase 2 (windows setup), et donc dans l'installation finale. 

Vu que le réseau est accessible ensuite on peut aussi passer directement des drivers depuis un partage réseau en utilisant unattended.xml, ce qui évite de charger l'image wim. 
 
