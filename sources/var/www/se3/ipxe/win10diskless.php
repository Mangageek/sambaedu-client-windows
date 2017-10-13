<?php
header ("Content-type: text/plain");
echo "#!ipxe\n";

// cible iscsi
//echo "ifopen net0\n";
//echo "dhcp\n";
echo "set net0/gateway 0.0.0.0\n";
//echo "set net0/keep-san 1\n";
$iscsi_rootfs="iscsi:192.168.202.1:::0:iqn.2003-01.org.linux-iscsi.proxmox3.x8664:sn.f8bfcf8bf214";
echo "sanboot --drive 0x80 ".$iscsi_rootfs."\n";
echo "boot\n";
?>
