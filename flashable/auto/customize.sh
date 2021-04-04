# LiteGapps
# customize.sh 
# latest update 04-04-2021
# By wahyu6070
chmod 755 $MODPATH/bin/litegapps-functions
#litegapps functions
. $MODPATH/bin/litegapps-functions
#path
if [ -f /system_root/system/build.prop ]; then
SYSDIR=/system_root/system 
elif [ -f /system/system/build.prop ]; then
SYSDIR=/system/system
else
SYSDIR=/system
fi
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
*) report_bug " <$findarch> Your Architecture Not Support" ;;
esac

for CCCACHE in $litegapps/log $tmp; do
del $CCCACHE
cdir $CCCACHE
done

#functions litegapps info module.prop and build.prop
litegapps_info

#detected build.prop
[ -f $SYSDIR/build.prop ] || report_bug "System build.prop not found"

#mode installation
case $TYPEINSTALL in
kopi)
sedlog "- Type install KOPI module"
;;
magisk)
sedlog "- Type install KOPI installer convert to magisk module"
;;
*)
sedlog "-Type install MAGISK module"
;;
esac

#arch bin detected
case $(uname -m) in
*x86*) arch32=x86 ;;
*) arch32=arm ;;
esac
bin=$MODPATH/bin/$arch32

chmod -R 775 $bin

#checking format file
if [ -f $files/arch.tar.xz ]; then
format_file=xz
elif [ -f $files/arch.tar.7z ]; then
format_file=7za
elif [ -f $files/arch.tar.br ]; then
format_file=brotli
elif [ -f $files/arch.tar.gz ]; then
format_file=gunzip
elif [ -f $files/arch.tar.zst ]; then
format_file=zstd
else
report_bug "File Gapps not found or format not support"
listlog $files
fi
sedlog "Format file : $format_file"


#checking executable
if [ $format_file ! xz ] && [ $format_file ! gunzip ] && [ ! -f $bin/$format_file ]; then
report_bug "Executable not found"
else 
sedlog "Executable $format_file found"
listlog $bin
fi

#extracting file format
printlog "- Extracting Gapps"
case $format_file in
xz) $bin/busybox xz -d $files/arch.tar.xz ;;
7za) $bin/7za e -y $files/arch.tar.7z > $livelog ;;
gunzip) gz -d $files/arch.tar.gz ;;
brotli) $bin/brotli -dj $files/arch.tar.br ;;
zstd) $bin/zstd -df --rm $files/arch.tar.zst ;;
*)
report_bug "File format not support"
listlog $files
esac

#extract tar files
printlog "- Extracting archive"
if [ -f $files/arch.tar ]; then
sedlog "Extracting $files/$ARCH.tar"
$bin/busybox tar -xf $files/arch.tar -C $tmp
listlog $files
fi


#cheking sdk files
test ! -d $tmp/$ARCH/$SDKTARGET && abort "Your Android Version Not Support"
   
#extrack tar files
print "- Extracting tar file"
find $tmp/$ARCH/$SDKTARGET -name *.tar -type f 2>/dev/null | while read tarfile; do
tarout=`echo "$tarfile" | cut -d '.' -f -1`
tarin=$tarfile
tarout=`dirname "$(readlink -f $tarin)"`
while_log "- Extracting tar : $tarin"
$bin/busybox tar -xf $tarin -C $tarout
del $tarin
done >> $loglive


#Building Gapps
datanull=/data/adb/abcdfghijk
cdir $datanull
#$datanull is fix creating ..apk
print "- Building Gapps"
find $tmp/$ARCH/$SDKTARGET -name AndroidManifest.xml -type f 2>/dev/null | while read xml_name; do
apkdir=`dirname "$(readlink -f $xml_name)"`
apk_zip_level=0
while_log "- Creating Archive Apk : $apkdir"
cd $apkdir
$bin/zip -r0 $apkdir.apk *
del $apkdir
cdir $apkdir
mv -f $apkdir.apk $apkdir/
cd $datanull
done >/dev/null
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


#litegapps menu
cdir $MODPATH/system/bin
cp -pf $MODPATH/bin/litegapps $MODPATH/system/bin/
chmod 755 $MODPATH/system/bin/litegapps

#Litegapps post fs
if [ -f /data/adb/magisk/magisk ]; then
cp -pf $MODPATH/bin/litegapps-post-fs /data/adb/service.d/
chmod 755 /data/adb/service.d/litegapps-post-fs
fi

#creating log
make_log


printlog "- Cleaning cache"
test -d $files && del $files
test -d $tmp && del $tmp

#terminal tips
terminal_tips
