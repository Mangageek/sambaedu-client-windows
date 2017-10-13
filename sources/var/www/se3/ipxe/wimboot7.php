<?php
header ("Content-type: text/plain");
echo "#!ipxe\n";

echo "kernel Win7/wimboot\n";
echo "initrd Win7/winpeshl.ini winpeshl.ini\n";
echo "initrd Win7/install.bat install.bat\n";
echo "initrd Win7/boot/bcd             BCD\n";
echo "initrd Win7/boot/boot.sdi        boot.sdi\n";
echo "initrd Win7/sources/boot.wim  boot.wim\n";
echo "boot\n";

?>
