:: lancement de sysprep
:: est normalement deja connecte lors du lancement de ce script, et les privileges eleves

:: on ne lance pas le sysprep par défaut sauf en cas de clonage windows 10
::

@echo off

if [%~dp0]==[z:\os\netinst] (
   echo erreur,  ce script doit etre lance depuis le disque local
   pause
   exit 1
) 

REG.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "0" /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
set "ERR=%ERRORLEVEL%"
if not [%ERR%]==[0] (
   echo erreur, ce script doit etre lance avec les privileges administrateur
   echo lancer rejointse3.cmd
   pause
   exit 1
)

if exist %systemdrive%\netinst\action.txt (set /P ACTION=<"%systemdrive%\netinst\action.txt")


echo nettoyage wpkg
:: on tue wpkg en cas de clonage
schtasks /end /TN wpkg 2>NUL
schtasks /delete /TN wpkg /F 2>NUL
taskkill /IM cscript.exe /T /F 2>NUL

echo nettoyage gpo locales

del /s /f /q %windir%\system32\grouppolicy\*

call %systemdrive%\netinst\se3w10-vars.cmd

:: detection OS
ver | findstr /i /c:"version 10." >nul
if [%errorlevel%]==[0] (set "OS=10") else (set "OS=7")
if [%OS%]==[7] (goto nosysprep)

:: win10
if [%ACTION%]==[] (set "ACTION=rejoint")
if [%ACTION%]==[renomme] (goto nosysprep)
if [%ACTION%]==[clone] (goto sysprep)
if not [%1]==[/sysprep] (goto nosysprep)

:sysprep
cls
echo ATTENTION l'operation %ACTION% va se faire AVEC sysprep ! 
choice /C ONA /T 5 /N /D O /M "(O)ui, (N)on, (a)nnuler? [Ona]"
set "CHOIX=%ErrorLevel%"
IF [%CHOIX%]==[2] goto nosysprep
IF [%CHOIX%]==[3] exit

%windir%\system32\sysprep\sysprep.exe /generalize /oobe /quit /unattend:c:\netinst\sysprep-%OS%.xml
set "ERR=%ERRORLEVEL%"
if [%ERR%]==[0] (goto y) else (goto n)
:n
echo probleme sysprep, essayez de le resoudre avant de relancer ce script !
echo erreur : %ERR%
goto nosysprep

:y
echo sysprep ok>> %systemdrive%\netinst\logs\unattend.log
goto fin

:nosysprep
cls
echo ATTENTION l'operation %ACTION% va se faire SANS sysprep ! 
choice /C ONA /T 5 /N /D O /M "(O)ui, (N)on, (a)nnuler? [Ona]"
set "CHOIX=%ErrorLevel%"
IF [%CHOIX%]==[2] goto sysprep
IF [%CHOIX%]==[3] exit

reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /F >NUL
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /d "%ComputerName%" /F >NUL
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /d "adminse3" /F >NUL
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /d "%XPPASS%" /F >NUL
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /d "1" /F >NUL
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoLogonCount" /d "3" /F >NUL
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SE3install" /d "%SystemDrive%\netinst\se3w10.cmd" /F >NUL
cscript %systemdrive%\netinst\quitte_domaine.vbs /u:"adminse3" /p:"%XPPASS%"


net user | findstr adminse3 >NUL
if [%errorlevel%]==[0] (goto fin)

echo creation de adminse3

net user adminse3 %XPPASS% /add
net localgroup Administrateurs adminse3 /add
net accounts /maxpwage:unlimited

:fin
call %systemdrive%\netinst\se3rapport.cmd %ACTION% y
%SystemRoot%\system32\shutdown.exe -r -t 10  -c "Le poste est pret pour l'integration"

