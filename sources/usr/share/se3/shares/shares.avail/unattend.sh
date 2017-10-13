#!/bin/bash
#shares_Vista: install
#action: start
#level: 10
# Script de connexion destine a creer un fichier contenant les infos necessaires a windows setup/sysprep
# fichier /install/os/machines/$machine.reg
# a partir  de l'ip on récupere le nom reservé  dans le dhcp car on veut pouvoir le changer lors de 
# l'installation Windows
#
if [ -z "$3" ]; then
        echo "Erreur d'argument."
        echo "$*"
        echo "Usage: unattend.sh utilisateur machine ip"
        exit
fi
# test pour les clients linux
regex_ip='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
machine=$(echo "$2" | grep -E "$regex_ip")

if [ -z "$machine" ]; then
    machine=$(echo "$2" | tr 'A-Z' 'a-z')
else
    machinetmp=`nmblookup -A $machine | sed -n '2p' | cut -d' ' -f1 | sed 's/^[ \t]*//;s/[ \t]*$//'`
    machine=$(echo "$machinetmp" | tr 'A-Z' 'a-z')
fi

ip=$3

# Dossier/fichier de log si nécessaire
DOSS_SE3LOG=/var/log/se3
mkdir -p $DOSS_SE3LOG
SE3LOG=$DOSS_SE3LOG/unattend.log

# recup parametres mysql
. /etc/se3/config_o.cache.sh

# recup parametres ldap
#. /etc/se3/config_l.cache.sh


# recherche d'une reservation pour cette machine
new_machine=$(echo "select name from se3_dhcp where ip = '$ip'" | mysql -h $dbhost $dbname -u $dbuser -p$dbpass | tail -n 1)

if  [ -z "$new_machine" ]; then
        new_machine=$(ldapsearch -xLLL "(ipHostNumber=$ip)" cn | grep "^cn:" | sed "s/^cn: \(.*\)$/\1/" | tail -n1)
        [ -z "$new_machine" ] && exit 0
fi

if [ "$machine" != "$new_machine" ];  then
        echo  "$new_machine
" > /var/se3/unattended/install/os/netinst/$machine.txt
        todos /var/se3/unattended/install/os/netinst/$machine.txt
        chown adminse3 /var/se3/unattended/install/os/netinst/$machine.txt
        echo "renommage de $machine en $new_machine">>$SE3LOG
else
        grep -l "$machine" /var/se3/unattended/install/os/netinst/*.txt 2>/dev/null | xargs rm -f 
fi
exit 0

