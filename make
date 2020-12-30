#!/system/bin/sh
base="$(dirname "$(readlink -f $0)")"
chmod -R 775 $base/bin
. $base/bin/kopi
bin=$base/bin/$ARCH32


chmod 775 $base/build.sh
time $bin/bash $base/build.sh $@
