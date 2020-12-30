# LiteGapps
# By wahyu6070
chmod 777 $MODPATH/bin/kopi
#kopi functions
. $MODPATH/bin/kopi
#path
test -f /system_root/system/build.prop && SYSDIR=/system_root/system || test -f /system/system/build.prop && SYSDIR=/system/system || SYSDIR=/system
VENDIR=/vendor
tmp=/data/adb/litegapps
litegapps=/data/media/0/Android/litegapps
log=$litegapps/log/litegapps.log
loglive=$litegapps/log/litegapps_live.log
files=$MODPATH/files
SDKTARGET=$(getp ro.build.version.sdk $SYSDIR/build.prop)

findarch=$(getp ro.product.cpu.abi $SYSDIR/build.prop | cut -d '-' -f -1)
case $findarch in
arm64) ARCH=arm64 ;;
armeabi) ARCH=arm ;;
x86) ARCH=x86 ;;
x86_64) ARCH=x86_64 ;;
*) abort " <$findarch> Your Architecture Not Support" ;;
esac


del $litegapps/log
cdir $litegapps/log
del $tmp
cdir $tmp
printlog "____________________________________"
printlog "|"
printlog "| Name            : $MODULENAME"
printlog "| Version         : $MODULEVERSION"
printlog "| Build date      : $MODULEDATE"
printlog "| By              : $MODULEAUTHOR"
printlog "|___________________________________"
printlog "|"
printlog "| Telegram        : https://t.me/litegapps"
printlog "|___________________________________"
printlog "|              Device Info"
printlog "| Name Rom        : $ANDROIDROM"
printlog "| Device          : $ANDROIDMODEL ($ANDROIDDEVICE)"
printlog "| Android Version : $ANDROIDVERSION"
printlog "| Architecture    : $ARCH"
printlog "| Sdk             : $SDKTARGET"
printlog "|___________________________________"
printlog " "

case $(uname -m) in
*x86*) arch32=x86 ;;
*) arch32=arm ;;
esac
bin=$MODPATH/bin/$arch32

chmod -R 775 $bin


#diference litegapps++

#checking format file
if [ -f $files/files.tar.xz ]; then
format_file=xz
elif [ -f $files/files.tar.7z ]; then
format_file=7za
elif [ -f $files/files.tar.br ]; then
format_file=brotli
elif [ -f $files/files.tar.gz ]; then
format_file=gunzip
elif [ -f $files/files.tar.zst ]; then
format_file=zstd
else
abort "File Gapps not found or format not support"
listlog $files
fi
sedlog "Format file : $format_file"


#checking executable
if [ $format_file ! xz ] && [ $format_file ! gunzip ] && [ ! -f $bin/$format_file ]; then
abort "Executable not found"
else 
sedlog "Executable $format_file found"
listlog $bin
fi

#extracting file format
printlog "- Extracting Gapps"
case $format_file in
xz) $bin/busybox xz -d $files/files.tar.xz ;;
7za) $bin/7za e -y $files/files.tar.7z > $livelog ;;
gunzip) gz -d $files/files.tar.gz ;;
brotli) $bin/brotli -dj $files/files.tar.br ;;
zstd) $bin/zstd -df --rm $files/files.tar.zst ;;
*)
abort "File format not support"
listlog $files
esac

#extract tar files
printlog "- Extracting archive"
if [ -f $files/files.tar ]; then
sedlog "Extracting $files/files.tar"
tar -xf $files/files.tar -C $tmp
listlog $files
fi

cdir $tmp/$ARCH/$SDKTARGET

#sdk
if [ -d $tmp/api/$SDKTARGET ]; then
cp -a $tmp/api/$SDKTARGET/* $tmp/$ARCH/$SDKTARGET/
else
abort "Your Android Version Not Support"
fi

#arch
if [ -d $tmp/arch/$ARCH ]; then
cp -af $tmp/arch/$ARCH/* $tmp/$ARCH/$API/
fi

#croos system
if [ -d $tmp/croos_system ]; then
cp -af $tmp/croos_system/* $tmp/$ARCH/$API/
fi
#end defference litegapps

#cheking sdk files
   
#extrack tar files
print "- Extracting tar file"
find $tmp/$ARCH/$SDKTARGET -name *.tar -type f 2>/dev/null | while read tarfile; do
tarout=`echo "$tarfile" | cut -d '.' -f -1`
tarin=$tarfile
tarout=`dirname "$(readlink -f $tarin)"`
while_log "- Extracting tar : $tarin"
tarex $tarin $tarout
del $tarin
done >> $loglive


#Building Gapps
datanull=/data/adb/abcdfghijk
cdir $datanull
#$datanull is fix creating ..apk
print "- Building Gapps"
find $tmp/$ARCH/$SDKTARGET -name AndroidManifest.xml -type f 2>/dev/null | while read xml_name; do
apkdir=`dirname "$(readlink -f $xml_name)"`
while_log "- Creating Archive Apk : $apkdir"
cd $apkdir
$bin/zip -r0 $apkdir.apk *
del $apkdir
cdir $apkdir
mv -f $apkdir.apk $apkdir/
cd $datanull
done >> $loglive
del $datanull


#Zipalign
printlog "- Zipalign"
find $tmp/$ARCH/$SDKTARGET -name *.apk -type f 2>/dev/null | while read apk_file; do
apkdir1=`dirname "$(readlink -f $apk_file)"`
while_log "- Zipalign $apk_file"
$bin/zipalign -f -p -v 4 $apk_file $apkdir1/new.apk
del $apk_file
mv -f $apkdir1/new.apk $apk_file
done >> $loglive


#copying file
printlog "- Copying Gapps"
if [ $SDKTARGET -lt 29 ]; then
sysdirtarget=$MODPATH/system
vendirtarget=$MODPATH/system/vendor
cdir $sysdirtarget
#cdir $vendirtarget
else
sysdirtarget=$MODPATH/system/product
vendirtarget=$MODPATH/system/vendor
cdir $sysdirtarget
#cdir $vendirtarget
fi

if [ -d $tmp/$ARCH/$SDKTARGET/system ]; then
sedlog "- Copying system"
listlog $tmp
cp -af $tmp/$ARCH/$SDKTARGET/system/* $sysdirtarget/
fi

if [ -d $tmp/$ARCH/$SDKTARGET/vendor ]; then
sedlog "- Copying vendor"
listlog $tmp
cp -af $tmp/$ARCH/$SDKTARGET/vendor/* $vendirtarget/
fi


#Permissions
find $MODPATH/system -type d 2>/dev/null | while read setperm_dir; do
while_log "- Set chcon dir : $setperm_dir"
ch_con $setperm_dir
while_log "- Set chmod 755 dir : $setperm_dir"
chmod 755 $setperm_dir
done >> $loglive

printlog "- Set Permissions"
find $MODPATH/system -type f 2>/dev/null | while read setperm_file; do
while_log "- Set chcon file : $setperm_file"
ch_con $setperm_file
while_log "- Set chmod 644 file : $setperm_file"
chmod 644 $setperm_file
done >> $loglive


#creating log
printlog "- Creating log"
if [ -f $SYSDIR/build.prop ]; then
cp -pf $SYSDIR/build.prop $litegapps/log/sys_build.prop
fi

if [ -f $VENDIR/build.prop ]; then
cp -pf $VENDIR/build.prop $litegapps/log/ven_build.prop
fi

if [ -d $litegapps/log ]; then
listlog $tmp
listlog $MODPATH
listlog $litegapps
ls -alZR $MODPATH/system >> $loglive
cd $litegapps/log
test -f $litegapps/log/litegapps_log.tar.gz && del $litegapps/log/litegapps_log.tar.gz
tar -cz -f $litegapps/log/litegapps_log.tar.gz *
cd /
fi

#litegapps menu
cdir $MODPATH/system/bin
cp -pf $MODPATH/bin/litegapps $MODPATH/system/bin/
chmod 755 $MODPATH/system/bin/litegapps

#Litegapps post fs
if [ -f /data/adb/magisk/magisk ]; then
cp -pf $MODPATH/bin/litegapps-post-fs /data/adb/service.d/
chmod 755 /data/adb/service.d/litegapps-post-fs
fi

printlog "- Cleaning cache"
test -d $files && del $files
test -d $tmp && del $tmp

printlog
printlog "*Tips"
printlog "- Open Terminal"
printlog "- su"
printlog "- litegapps"
printlog " "
printlog " Bug report : https://t.me/litegappsgroup"
printlog " "

