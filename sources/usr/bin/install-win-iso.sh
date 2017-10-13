#!/bin/bash
# script d'installation d'une iso Windows pour sambaedu-client-windows

iso="$1"
[ -z "$1" ] && echo "vous devez donner le nom de du fichier iso dans os/iso" && exit 1
mkdir /mnt/iso
mount -o loop "/var/se3/unattended/install/os/iso/$1" /mnt/iso
cp -R /mnt/iso/* 
chown -R adminse3:admins /var/se3/unattended/install/os/Win10

echo "Sources Windows installées. Vous devez maintenant injecter les drivers réseau
dans l'image de boot avec DISM depuis un poste windows 10" 
umount /mnt/iso


