:: lanceur de demarrage des scripts  SE3
@echo off

if not exist %systemdrive%\netinst (mkdir %systemdrive%\netinst)
if not exist %systemdrive%\netinst\logs (mkdir %systemdrive%\netinst\logs)
if not exist %systemdrive%\netinst\logs\unattend.log (echo "debut de la mise au domaine">%systemdrive%\netinst\logs\unattend.log)
time /T>>%systemdrive%\netinst\logs\unattend.log

:: on tue wpkg en cas de clonage

schtasks /end /tn wpkg
::schtasks /delete /tn wpkg
taskkill /IM cscript.exe /F /T 2>NUL
if exist %systemroot%\wpkg-client.vbs (del /F /Q %systemroot%\wpkg-client.vbs && echo Suppression de wpkg-client.vbs)

net use * /delete /yes

::
if exist %systemdrive%\netinst\phase.txt (set /P PHASE=<%systemdrive%\netinst\phase.txt)
set /A "PHASE=PHASE+1"
echo:%PHASE%>%systemdrive%\netinst\phase.txt
call %systemdrive%\netinst\se3w10s-%PHASE%.cmd
::echo:%PHASE%>%systemdrive%\netinst\phase.txt
call  %systemdrive%\netinst\se3rapport.cmd post-%PHASE% y
