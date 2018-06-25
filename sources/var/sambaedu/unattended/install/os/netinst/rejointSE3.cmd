:: script de mise au domaine manuel
:: fonctionnel sous windows W7 et W10
:: 
:: n'est normalement lancee qu'en cas d'adhesion d'un nouveau poste, et que la mise au
:: domaine depuis l'interface se3 a echoue
:: Permet d'elever les privileges pour lancer le processus sysprep.
:: si le poste a deja ete enregistre dans l'interface, le nom sera automatiquement redonne
::
:: A lancer directement depuis \\se3\install\os\netinst\

set NETINST=%~dp0

::if exist %systemdrive%\netinst\phase.txt (set /P PHASE=<%systemdrive%\netinst\phase.txt)
::if [%1]==[nosysprep] (set "SYSPREP=0") else (set "SYSPREP=1")

@echo off


if not exist %systemdrive%\netinst (md %systemdrive%\netinst)
copy %NETINST%\*.cmd %systemdrive%\netinst
copy %NETINST%\*.ini %systemdrive%\netinst
copy %NETINST%\*.vbs %systemdrive%\netinst
copy %NETINST%\*.ps1 %systemdrive%\netinst
copy %NETINST%\*.xml %systemdrive%\netinst
copy %NETINST%\wget.exe %systemdrive%\netinst
copy %NETINST%\*.js %systemdrive%\netinst
copy %NETINST%\*.txt %systemdrive%\netinst


echo Execution en mode eleve de se3sysprep.cmd.
	
cscript %systemdrive%\Netinst\execute-elevated.js %systemdrive%\Netinst\se3sysprep.cmd 
::%SYSPREP%
 
