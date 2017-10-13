wpeinit.exe  
call se3w10-vars.cmd
net use z: \\%SE3IP%\install /user:adminse3 %XPPASS%
rem
z:\os\Win10\setup.exe /auto upgrade /quiet 

