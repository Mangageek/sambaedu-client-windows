:: lancement de sysprep
::  est normalement deja connecte lors du lancement de ce script, et les privileges eleves
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


echo nettoyage wpkg
:: on tue wpkg en cas de clonage
schtasks /end /TN wpkg 2>NUL
schtasks /delete /TN wpkg /F 2>NUL
taskkill /IM cscript.exe /T /F 2>NUL

echo nettoyage gpo locales

del /s /f /q %windir%\system32\grouppolicy\*

call %systemdrive%\netinst\se3w10-vars.cmd
:: recup du nom si il existe
if exist "%systemdrive%\netinst\%IP%.txt" (goto sysprep)
:: si la machine est enregistree cela ne sert a rien, elle prendra son nom au boot
if exist "%systemdrive%\netinst\%IP%.txt" (goto sysprep)
:: si elle n'est pas enregistrée on permet de le faire ici :
set /P NEW_NAME=entrez le nom [%computername%]: || set NEW_NAME=%Computername%
echo:%NEW_NAME%>%SystemDrive%\Netinst\sysprep.txt

:sysprep
echo Pour info le nom enregistre est : 
type "%SystemDrive%\Netinst\sysprep.txt"
:: sensé permettre à sysprep de fonctionner dans certains cas... Pas vu de différence !
::powershell -ExecutionPolicy ByPass -File c:\netinst\tiles.ps1
%windir%\system32\sysprep\sysprep.exe /generalize /oobe /quit /unattend:c:\netinst\sysprep.xml
set "ERR=%ERRORLEVEL%"
if [%ERR%]==[0] (goto y) else (goto n)
:n
echo probleme sysprep, essayez de le resoudre avant de relancer ce script !
echo erreur : %ERR%
pause
exit 1
:y
echo sysprep ok>> %systemdrive%\netinst\logs\unattend.log
call %systemdrive%\netinst\se3rapport.cmd pre y

%SystemRoot%\system32\shutdown.exe -r -t 10  -c "Le poste est pret pour le clonage"

