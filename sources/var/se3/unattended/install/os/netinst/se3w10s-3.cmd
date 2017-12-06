:: ce script est lancé en dernier par specialize en admine3

:: Il permet :
:: 1. Activer les pseudo-gpo SE3
:: 2. d'installer wpkg sans le lancer puis de lancer l'install complete des applis wpkg lors du reboot suivant
:: 3. de lancer des installations et commandes personnalisees eventuelles contenues dans \\se3\install\scripts\perso.bat

@echo off

:: 1. Activation des pseudo-GPO
:: TODO on pourrait les copier directement en place lors de l'installation ?

pushd %SystemDrive%\netinst
call se3w10-vars.cmd

time /T >> logs\unattend.log
echo specialize phase 3: installation des gpo >> logs\unattend.log

netsh firewall set portopening protocol=UDP port=137 name=se3_137 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
netsh firewall set portopening protocol=TCP port=139 name=se3_139 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
netsh firewall set portopening protocol=UDP port=138 name=se3_138 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
netsh firewall set portopening protocol=TCP port=445 name=se3_445 mode=ENABLE scope=CUSTOM addresses=%se3ip%/255.255.255.255
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /f 2>NUL
echo preparation des GPO

:: recherche du numero de version gpo et on l'incremente si il existe.
for /f "tokens=3 delims= " %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\GPO-List\0" /v Version ^| findstr REG_DWORD ') do @set "VERSION=%%a"
if [%VERSION%]==[] (set "VERSION=0x10001") else (set /a "VERSION=VERSION+0x10001")
echo gpo_version=%VERSION%
:: creation des GPO minimales
if not exist %SYSTEMROOT%\System32\GroupPolicy mkdir %SYSTEMROOT%\System32\GroupPolicy
if not exist %SYSTEMROOT%\System32\GroupPolicy\Machine mkdir %SYSTEMROOT%\System32\GroupPolicy\Machine
if not exist %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts mkdir %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts
if not exist %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Startup mkdir %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Startup
if not exist %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Shutdown mkdir %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Shutdown

echo [general]>%SYSTEMROOT%\System32\GroupPolicy\gpt.ini
echo Version=%VERSION%>>%SYSTEMROOT%\System32\GroupPolicy\gpt.ini
echo gPCUserExtensionNames=[{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{0F6B957E-509E-11D1-A7CC-0000F87571E3}][{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B66650-4972-11D1-A7CA-0000F87571E3}]>>%SYSTEMROOT%\System32\GroupPolicy\gpt.ini
echo gPCMachineExtensionNames=[{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{0F6B957D-509E-11D1-A7CC-0000F87571E3}][{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}]>>%SYSTEMROOT%\System32\GroupPolicy\gpt.ini

copy scriptsC.ini %SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\scripts.ini

echo rem script de demarrage se3>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd
echo echo ok^>^>%SystemDrive%\netinst\logs\GPO.txt>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd
echo rem script de demarrage se3>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Shutdown\Shutdown.cmd
echo del /F /Q %SystemDrive%\netinst\*>>%SYSTEMROOT%\System32\GroupPolicy\Machine\Scripts\Shutdown\Shutdown.cmd
echo Machine ok>%SYSTEMROOT%\System32\Grouppolicy\Se3.log
gpupdate /force


:: 2. Installation de wpkg
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
net use Z: \\%NETBIOS_NAME%\install %XPPASS% /user:%SE3_DOMAIN%\adminse3 /persistent:no

call %Z%\wpkg\initvars_se3.bat >NUL

echo ############## INSTALLATION WPKG ENCHAINEE #########
:: on verifie si wpkg est deja installe : si c'est le cas , c'est qu'il s'agit d'un clonage ou renommage.
if exist %SystemRoot%\wpkg-client.vbs (goto reinstw) else (goto instw)

:reinstw
    ::  cas de clonage/changement de nom...
    echo reinitialisation de wpkg
    Set NoRunWpkgJS=1
    Set TaskUser=adminse3
    Set TaskPass=%XPPASS%
    if exist Z:\wpkg\wpkg-repair.bat (copy Z:\wpkg\wpkg-repair.bat %systemdrive%\netinst\wpkg-repair.cmd)
    call %systemdrive%\netinst\wpkg-repair.cmd
    echo.
    goto suite

:instw
    :: if exist z:\wpkg\wpkg-se3.js cscript z:\wpkg\wpkg-se3.js /profile:unattended /synchronize /nonotify
    :: nouvelle installation : installer la tache wpkg sans la lancer 
    echo Installation de la tache planifiee wpkg sans execution immediate
    Set NoRunWpkgJS=1
    Set TaskUser=adminse3
    Set TaskPass=%XPPASS%
    if exist Z:\wpkg\wpkg-install.bat (copy Z:\wpkg\wpkg-install.bat %systemdrive%\netinst\wpkg-install.cmd)
    call %systemdrive%\netinst\wpkg-install.cmd
    echo.
    :: echo installation immediate du paquet wsusoffline
    :: if exist z:\wpkg\wpkg-se3.js cscript z:\wpkg\wpkg-se3.js /install:wsusoffline /nonotify

:suite
echo WPKG SERA LANCE AU PROCHAIN REBOOT
echo ################## FIN DE L'INSTALLATION WPKG ###############

:: 3. Scripts perso
echo specialize phase 3: installation des scripts perso >> logs\unattend.log
if exist Z:\scripts\perso.bat (
    echo ########### LANCEMENT D'INSTRUCTIONS PERSONNELLES ######################
    call Z:\scripts\perso.bat
    echo ############### FIN DES INSTRUCTIONS PERSONNELLES ######################
) ELSE (
    echo Pas de commande personnalisee a lancer : pas de script Z:\scripts\perso.bat
)

:: accepter les drivers non signes
echo Sous %WINVERS%, on accepte les drivers non signes.
bcdedit.exe -set loadoptions DISABLE_INTEGRITY_CHECKS

DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:z:os\Win10\sources\sxs

echo ############## ACTIVATION WINDOWS #######
:: si une cle est presente dans le bios, on la recupere. Fonctionne pour les postes initialement en W8 ou plus
::TODO 
:: permettre de recuperer une cle w7 dans la base ldap ?
powershell -ExecutionPolicy ByPass -File activation.ps1

echo ### activation des tuiles pour les utilisateurs du domaine ####
powershell -ExecutionPolicy ByPass -File tiles.ps1

echo se3 OK>> unattend.log 
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DontDisplayLastUserName" /d "1" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /d "%SE3_DOMAIN%" /F
reg.exe delete "HKey_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SE3install" /F
net use * /delete /yes
%SystemRoot%\system32\shutdown.exe -r -t 3  -c "Le poste %ComputerName% est pret !"
