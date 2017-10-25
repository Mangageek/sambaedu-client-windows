::  phase 1 : configuration du poste pour mise au domaine SE3
@echo off
time /T >>%systemdrive%\netinst\logs\unattend.log
echo phase 1 : debut integration>>%systemdrive%\netinst\logs\unattend.log
::net use * /delete /y
:: cles registre indispensables pour Samba en mode Legacy

reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" /v "\\*\netlogon" /d "RequireMutualAuthentication=0,RequireIntegrity=0,RequirePrivacy=0" /t REG_SZ /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" /v "\\*\netlogon" /d "RequireMutualAuthentication=0,RequireIntegrity=0,RequirePrivacy=0" /t REG_SZ /F
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /d "0" /t REG_DWORD /F
reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DomainCompatibilityMode" /t REG_DWORD /d "1" /F
reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DNSNameResolutionRequired" /t REG_DWORD /d "0" /F
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "ForceGuest" /t REG_DWORD /d "0" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" /v "Formatdatabase" /t REG_DWORD /d "1" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" /v "Enabled" /t REG_DWORD /d "0" /F
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "CachedLogonsCount" /d "0" /F
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Appx" /v "AllowDeploymentInSpecialProfiles" /t "REG_DWORD" /d "1" /F

:: desactivation smb2/3 sinon rien ne fonctionne...

:: on desactive smb2/3
sc.exe config lanmanworkstation depend= bowser/mrxsmb20/mrxsmb10/nsi
sc.exe config mrxsmb20 start= disabled
:: on active smb1   DANGER!!!
sc.exe config lanmanworkstation depend= bowser/mrxsmb10/nsi
sc.exe config mrxsmb10 start= auto
dism.exe /online /enable-feature /featurename:SMB1Protocol-client
dism.exe /online /enable-feature /featurename:SMB1Protocol-server

:: on renomme l'ordinateur si besoin : 

call %systemdrive%\netinst\se3w10-vars.cmd

net use z: \\%NETBIOS_NAME%\install /user:%SE3_DOMAIN%\adminse3 %XPPASS%

ping -n 3 %SE3IP%

if exist "z:\os\netinst\%IP%.txt" (goto z)
if exist "c:\netinst\%IP%.txt" (goto c)
if exist "c:\netinst\sysprep.txt" (goto s)
cls
echo pas de nom trouve on pose la question >> %systemdrive%\netinst\logs\unattend.log
::set NAME=%ComputerName%
set /p NAME=Entrez le nom de la machine [%ComputerName%]:|| set NAME=%ComputerName%
goto fin
:z
set /P NAME=<"z:\os\netinst\%IP%.txt"
goto fin
:c
set /P NAME=<"c:\netinst\%IP%.txt"
goto fin
:s
set /p NAME=<c:\netinst\sysprep.txt
goto fin
:fin
if [%NAME%]==[] (
	echo erreur, impossible de trouver un nom
	set "NAME=%ComputerName%"
)
echo "machine renommee %NAME%"
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t REG_SZ /d "%NAME%" /F
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName /t REG_SZ /d "%NAME%" /F
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d "%NAME%" /F
reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d "%NAME%" /F
echo phase 1 : la machine est renommee %NAME% >> %systemdrive%\netinst\logs\unattend.log

:: reboot
%SystemRoot%\system32\shutdown.exe -r -t 3  -c "Le poste %ComputerName% est renomme %NAME%"

