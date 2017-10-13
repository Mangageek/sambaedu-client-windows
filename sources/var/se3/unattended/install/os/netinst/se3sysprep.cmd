:: lancement de sysprep
:: le lecteur z: est normalement deja connecte lors du lancement de ce script
@echo off

if not exist %systemdrive%\netinst md %systemdrive%\netinst
copy z:\os\netinst\*.cmd %systemdrive%\netinst
copy z:\os\netinst\*.ini %systemdrive%\netinst
copy z:\os\netinst\*.vbs %systemdrive%\netinst
copy z:\os\netinst\*.ps1 %systemdrive%\netinst
copy z:\os\netinst\*.xml %systemdrive%\netinst
copy z:\os\netinst\wget.exe %systemdrive%\netinst
echo nettoyage wpkg
:: on tue wpkg en cas de clonage
schtasks /end /TN wpkg 2>NUL
schtasks /delete /TN wpkg /F 2>NUL
taskkill /IM cscript.exe /T /F 2>NUL

echo nettoyage gpo locales

del /s /f /q %windir%\system32\grouppolicy\*


:: recup du nom si il existe
if exist %systemdrive%\netinst\sysprep.txt goto sysprep
:: si la machine est enregistree cela ne sert a rien, elle prendra son nom au boot
:: si elle n'est pas enregistrée on permet de le faire ici :
set /P NEW_NAME=entrez le nom [%computername%]: || set NEW_NAME=%Computername%
echo:%NEW_NAME%>%SystemDrive%\Netinst\sysprep.txt

:sysprep
type %SystemDrive%\Netinst\sysprep.txt
:: sensé permettre à sysprep de fonctionner dans certains cas... Pas vu de différence !
::powershell -ExecutionPolicy ByPass -File c:\netinst\tiles.ps1
start /wait %windir%\system32\sysprep\sysprep.exe /generalize /oobe /quit /unattend:c:\netinst\sysprep.xml
if %ERRORLEVEL% neq 0 goto n else goto y
:n
echo probleme sysprep, essayez de le resoudre avant de relancer ce script ! 
pause
exit 1
:y
echo sysprep ok >> %systemdrive%\netinst\logs\unattend.log
call %systemdrive%\netinst\se3rapport.cmd pre y

%SystemRoot%\system32\shutdown.exe -r -t 10  -c "Le poste est pret pour le clonage"

