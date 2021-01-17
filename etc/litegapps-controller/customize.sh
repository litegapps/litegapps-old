# LiteGapps
# By wahyu6070
[ -d /data/litegapps ] && rm -rf /data/litegapps
print "- copying binary"
[ -d /data/litegapps ] && rm -rf /data/litegapps
cp -af $MODPATH/litegapps /data/
chmod -R 755 /data/litegapps
print
print
print "*Tips"
print
print "- Open Terminal"
print
print "- su"
print "- litegapps"
print
print " report bug https://t.me/litegapps"
print