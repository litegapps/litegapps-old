base="$(dirname "$(readlink -f $0)")"
case $(uname -m) in
*x86) ARCH32=x86 ;;
*) ARCH32=arm
esac
bin=$base/../../bin/$ARCH32
chmod -R 777 $bin

find $base -name *.zip -type f | while read zipname; do
output=$base/gapps
rm -rf $output
mkdir -p $output
$bin/unzip -o $zipname -d $output >/dev/null
done

find $base -name *.tar* -type f | while read filen; do
out=$(echo "$filen" | cut -d '.' -f 1)
echo "- Extracting $(basename $filen)"
mkdir -p $out
$bin/busybox tar -xf $filen -C $out
rm -rf $filen
done


system=$base/system
rm -rf $system
mkdir -p $system
mkdir -p $system/etc
find $base -type d | while read asw; do
case $asw in
*nodpi/priv-app)
echo "- Copying $asw"
cp -af $asw $system/
rm -rf $asw
;;
*nodpi/app)
echo "- Copying $asw"
cp -af $asw $system/
rm -rf $asw
;;
*lib64)
echo "- Copying $asw"
cp -af $asw $system/
rm -rf $asw
;;
*lib)
echo "- Copying $asw"
cp -af $asw $system/
rm -rf $asw
;;
*framework)
echo "- Copying $asw"
cp -af $asw $system/
rm -rf $asw
;;
*etc/default-permissions)
echo "- Copying $asw"
cp -af $asw $system/etc/
rm -rf $asw
;;
*etc/sysconfig)
echo "- Copying $asw"
cp -af $asw $system/etc/
rm -rf $asw
;;
*etc/preferred-apps)
echo "- Copying $asw"
cp -af $asw $system/etc/
rm -rf $asw
;;
*permissions)
echo "- Copying $asw"
cp -af $asw $system/etc/
rm -rf $asw
;;
esac
done
