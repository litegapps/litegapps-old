#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
#Litegapps
#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
#29-12-2020
litegapps_menu_version=1.0
litegapps_menu_code=1

getp5(){ grep "^$1" "$2" | head -n1 | cut -d = -f 2; }
test -f /system_root/system/build.prop && SYSDIR=/system_root/system || test -f /system/system/build.prop && SYSDIR=/system/system || SYSDIR=/system
findarch=$(getp5 ro.product.cpu.abi $SYSDIR/build.prop | cut -d '-' -f -1)
SDK=$(getp5 ro.build.version.sdk $SYSDIR/build.prop)
case $findarch in
arm64) ARCH=arm64 ;;
armeabi) ARCH=arm ;;
x86) ARCH=x86 ;;
x86_64) ARCH=x86_64 ;;
*) abort " <$findarch> Your Architecture Not Support" ;;
esac


spinner() {
  set +x
  PID=$!
  h=0; anim='-\|/';
  while [ -d /proc/$PID ]; do
    h=$(((h+1)%4))
    sleep 0.02
    printf "\r${@} [${anim:$h:1}]"
  done
  set -x 2>>$VERLOG
}

download_file(){
clear
print "             Download Files"
url=$2
name=$1
print "- Name : $name"
del $base2/download
test ! -d $base2/download && mkdir -p $base2/download
$bin2/curl -L -o $base2/download/$name.tar.xz $url 2>/dev/null & spinner "- Downloading" 2>/dev/null
print
print "- Size : $(du -sh $base2/download/$name.tar.xz | cut -f1)"
print "- Extracting"
test -d $base2/app/$name && del $base2/app/$name
test ! -d $base2/app/$name && cdir $base2/app/$name
$bin2/busybox tar -xf $base2/download/$name.tar.xz -C $base2/app/$name
if [ -f $base2/app/$name/install.sh ]; then
	print "- Installing Using Manual script"
	chmod 775 $base2/app/$name/install.sh
	. $base2/app/$name/install.sh
else
	print "- Installing default script"
	if [ -d $base2/app/$name/system ]; then
	cd $base2/app/$name/system
	find * -type f | while read sfile; do
		echo "$sfile" >> $base2/app/$name/list_system
	done
	cd /
	fi
	print "- Pushing"
	for i1 in $(cat $base2/app/$name/list_system); do
		if [ -f $base2/app/$name/system/$i1 ]; then
			[ -d $(dirname $SYSDIR/$i1) ] && del $(dirname $SYSDIR/$i1)
			[ ! -d $(dirname $SYSDIR/$i1) ] && cdir $(dirname $SYSDIR/$i1)
			cp -pf $base2/app/$name/system/$i1 $SYSDIR/$i1
		fi
	done
	print "- set permissions"
	for i2 in $(cat $base2/app/$name/list_system); do
		if [ -f $SYSDIR/$i2 ]; then
			chcon -h u:object_r:system_file:s0 $SYSDIR/$i2
			chmod 644 $SYSDIR/$i2
			chcon -h u:object_r:system_file:s0 $(dirname $SYSDIR/$i2)
			chmod 755 $(dirname $SYSDIR/$i2)
		fi
	done
	
	test ! -f $base2/list_file_installed && touch $base2/list_file_installed
	for asw in $(cat $base2/app/$name/list_system); do
		if grep -Fxq "$asw" $base2/list_file_installed; then
			echo
		else
			echo "$asw" >> $base2/list_file_installed
		fi
	done
fi
print "- Done"
print
print
print "1.Reboot"
print "2.Back"
print
echo -n "Select Menu : "
read menud
case $menud in
1)
reboot
;;
2)
echo
;;
esac

}


download_menu(){
	while true; do
	clear
	print "      Download list"
	print
	print "1.Wellbeing"
	print "2.Youtube Vanced"
	print "3.Sound Picker"
	print "4.about"
	print "5.Exit"
	echo -n "Select List :"
	read dmenu
	case $dmenu in
	1)
	download_file Wellbeing https://sourceforge.net/projects/litegapps/files/database/$ARCH/$SDK/Wellbeing.tar.xz/download
	;;
	2)
	download_file Youtube https://sourceforge.net/projects/litegapps/files/database/$ARCH/$SDK/YoutubeVanced.tar.xz/download
	;;
	3)
	echo
	;;
	4)
	clear
	printmid "About"
	print
	print "This is a tool to download the manual Litegapps application."
	print
	print "Problem solving : "
	print "1.make sure you have a good internet connection"
	print "2.make sure you are using the latest version of litegapps control"
	print
	print "Report bug : https://t.me/litegapps"
	print
	print "1.Back"
	print
	echo -n "Select Menu : "
	read lololo
	;;
	5)
	break
	;;
	esac
	done
	
	}


while true; do
clear
print
printmid "Litegapps Menu"
print
print "1.Download package"
print "2.Tweaks"
print "3.Update Litegapps menu"
print "4.about "
print "5.exit"
print
echo -n "Select Menu : "
read menu77
	case $menu77 in
		1)
		download_menu
		;;
		2)
		echo
		;;
		3)
		chmod 755 /data/litegapps/updater.sh
		. /data/litegapps/updater.sh
		;;
		4)
		clear
		printmid "About Litegapps Menu"
		print
		print "Litegapps Menu is an additional feature of Litegapps or Litegapps++"
		print " "
		print "telegram channel : https://t.me/litegapps"
		print " "
		print "1.Back"
		print
		echo -n "Select Menu : "
		read lzuz
		;;
		5)
		break
		;;
		*)
		error "please select"
		sleep 2s
		;;
		esac
done












#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
