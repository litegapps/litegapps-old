#litegapps control
#29-12-2020
updaterversion=1.0
updatercode=1
based=/data/litegapps
bins=$based/bin

getp(){
	grep "^$1" "$2" | head -n1 | cut -d = -f 2;
	}


clear
printmid "Litegapps Menu Updater"
print
print "- Checking Litegapps Menu"
$bins/curl -L -o $based/download/litegapps_menu https://raw.githubusercontent.com/wahyu6070/litegapps_control/master/litegapps/litegapps_menu.sh 2>/dev/null
if [ $(getp litegapps_menu_code $based/download/litegapps_menu) -gt $(getp litegapps_menu_code $based/litegapps_menu.sh) ]; then
print
print "  Litegapps Menu Latest version is available ! : "
print "  Old Version : $(getp litegapps_menu_version $based/litegapps_menu.sh)"
print "  New Version : $(getp litegapps_menu_version $based/download/litegapps_menu)"
print
print "- Updating"
cp -pf $based/download/litegapps_menu $based/litegapps_menu.sh
print "- Set permissions"
chmod 755 $based/litegapps_menu.sh
print "- update successful"
elif [ $(getp litegapps_menu_code $based/download/litegapps_menu) -eq $(getp litegapps_menu_code $based/litegapps_menu.sh) ]; then
print "  Litegapps Menu version is up to date !"
print "  Litegapps Menu Version : $(getp litegapps_menu_version $based/litegapps_menu.sh)"
fi
del $based/download/litegapps_menu


print "- Checking Updater"
$bins/curl -L -o $based/download/updater https://raw.githubusercontent.com/wahyu6070/litegapps_control/master/litegapps/updater.sh 2>/dev/null
if [ $(getp updatercode $based/download/updater) -gt $(getp updatercode $based/updater.sh) ]; then
print
print "  Updater Latest version is available ! : "
print "  Old Version : $(getp updaterversion $based/updater.sh)"
print "  New Version : $(getp updaterversion $based/download/updater)"
print
print "- Updating"
cp -pf $based/download/updater $based/updater.sh
print "- Set permissions"
chmod 755 $based/updater.sh
print "- Update successful"

elif [ $(getp updatercode $based/download/updater) -eq $(getp updatercode $based/updater.sh) ]; then
print "  Updater version is up to date !"
print "  Updater Version : $(getp updaterversion $based/updater.sh)"
fi
del $based/download/updater

print "- Done"
print
print "1.Exit"
print
echo -n "Select Menu : "
read lullll