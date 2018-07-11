:: phase 2 : mise au domaine SE3
:: 
@echo off
pushd %SystemDrive%\netinst
time /T >> logs\unattend.log
echo phase 2: mise au domaine >> logs\unattend.log
call se4w10-vars.cmd
net use * /delete /yes

:integ
echo on attend un peu avant d'integrer le poste...
ping -n 10 %SE4AD_NAME%
cscript joindomain.vbs /d:"%DOMAIN%" /u:"%ADMINSE_NAME%" /p:"%ADMINSE_PASSWD%" 
set "ERR=%errorlevel%"
if [%ERR%]==[0] (goto ok)
echo ERREUR %ERR% LORS DE LA JONCTION A %DOMAIN% >> logs\unattend.log
set /P OK=tenter a nouveau l'integration (O/n)?
if not [%OK%]==[n] (goto integ)
set /A "PHASE=PHASE-1"
exit


:ok
echo phase 2: mise au domaine OK >> logs\unattend.log
::reg.exe add "HKey_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SEinstall" /d "%systemdrive%\Netinst\se4w10-3.cmd" /F
%SystemRoot%\system32\shutdown.exe -r -t 3  -c "Le poste %ComputerName% va rebooter sur le domaine %DOMAIN%"
