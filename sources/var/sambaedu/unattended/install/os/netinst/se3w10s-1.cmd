::  phase 1 : configuration du poste pour mise au domaine SE4
::  cles registre indispensables et changement du nom
@echo off
time /T>>%systemdrive%\netinst\logs\unattend.log
echo phase 1 : debut integration>>%systemdrive%\netinst\logs\unattend.log
::net use * /delete /y
:: cles registre à supprimer indispensables pour Samba en mode Legacy

reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /d "0" /t REG_DWORD /F
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "ForceGuest" /t REG_DWORD /d "0" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" /v "Formatdatabase" /t REG_DWORD /d "1" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" /v "Enabled" /t REG_DWORD /d "0" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "CachedLogonsCount" /d "0" /F
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Appx" /v "AllowDeploymentInSpecialProfiles" /t "REG_DWORD" /d "1" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t "REG_DWORD" /d "2" /F
::

:: detection OS
ver | findstr /i /c:"version 10." >nul
if [%errorlevel%]==[0] (set "OS=10") else (set "OS=7")
if [%OS%]==[7] (goto renomme)

:: activation smb2/3 sinon rien ne fonctionne...
:: on active smb2/3
:: on desactive smb1   DANGER!!!
powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "& {Set-itemproperty -path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type Dword -Value 0 -Force}"
powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "& {Set-itemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB2 -Type Dword -Value 1 -Force}"
powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "& {Set-itemProperty -path "HKLM:\SYSTEM\CurrentControlSet\services\lanmanworkstation" -name "DependOnService" -value "Bowser", "MRxSmb20", "NSI" -type MultiString}"
powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "& {Set-itemProperty -path "HKLM:\SYSTEM\CurrentControlSet\services\mrxsmb10" -name "Start" -type Dword -Value 4 -Force}"
powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "& {Set-itemProperty -path "HKLM:\SYSTEM\CurrentControlSet\services\mrxsmb20" -name "Start" -type Dword -Value 2 -Force}"
reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" /v "\\netlogon" /F
reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" /v "\\netlogon" /F
reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DomainCompatibilityMode" /F
reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DNSNameResolutionRequired" /F
dism.exe /online /disable-feature /quiet /norestart /featurename:SMB1Protocol
dism.exe /online /disable-feature /quiet /norestart /featurename:SMB1Protocol-Client
dism.exe /online /disable-feature /quiet /norestart /featurename:SMB1Protocol-Server
dism.exe /online /enable-feature /quiet /norestart /featurename:SMB1Protocol-Deprecation

:: on renomme l'ordinateur si besoin : 
:renomme

call %systemdrive%\netinst\se3w10-vars.cmd

net use z: \\%NETBIOS_NAME%\install /user:%SE3_DOMAIN%\Administrator %XPPASS%

ping -n 3 %SE3IP%

:: recup du nom si il existe
::priorite au fichier local
if exist "%systemdrive%\netinst\sysprep.txt" (goto s)
::fichier du serveur
if exist "z:\os\netinst\%IP%.txt" (goto z)
::fichier local
if exist "%systemdrive%\netinst\%IP%.txt" (goto c)
:: en derner ressort
set "NAME=%ComputerName%"
:c
set /P NAME=<"%systemdrive%\netinst\%IP%.txt"
goto nom
:z
set /P NAME=<"z:\os\netinst\%IP%.txt"
goto nom
:s
set /P NAME=<"%systemdrive%\netinst\sysprep.txt"
:nom
cls
echo Pour info le nom enregistre pour %IP% est [%NAME%] 
choice /C ON /T 10 /N /D O /M "Accepter [On]"
IF errorlevel 2 goto choix
IF errorlevel 1 goto nomok

:choix
:: si elle n'est pas enregistree on permet de le faire ici :
set "OLDNAME=%NAME%"
set /P NAME=entrez le nouveau nom [%OLDNAME%]: || set NAME=%OLDNAME%
echo:%NAME%>%SystemDrive%\Netinst\sysprep.txt
:nomok
echo Pour info le nom choisi est : 
type "%SystemDrive%\Netinst\sysprep.txt"
if [%NAME%]==[] (

	echo erreur, impossible de trouver un nom
	goto renomme
)
echo "machine renommee %NAME%"
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t REG_SZ /d "%NAME%" /F
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t REG_SZ /d "%NAME%" /F
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d "%NAME%" /F
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d "%NAME%" /F
echo phase 1 : la machine est renommee %NAME% >> %systemdrive%\netinst\logs\unattend.log
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /d "%NAME%" /F >NUL

:: reboot
%SystemRoot%\system32\shutdown.exe -r -t 3  -c "Le poste %ComputerName% est renomme %NAME%"

