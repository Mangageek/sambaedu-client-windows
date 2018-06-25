<?php
header ("Content-type: text/plain");
echo "#!ipxe\n";

echo "kernel Win10/wimboot\n";
echo "initrd Win10/winpeshl.ini winpeshl.ini\n";
echo "initrd Win10/manu.bat install.bat\n";
echo "initrd Win10/se3w10-vars.cmd se3w10-vars.cmd\n";
echo "initrd Win10/boot/bcd             BCD\n";
echo "initrd Win10/boot/boot.sdi        boot.sdi\n";
echo "initrd Win10/sources/boot.wim  boot.wim\n";
echo "boot\n";

?>
