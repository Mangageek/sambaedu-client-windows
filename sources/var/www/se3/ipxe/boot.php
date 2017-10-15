<?php
header ("Content-type: text/plain");
echo "#!ipxe\n";
$menu_timeout = '1000';
function title($name) {
    # the max number of characters for resolution 1024 x 768 is 107
    $total_length = 107;
    $name_length = strlen($name);
    $start = intval(($total_length - $name_length) / 2);
    $end = $total_length - $start - $name_length;
    $title = str_repeat("-", $start) . $name . str_repeat("-", $end);
    echo "item --gap -- {$title}\n";
    

}
# set resolution and background
echo "console --x 1024 --y 768 --picture ipxe-se3.png\n";

echo ":menu\n";
echo "menu Preboot eXecution Environment\n";
echo "set menu-default Win10\n";
echo "set menu-timeout $menu_timeout\n";

title("Menu");
//echo "item --key 1 login (1) Authentication\n";
//echo "item --key 2 Win7  (2) W7 wim\n";
echo "item --key 3 Win10  (3) Installation W10\n";
echo "item --key 4 Win10up  (4) Mise a jour W10 (experimental!!!)\n";
echo "item --key 5 Win10man  (5) Installation W10 manuelle\n";
echo "item --key 8 Win10l2  (8) boot W10 diskless(experimental!!!)\n";
echo "item --key 6 shell  (6) iPXE shell\n";
echo "item --key 0 exit  (0) Exit iPXE and boot harddisk\n";

echo "choose --default \${menu-default} --timeout \${menu-timeout} selected && goto \${selected} || exit 0\n";

//echo ":login\n";
//echo "login\n";
//echo "isset \${username} && isset \${password} || goto menu\n";
//echo "params \n";
//echo "param username \${username}\n";
//echo "param password \${password}\n";
//echo "chain --replace --autofree menu.php##params\n || sleep 10\n";

echo ":Win7\n";
echo "chain --replace wimboot7.php\n";
echo ":Win10\n";
echo "chain --replace wimboot10.php\n";
echo ":Win10up\n";
echo "chain --replace wimboot10r.php\n";
echo "boot\n";
echo ":Win10man\n";
echo "chain --replace wimboot10man.php\n";
echo ":Win10l2\n";
echo "chain --replace win10diskless2.php\n";

echo ":shell\n";
echo "echo iPXE shell...\n";
echo "shell\n";


echo ":exit\n";
echo "echo Booting harddisk ...\n";
echo "sanboot --no-describe --drive 0x80\n";

?>
