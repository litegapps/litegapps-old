base="`dirname $(readlink -f "$0")`"
chmod -R 775 $base/bin
. $base/bin/kopi
config=$base/config
tmp=$base/tmp
flashable=$base/flashable
flashable2=$base/litegapps++/flashable
bin=$base/bin/$ARCH32
log=$base/log/make.log
loglive=$base/log/make_live.log
out=$base/output
script=$base/script
del $loglive
read_config() {
	getp "$1" "$config"
}


PROP_ARCH=$(read_config arch)
PROP_SDK=$(read_config sdk)
PROP_ANDROID=$(read_config android.target)
PROP_VERSION=$(read_config litegapps.version)
PROP_BUILDER=$(read_config name.builder)

case $(read_config build.status) in
6070) PROP_STATUS=official ;;
wahyu6070) PROP_STATUS=official ;;
*) PROP_STATUS=unofficial ;;
esac

#################################################
#Cleaning dir
#################################################
if [ "$1" = clean ]; then
	flashable=$base/flashable
	print "- Cleaning"
	if [ -d $base/output ]; then
		del $base/output
		cdir $base/output
		touch $base/output/placefolder
	fi
	
	
	if [ -d $base/log ]; then
		del $base/log
		cdir $base/log
		touch $base/log/placefolder
	fi
	
	if [ -d $base/tmp ]; then
		del $base/tmp
	fi
	for G in $(ls -1 $base/flashable); do
		if [ -d $base/flashable/$G/files ]; then
			del $base/flashable/$G/files
			cdir $base/flashable/$G/files
			touch $base/flashable/$G/files/placefolder
		fi
	done
	
	for F in $(ls -1 $base/litegapps++/flashable); do
		if [ -d $base/litegapps++/flashable/$F/files ]; then
			del $base/litegapps++/flashable/$F/files
			cdir $base/litegapps++/flashable/$F/files
			touch $base/litegapps++/flashable/$F/files/placefolder
			##
		fi
	done
	print "- Cleaning Done"
	sleep 5s
	exit 0
fi

#################################################
# Git update repository
#################################################

if [ "$1" = push ]; then
	print "- Update repository github"
	if [ ! -d $base/.git ]; then
	print "- Cleating Git init"
	git init
	fi
	cd $base
	git commit -m "improvement •> $(date)"
	if [ ! "$(grep https://github.com/Wahyu6070/litegapps.git $base/.git/config)" ]; then
	print "- git remote add origin"
	git remote add origin https://github.com/Wahyu6070/litegapps.git
	fi
	print "- git push" && git push -u origin master
	print "- Git push done"
	exit 0
fi

#################################################
#Start
#################################################
clear
printlog " "
printlog "                 LiteGapps Building"
printlog " "
printlog " "
printlog " "
printlog "ARCH : $PROP_ARCH"
printlog "SDK  : $PROP_SDK"
printlog "Builder : $PROP_BUILDER"
printlog "Version : $PROP_VERSION"
printlog "Codename : $(read_config codename)"
printlog "Build Date : $(date +%d-%m-%Y)"
printlog "Build Status : $PROP_STATUS"
printlog "Android Target : $PROP_ANDROID"
printlog " "
printlog " "
printlog " "

sys_gapps=$base/gapps/$PROP_ARCH/$PROP_SDK/system
ven_gapps=$base/gapps/$PROP_ARCH/$PROP_SDK/vendor


[ -d $base/log ] && del $base/log
[ ! -d $base/log ] && cdir $base/log
[ -d $tmp ] && del $tmp
[ ! -d $tmp ] && cdir $tmp

if [[ $PROP_ARCH == all || $PROP_ARCH == All ]]; then
cp -af $base/gapps/* $tmp/
elif [[ $PROP_SDK == all || $PROP_SDK == All ]]; then
cdir $tmp/$PROP_ARCH
cp -af $base/gapps/$PROP_ARCH/* $tmp/$PROP_ARCH/
else
cdir $tmp/$PROP_ARCH/$PROP_SDK
tmpsys=$tmp/$PROP_ARCH/$PROP_SDK/system
tmpven=$tmp/$PROP_ARCH/$PROP_SDK/vendor
test -d $sys_gapps && cp -af $sys_gapps $tmpsys || printlog "- Failed copying $sys_gapps"
test -d $ven_gapps && cp -af $ven_gapps $tmpven
fi


#################################################
#Unzip
#################################################
printlog "- Unzip"
find $tmp -name *.apk -type f | while read apkname; do
case $apkname in
*.apk)
outdir=`dirname $apkname`
while_log "$(basename $apkname)"
cdir $outdir
$bin/unzip -o $apkname -d $outdir
del $apkname
;;
esac
done >> $loglive


#################################################
#Creating tar app/priv-app
#################################################
print "- Creating tar file"
find $tmp -type d | while read folname; do
case "$folname" in
*system)
for i1 in $(ls -1 $folname); do
    if [ -d $folname/$i1 ]; then
       for i2 in $(ls -1 $folname/$i1); do
             cd $folname/$i1
             sedlog "- Creating .tar $folname/$i1/$i2"
             tar -cf $i2.tar $i2
             del $i2
             cd /
       done
    fi
done
;;
*vendor)
for b1 in $(ls -1 $folname); do
    if [ -d $folname/$b1 ]; then
       for b2 in $(ls -1 $folname/$b1); do
             cd $folname/$b1
             sedlog "- Creating .tar $folname/$b1/$b2"
             tar -cf $b2.tar $b2
             del $b2
             cd /
       done
    fi
done 
;;
esac
done



#################################################
#Crearing tar
#################################################
printlog "- Creating arch.tar"
cd $tmp
sedlog "- Creating arch.tar"
$bin/tar -cf "arch.tar" *
cd /
for rmdir in $(ls -1 $tmp); do
  if [ -d $tmp/$rmdir ]; then
    sedlog "- Removing $tmp/$rmdir"
    del $tmp/$rmdir
  fi
done


#################################################
#Creating archive
#################################################
compression=$(read_config compression)
lvlcom=$(read_config compression.level)
printlog "- Creating archive : $compression"
printlog "- Level Compression : $lvlcom"
cd $tmp
for archi in $(ls -1 $tmp); do
   case $compression in
     xz)
       if [ $lvlcom -lt 10 ]; then
        $bin/xz -${lvlcom}e $tmp/$archi
        del $archi
       else
       abort "xz level 1-9"
       fi
     ;;
      br | brotli)
       if [ $lvlcom -lt 10 ]; then
        $bin/brotli -${lvlcom}j $archi
        del $archi
       else
       abort "brotli level 1-9"
       fi
     ;;
     zip)
     if [ $lvlcom -lt 10 ]; then
        $bin/zip -r${lvlcom} $archi.zip $archi >> $loglive
        del $archi
       else
       abort "zip level 1-9"
       fi
     ;;
     7z | 7za | 7zip | 7zr | p7zip)
     if [ $lvlcom -lt 10 ]; then
        $bin/7za a -t7z -m0=lzma -mx=$lvlcom -mfb=64 -md=32m -ms=on $archi.7z $archi >> $loglive
        del $archi
       else
       abort "7zip level 1-9"
       fi
     ;;
     zstd | zst)
     if [ $lvlcom -lt 20 ]; then
        $bin/zstd --rm -$lvlcom $archi >> $loglive
       else
       abort "Zstd level 1-19"
       fi
     ;;
     gz | gzip | gunzip)
     if [ $lvlcom -lt 10 ]; then
        $bin/gzip -$lvlcom $archi
       else
       abort "gzip level 1-9"
       fi
     ;;
     *)
       printlog "!!! Format $compression Not support"
       sleep 4s
       exit 1
      ;;
     esac
done

#################################################
#Creating md5sum
#################################################
printlog "- Creating MD5sum"
for t1 in $(ls -1 $tmp); do
$bin/busybox md5sum -b $tmp/$t1 | cut -d ' ' -f1 > $tmp/$t1.md5
done

#################################################
#Delete files
#################################################
for i in $(ls -1 $flashable); do
	 if [ -d $flashable/$i/files ]; then
	 	del $flashable/$i/files
	 	cdir $flashable/$i/files
	fi
done
#moving files
printlog "- Moving Files"
for i in $(ls -1 $tmp); do
	for Z in $(ls -1 $flashable); do
		sedlog "- copying <$tmp/$i> ==> <$flashable/$Z/files>"
		cp -pf $tmp/$i $flashable/$Z/files
	done
done

#################################################
#set module.prop
#################################################
printlog "- Updating module.prop"
find $flashable -name module.prop -type f | while read setmodule ; do
sed -i 's/'"$(getp name $setmodule)"'/'"Litegapps ${PROP_ARCH} ${PROP_ANDROID} ${PROP_STATUS}"'/g' $setmodule
sed -i 's/'"$(getp author $setmodule)"'/'"$PROP_BUILDER"'/g' $setmodule
sed -i 's/'"$(getp version $setmodule)"'/'"v${PROP_VERSION}"'/g' $setmodule
sed -i 's/'"$(getp versionCode $setmodule)"'/'"$(read_config litegapps.version.code)"'/g' $setmodule
sed -i 's/'"$(getp date $setmodule)"'/'"$(date +%d-%m-%Y)"'/g' $setmodule
done

#################################################
#Upstream litegapps utils from etc/litegapps_utils
#################################################
LITEGAPPS_UTILS=$base/etc/litegapps_utils
printlog "- Updating Litegapps Utils"
finput=$LITEGAPPS_UTILS/litegapps
if [ -f $finput ]; then
	for X in $flashable $flashable2; do
		for Z in $(ls -1 $X); do
			sedlog "- Updating $finput to $X/$Z/bin/"
			cp -f $finput $X/$Z/bin/
		done
		
	done
fi

finput=$LITEGAPPS_UTILS/27-litegapps.sh
if [ -f $finput ]; then
	for X in $flashable $flashable2; do
		for Z in $(ls -1 $X); do
			sedlog "- Updating $finput to $X/$Z/bin/"
			cp -f $finput $X/$Z/bin/
		done
		
	done
fi

finput=$LITEGAPPS_UTILS/litegapps-post-fs
if [ -f $finput ]; then
	for X in $flashable $flashable2; do
		for Z in $(ls -1 $X); do
			sedlog "- Updating $finput to $X/$Z/bin/"
			cp -f $finput $X/$Z/bin/
		done
		
	done
fi

finput=$LITEGAPPS_UTILS/kopi
if [ -f $finput ]; then
	for X in $flashable $flashable2; do
		for Z in $(ls -1 $X); do
			sedlog "- Updating $finput to $X/$Z/bin/"
			cp -f $finput $X/$Z/bin/
		done
		
	done
fi


finput=$LITEGAPPS_UTILS/LICENSE
if [ -f $finput ]; then
	for X in $flashable $flashable2; do
		for Z in $(ls -1 $X); do
			sedlog "- Updating $finput to $X/$Z/bin/"
			cp -f $finput $X/$Z/
		done
		
	done
fi
finput=$LITEGAPPS_UTILS/README.md
if [ -f $finput ]; then
	for X in $flashable $flashable2; do
		for Z in $(ls -1 $X); do
			sedlog "- Updating $finput to $X/$Z/bin/"
			cp -f $finput $X/$Z/
		done
		
	done
fi
			
#################################################
#setime
#################################################
if [ $(read_config set.time) = true ] && [ $(read_config date.time) -eq $(read_config date.time) ]; then
printlog "- Set time stamp"
setime -r $base/flashable $(read_config date.time)
fi


#################################################
# Zipping
#################################################

case $(read_config zip.level) in
0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9) ziplevel=$(read_config zip.level) ;;
*) ziplevel=1 ;;
esac


#################################################
#Magisk Module
#################################################
test ! -d $out && cdir $out
zipname=`echo "[MAGISK]LiteGapps_${PROP_ARCH}_${PROP_ANDROID}_$(date +%Y%m%d)_${PROP_STATUS}"`
printlog
printlog "- Creating Magisk Module Only"
printlog "- ZIP name  : $zipname"
printlog "- ZIP level : $ziplevel"
cd $flashable/magisk
test -f "$out/$zipname.zip" && del "$out/$zipname.zip"
$bin/zip -r$ziplevel $out/"$zipname.zip" . >/dev/null
cd $base
printlog "- ZIP size  : $(du -sh $out/$zipname.zip | cut -f1)"

#################################################
#Recovery
#################################################
zipname2=`echo "[RECOVERY]LiteGapps_${PROP_ARCH}_${PROP_ANDROID}_$(date +%Y%m%d)_${PROP_STATUS}"`
printlog
printlog "- Creating Recovery Only"
printlog "- ZIP name  : $zipname2"
printlog "- ZIP level : $ziplevel"
cd $flashable/recovery
test -f "$out/$zipname2.zip" && del "$out/$zipname2.zip"
$bin/zip -r$ziplevel $out/"$zipname2.zip" . >/dev/null
cd $base
printlog "- ZIP size  : $(du -sh $out/$zipname2.zip | cut -f1)"

#################################################
#Auto
#################################################
zipname3=`echo "[AUTO]LiteGapps_${PROP_ARCH}_${PROP_ANDROID}_$(date +%Y%m%d)_${PROP_STATUS}"`
printlog
printlog "- Creating AUTO RECOVERY/MAGISK"
printlog "- ZIP name  : $zipname3"
printlog "- ZIP level : $ziplevel"
cd $flashable/auto
test -f "$out/$zipname3.zip" && del "$out/$zipname3.zip"
$bin/zip -r$ziplevel $out/"$zipname3.zip" . >/dev/null
cd $base
printlog "- ZIP size  : $(du -sh $out/$zipname3.zip | cut -f1)"

#################################################
#Litegapps++
#################################################
if [ $(read_config litegapps2) = true ]; then
printlog " "
printlog "- Creating Litegapps++"
. $base/litegapps++/make
fi

del $tmp
printlog " "
printlog "- Done"

#################################################
#Done
#################################################
