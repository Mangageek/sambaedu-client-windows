#!/bin/bash


# /usr/share/se3/scripts/sysprep.sh $action $name $ip $mac [$adminname $adminpasswd]
# ce script permet de sortir un poste du domaine si il y est deja, et de l'y remettre
# sous un autre nom.
# l'enregistrement ldap cn=machine est également mis à jour.  
#
# On utilise le mecanisme des GPO locales : copie d'un script shutdown.cmd par admin$,
# qui sort le poste du domaine et configure le demarrage au boot suivant, 
# copie dans %systemdrive%\netinst de tout ce qu'il faut pour la mise au domaine au reboot,
# puis on initie un reboot par rpc.
# 
# si cela foire, on lance se3sysprep.cmd depuis le poste.
# usage :
# sysprep.sh  rejoint  $nom $ip $mac [$adminame] [$passadmin]  : met au domaine
# sysprep.sh  renomme  $nom $ip $anciennom [$adminame] [$passadmin] : renomme
# sysprep.sh   clone    $nom $ip $mac [$adminame] [$passadmin] : prepare le clonage
# sysprep.sh   ldap    $nom $ip $mac    : met uniquement a jour le ldap
#

if [ -f  /home/netlogon/$3.lck ]; then 
    exit 0
fi
>/home/netlogon/$3.lck


function mkgpopasswd 
{
[ -f /home/netlogon/machine/$1 ] && rm -f /home/netlogon/machine/$1
[ ! -d /home/netlogon/machine/$1 ] && mkdir -p /home/netlogon/machine/$1
(
echo username=$1\\$adminname
echo password=$passadmin
)>$logondir/gpoPASSWD
chmod  600 $logondir/gpoPASSWD
chown adminse3 $logondir/gpoPASSWD
}

function uploadGPO # argument : $remotename $localname $remotedom 
{
mkgpopasswd $3
smbclient  //$ip/ADMIN$ -A /home/netlogon/machine/"$2"/gpoPASSWD << EOF
	mkdir \System32\GroupPolicy
	mkdir \System32\GroupPolicy\Machine
	mkdir \System32\GroupPolicy\Machine\Scripts
	mkdir \System32\GroupPolicy\Machine\Scripts\Startup
	mkdir \System32\GroupPolicy\Machine\Scripts\Shutdown
	put $logondir/shutdown.cmd \System32\GroupPolicy\Machine\Scripts\Shutdown\shutdown.cmd
	put $domscripts/startup.cmd \System32\GroupPolicy\Machine\Scripts\Startup\startup.cmd
	put $logondir/registry.pol \System32\GroupPolicy\Machine\registry.pol
	put $logondir/gpt.ini \System32\GroupPolicy\gpt.ini
	put /home/netlogon/scriptsC.ini \System32\GroupPolicy\Machine\Scripts\scripts.ini
    prompt OFF
#	rmdir \System32\GroupPolicy\User
	rm \tasks\wpkg.job  
EOF
	return $?
}
function setADM
{
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/gpt.ini" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/Machine" -C "$1\\administrateur" || return $?
#	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/Machine/registry.pol" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts/scripts.ini" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts/Startup" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts/Startup/startup.cmd" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts/Shutdown" -C "$1\\administrateur" || return $?
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts/Shutdown/shutdown.cmd" -C "$1\\administrateur" || return $?
	
}

function uploadDom # argument : $remotename $localname $remotedom 
{
mkgpopasswd $3
smbclient  //$ip/C$ -A /home/netlogon/machine/"$2"/gpoPASSWD << EOF
	mkdir Netinst
	mkdir Netinst\logs
	put $logondir/sysprep.txt Netinst\sysprep.txt
        put $logondir/action.txt Netinst\action.txt
        cd Netinst
	lcd $netinst
        prompt OFF
        mput -y *
EOF
return $?
}



function setACL
{
#	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/Machine/registry.pol" -a "ACL:adminse3:ALLOWED/0/FULL,ACL:SYSTEM:ALLOWED/0/FULL"
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/gpt.ini" -a "ACL:adminse3:ALLOWED/0/FULL,ACL:SYSTEM:ALLOWED/0/FULL"
	smbcacls //$ip/ADMIN$ -A /home/netlogon/machine/$2/gpoPASSWD  "/System32/Grouppolicy/Machine/Scripts/scripts.ini" -a "ACL:adminse3:ALLOWED/0/FULL,ACL:SYSTEM:ALLOWED/0/FULL"
	smbcacls //$ip/ADMIN$  -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/Machine/Scripts/Startup/startup.cmd" -a "ACL:adminse3:ALLOWED/0/FULL,ACL:SYSTEM:ALLOWED/0/FULL"
	smbcacls //$ip/ADMIN$  -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/Machine/Scripts/Shutdown/shutdown.cmd" -a "ACL:adminse3:ALLOWED/0/FULL,ACL:SYSTEM:ALLOWED/0/FULL"
	smbcacls //$ip/ADMIN$  -A /home/netlogon/machine/$2/gpoPASSWD "/System32/Grouppolicy/gpt.ini" -a "ACL:adminse3:ALLOWED/0/FULL"
}

function tryuploadgpo # remotename remotedom
{ 
                
                uploadGPO $1 $ip $2  >/dev/null  2>&1 
                if [ "$?" == "0" ]
                then
                    setADM $1 $ip
                    setACL $1 $ip
                    uploadDom $1 $ip $2 >/dev/null  2>&1
       	            cp $logondir/sysprep.txt /home/netlogon/machine/$oldname
    	            rm -rf $logondir

      	            if [ "action" == "clone" ]; then
    	                echo "clonage : la machine est prete<br>"
    	            else
    	                # on fait l'enregistrement ldap de la machine et on efface l'ancien si besoin
                        /usr/share/se3/shares/shares.avail/connexion.sh adminse3 $name $ip $mac
                        # /usr/share/se3/sbin/update-csv.sh
                    fi
                    /usr/bin/net rpc shutdown -t 30 -r -C "Action $action  : Le poste $oldname ($ip) va etre renomme $name avec $2/$adminname%XXXXXXX " -I $ip -U "$2/$adminname%$passadmin" 
    	            return 0 
                else
                    echo "integration a distance : connexion a $1 impossible avec $2/$adminname...<br>" 
                    return 1
                fi
}

# initialisation des variables
. /etc/se3/config_m.cache.sh

action="$1"
name=$(echo "$2" | tr 'A-Z' 'a-z')
ip="$3"

if [ -z "$5" ]; then
    adminname=adminse3
else
    adminname="$5"
fi
if [ -z "$6" ]; then 
    passadmin=$xppass
else
    passadmin="$6"
fi
if [ "$action" == "ldap" ]; then
    # on enregistre la machine dans la base ldap
    /usr/share/se3/shares/shares.avail/connexion.sh adminse3 $name $ip $4
#    /usr/share/se3/sbin/update-csv.sh
else    
    if [ "$action" == "rejoint" -o "$action" == "clone" ]; then
        oldname=$name
        mac="$4"
    else
        oldname=$(echo "$4" | tr 'A-Z' 'a-z')
    fi

    # on repere la machine par son iP et on copie les GPO de son ancien nom si elles existent
    netinst=/var/se3/unattended/install/os/netinst
    logondir="/home/netlogon/machine/$ip"
    [ -f "$logondir" ] && rm -f $logondir
    if [ ! -d "$logondir" ]; then
        mkdir -p $logondir
    fi
	rm -f $logondir/*
    /usr/share/se3/logonpy/logon.py adminse3 $ip XP 
    [ -f /home/netlogon/machine/$oldname ] && rm -f /home/netlogon/machine/$oldname
    if [ -d "/home/netlogon/machine/$oldname" ]; then 
	    cp "/home/netlogon/machine/$oldname/*" $logondir
	fi    
    echo -e "$name\r
">$logondir/sysprep.txt
        echo -e "$name\r
">$netinst/$ip.txt
        echo -e "$action\r
">$logondir/action.txt
    sed -e "s/ADMIN=__ADMIN__/ADMIN=$adminname/;s/PASSWD=__PASSWD__/PASSWD=${passadmin}/" $netinst/shutdown.cmd.in >$logondir/shutdown.cmd
    if [ ! -f "$logondir/gpt.ini" ]
    then
	cp -f /home/netlogon/gpt.ini $logondir/gpt.ini
    fi
    GPO_VERS="$(grep Version $logondir/gpt.ini|cut -d '=' -f2|sed -e 's/\r//g')"
    if [ -z "$GPO_VERS" ]; then 
	cp -f /home/netlogon/gpt.ini $logondir/gpt.ini
	GPO_VERS=268439552
    else	
	(( GPO_VERS+=268439552 ))
    fi
    sed -i "s/Version=.*/Version=$GPO_VERS\r/g" $logondir/gpt.ini

    chmod -R 755 $logondir
    chown -R adminse3 $logondir
    
    # Try to upload GPO
    # Sometime, Windows XP isn't ready to accept connexions on C$ (just after boot)
    # on essaie toutes les combinaisons ip/netbiosname.... 
    /usr/share/se3/sbin/tcpcheck 20 $ip:445 >/dev/null
    tryuploadgpo $oldname $oldname
    if [ "$?" == "1" ]; then  
        tryuploadgpo $ip $oldname
        if [ "$?" == "1" ]; then  
            tryuploadgpo $name $oldname
            if [ "$?" == "1" ]; then  
                tryuploadgpo $name $name          
                if [ "$?" == "1" ]; then  
                    echo "la mise au domaine ne peut pas se faire a distance.<br> Vous
devez la lancer depuis le poste.<br> Pour cela il faut lancer le script z:\\os\\netinst\se3sysprep.cmd 
en connectant le lecteur z: à \\\\$netbios_name\\install <br>" 1>&2
                fi
            fi
        fi
    fi
fi
rm -f /home/netlogon/$ip.lck
rm -fr /home/netlogon/machine/$oldname
