#!/bin/bash

for o in /var/tmp/imgcreate-* ; do
	umount $o
done

rm -rf /var/tmp/imgcreate-*

birthday=$(date +%Y%m%d%H%M)
echo $birthday

#mkdir -p $birthday
#cd $birthday

yum clean all
LANG=C livecd-creator -c XiZhi.ks -f redflag-inmini-livecd
mv redflag-inmini-livecd.iso RedFlag-inMini-2010-livecd-$birthday.iso

echo Build RedFlag-inMini-2010-livecd-$birthday.iso

#dest="/home/www/html/download"
#mv -f redflag-netbook-livecd.iso $dest/redflag-netbook-liveCD-$birthday.iso
#rm -f $dest/latest.iso
#rm -f $dest/new.iso
#ln -s $dest/redflag-DT7-liveCD-$birthday.iso $dest/latest.iso
