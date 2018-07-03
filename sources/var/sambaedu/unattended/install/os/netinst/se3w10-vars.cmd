:: TODO charger les variables des facon dynamique
set "SE3_DOMAIN=QUENTINTEST"
set "NETBIOS_NAME=se4ad"
set "XPPASS=azerty_0"
set "SE3IP=192.168.201.12"
set "URLSE3=http://admin.quentintest.com"
for /f "tokens=2 delims=[]" %%i in ('nbtstat -a %computername% ^|find "Adresse IP"') do (set "IP=%%i")
