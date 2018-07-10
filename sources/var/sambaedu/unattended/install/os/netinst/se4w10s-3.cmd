:: ce script est lancé en dernier par specialize en Adminse

:: Il permet :
:: 1. d'installer wpkg sans le lancer puis de lancer l'install complete des applis wpkg lors du reboot suivant
:: 2. de lancer des installations et commandes personnalisees eventuelles contenues dans \\se4fs\install\scripts\perso.bat

@echo off

pushd %SystemDrive%\netinst
call se4w10-vars.cmd

time /T >> logs\unattend.log
echo specialize phase 3: installation des gpo >> logs\unattend.log

netsh firewall set portopening protocol=UDP port=137 name=se3_137 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
netsh firewall set portopening protocol=TCP port=139 name=se3_139 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
netsh firewall set portopening protocol=UDP port=138 name=se3_138 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
netsh firewall set portopening protocol=TCP port=445 name=se3_445 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /f 2>NUL
echo preparation des GPO

echo rem script de demarrage se3>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd
echo echo ok^>^>%SystemDrive%\netinst\logs\GPO.txt>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd
echo rem script de demarrage se3>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Shutdown\Shutdown.cmd
echo del /F /Q %SystemDrive%\netinst\*>>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Shutdown\Shutdown.cmd
echo Machine ok>%SYSTEMROOT%\System32\Grouppolicy\Se3.log
gpupdate /force

:: 1. Installation de wpkg
echo ############ PREPARATION DU POSTE POUR WPKG ###########################
echo specialize phase 3: installation de wpkg >> logs\unattend.log

echo Nettoyage des fichiers wpkg si presents
if exist %systemroot%\wpkg.txt del /F /Q %systemroot%\wpkg.txt && echo Suppression de wpkg.txt
if exist %systemroot%\wpkg.log del /F /Q %systemroot%\wpkg.log && echo Suppression de wpkg.log
if exist %systemroot%\wpkg-client.vbs del /F /Q %systemroot%\wpkg-client.vbs && echo Suppression de wpkg-client.vbs
if exist %systemroot%\system32\wpkg.xml del /F /Q %systemroot%\system32\wpkg.xml && echo Suppression de wpkg.xml
echo.
echo ############### PREPARATION DU DERNIER DEMARRAGE #########################
echo.

echo Mappage de la lettre Z: vers \\%NETBIOS_NAME%\install
:: Pour une utilisation aisee des scripts wpkg lances par perso.bat

if [%Z%]==[] (set "Z=Z:">NUL)
if [%SOFTWARE%]==[] (set "SOFTWARE=Z:\packages">NUL)
if [%ComSpec%]==[] (set "ComSpec=%SystemRoot%\system32\cmd.exe">NUL)
net use Z: \\%SE4FS_NAME%\install %ADMINSE_PASSWD% /user:%DOMAIN%\%ADMINSE_NAME% /persistent:no

call %Z%\wpkg\initvars_se3.bat >NUL

echo ############## INSTALLATION WPKG ENCHAINEE #########
:: on verifie si wpkg est deja installe : si c'est le cas , c'est qu'il s'agit d'un clonage ou renommage.
if exist %SystemRoot%\wpkg-client.vbs (goto reinstw) else (goto instw)

:reinstw
    ::  cas de clonage/changement de nom...
    echo reinitialisation de wpkg
    Set NoRunWpkgJS=1
    Set TaskUser=%ADMINSE_NAME%
    Set TaskPass=%ADMINSE_PASSWD%
    if exist Z:\wpkg\wpkg-repair.bat (copy Z:\wpkg\wpkg-repair.bat %systemdrive%\netinst\wpkg-repair.cmd)
    call %systemdrive%\netinst\wpkg-repair.cmd
    echo.
    goto suite

:instw
    :: if exist z:\wpkg\wpkg-se3.js cscript z:\wpkg\wpkg-se3.js /profile:unattended /synchronize /nonotify
    :: nouvelle installation : installer la tache wpkg sans la lancer 
    echo Installation de la tache planifiee wpkg sans execution immediate
    Set NoRunWpkgJS=1
    Set TaskUser=%ADMINSE_NAME%
    Set TaskPass=%ADMINSE_PASSWD%
    if exist Z:\wpkg\wpkg-install.bat (copy Z:\wpkg\wpkg-install.bat %systemdrive%\netinst\wpkg-install.cmd)
    call %systemdrive%\netinst\wpkg-install.cmd
    echo.
    :: echo installation immediate du paquet wsusoffline
    :: if exist z:\wpkg\wpkg-se3.js cscript z:\wpkg\wpkg-se3.js /install:wsusoffline /nonotify

:suite
echo WPKG SERA LANCE AU PROCHAIN REBOOT
echo ################## FIN DE L'INSTALLATION WPKG ###############

:: 2. Scripts perso
echo specialize phase 3: installation des scripts perso >> logs\unattend.log
if exist Z:\scripts\perso.bat (
    echo ########### LANCEMENT D'INSTRUCTIONS PERSONNELLES ######################
    call Z:\scripts\perso.bat
    echo ############### FIN DES INSTRUCTIONS PERSONNELLES ######################
) ELSE (
    echo Pas de commande personnalisee a lancer : pas de script Z:\scripts\perso.bat
)

::mise en place du mode d'alimentation peformances elevees
echo Mise en place du plan d'alimentation : performances elevees
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

:: accepter les drivers non signes
echo Sous %WINVERS%, on accepte les drivers non signes.
bcdedit.exe -set loadoptions DISABLE_INTEGRITY_CHECKS

:: detection OS
ver | findstr /i /c:"version 10." >nul
if [%errorlevel%]==[0] (set "OS=10") else (set "OS=7")
if [%OS%]==[7] (goto fin)


DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:z:os\Win10\sources\sxs

echo ############## ACTIVATION WINDOWS #######
:: si une cle est presente dans le bios, on la recupere. Fonctionne pour les postes initialement en W8 ou plus
::TODO 
:: permettre de recuperer une cle w7 dans la base ldap ?
powershell -ExecutionPolicy ByPass -File activation.ps1

echo ### activation des tuiles pour les utilisateurs du domaine ####
powershell -ExecutionPolicy ByPass -File tiles.ps1

:fin

echo se3 OK>> logs\unattend.log 
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DontDisplayLastUserName" /d "1" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /d "%DOMAIN%" /F
reg.exe delete "HKey_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SEinstall" /F
reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /F >NUL
net use * /delete /yes
%SystemRoot%\system32\shutdown.exe -r -t 3  -c "Le poste %ComputerName% est pret !"
