<?php
/* 
===========================================
   Projet SE3
   Dispositif SE3+TFTP+Sauvegarde/Restauration/Clonage
   Denis B
   Distribué selon les termes de la licence GPL
=============================================
*/

// loading libs and init
include "entete.inc.php";
include "ldap.inc.php";
include "ihm.inc.php";
//require_once "../dhcp/dhcpd.inc.php";
include "printers.inc.php";

require("lib_action_tftp.php");

//aide
$_SESSION["pageaide"]="Le_module_Clonage_des_stations#Unattend_W10";

// On active les rapports d'erreurs:
//error_reporting(E_ALL);

// Bibliothèque prototype Ajax pour afficher en décalé l'état des machines:
echo "<script type='text/javascript' src='../includes/prototype.js'></script>\n";

// CSS pour mes tableaux:
echo "<link type='text/css' rel='stylesheet' href='tftp.css' />\n";

if (is_admin("system_is_admin",$login)=="Y")
{
        $msg="";
	if(isset($_POST['config_win'])){
		//echo "PLOP";
		//$msg="";
	echo "<h1>".gettext("Configuration Windows")."</h1>\n";
	if(isset($_POST['action'])){
		ob_implicit_flush(true); 
		ob_end_flush();
		if($_POST['action']=='install_iso') {
			echo "Lancement de l'installation de l'iso...";
			system("/usr/bin/sudo /usr/bin/install-win-iso.sh $iso 2>&1");
		}
//
//
	//========================================================================

	echo "<form method=\"post\" action=\"".$_SERVER['PHP_SELF']."\">\n";
	//echo "<fieldset>\n";

	echo "<table class='crob' width=\"100%\">\n";
	echo "<tr>\n";
	echo "<th>Mise en place des sources Windows</th>\n";
	echo "</tr>\n";

	echo "<tr>\n";
	echo "<td>\n";
	echo "<tr><td>";

	echo "<select name='s1'>";
      	echo "<option value='' selected='selected'>-----</option>";

	foreach(glob(dirname(__FILE__) . '/var/se3/unattended/install/iso/*.iso') as $filename){
        	$filename = basename($filename);
        	echo "<option value='" . $filename . "'>".$filename."</option>";
        	}

        echo "</select>"; 
	echo "<input type='hidden' name='action' value='install_iso' />";
	echo ".<br>\n";
	echo "<p align='center'><input type=\"submit\" name=\"submit\" value=\"Lancer le T&#233;l&#233;chargement\" /></p>\n";
	echo "</td>\n";
	echo "</tr>\n";

	echo "</table>\n";

	//echo "</fieldset>\n";
	echo "</form>\n";

	//========================================================================

}
else {
	print (gettext("Vous n'avez pas les droits nécessaires pour ouvrir cette page..."));
}

// Footer
include ("pdp.inc.php");
?>
