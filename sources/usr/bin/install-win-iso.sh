#!/bin/bash
# script d'installation d'une iso Windows pour sambaedu-client-windows

iso="$1"
[ -z "$iso" ] && echo "vous devez donner le nom de du fichier iso dans os/iso" && exit 1
[ -f /mnt/iso ] || mkdir /mnt/iso
mount -o loop  "/var/se3/unattended/install/os/iso/$iso" /mnt/iso
cp -R /mnt/iso/* /var/se3/unattended/install/os/Win10/
#chown -R adminse3:admins /var/se3/unattended/install/os/Win10
chmod 666 /var/se3/unattended/install/os/Win10/sources/boot.wim
echo "Sources Windows installées. Vous devez maintenant injecter les drivers réseau
dans l'image de boot avec DISM depuis un poste windows 10" 
umount /mnt/iso
rm -fr /mnt/iso



