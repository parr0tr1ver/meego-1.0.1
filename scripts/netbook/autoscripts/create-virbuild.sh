#! /bin/bash 

# Originally written by kazutomo@turbolinux.co.jp ?
#   with heavy changes by Akinobu Mita <mita@miraclelinux.com>

set -x

TIME="`date +%Y%m%d%H%M`"

make_chroot_script () {

    oldRPMS=$RPMS
    oldROOT=$ROOT
    
    RPMS=/tmp/RPMS
    ROOT=/
    LOGFILE=/tmp/create-virbuild.log
    
#### Script for Executing on VIRBUILD ####
    cat > $1 <<CHROOT
#! /bin/bash -x

export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin

rm -f $LOGFILE
##### 
# below are very ugly. I'll fix later, hopefully  

# create /dev/null
mkdir -p /dev/
/bin/mknod /dev/null c 1 3

echo now installing rpms...... please wait a few minutes

$ROOT/bin/rpm --initdb --root $ROOT

# disable the following line for test
if false; then
$ROOT/bin/rpm -ivh $RPMS/libselinux-*.rpm --force --nodeps --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/setup-*.rpm  --force    --root $ROOT > $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/glibc-common-*.rpm --force --nodeps --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/glibc-2.*i686.rpm --force --nodeps --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/filesystem-*.rpm --force --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/libgcc-*.rpm --force --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/tzdata-*.rpm --force --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/setup-*.rpm --force --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/filesystem-*.rpm --force --root $ROOT >> $LOGFILE 2>&1
$ROOT/bin/rpm -ivh $RPMS/bash-*.rpm --force --root $ROOT >> $LOGFILE 2>&1

if [ -f $RPMS/ldconfig-*.rpm ] ; then
    $ROOT/bin/rpm -ivh $RPMS/ldconfig-*.rpm --force --root $ROOT >> $LOGFILE
fi
$ROOT/bin/rpm -ivh $RPMS/basesystem-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1
fi

#echo $ROOT | grep '/work/rhas' > /dev/null 2>&1
#if [ $? = 0 ] ; then
#    if [ ! -d $ROOT/lib ] ; then
#	echo "$ROOT/lib: no such directory."
#	exit 1
#    fi
#    ln -s /lib/kernel/2.4.9-e.3/libredhat-kernel.so.1.0.1 $ROOT/lib/libredhat-kernel.so.1.0.1
#    ln -s /lib/libredhat-kernel.so.1.0.1 $ROOT/lib/libredhat-kernel.so.1
#    $ROOT/bin/rpm -ivh $RPMS/glibc-[^d]*.rpm $RPMS/libaio*.rpm --force --nodeps --root $ROOT >> $LOGFILE 2>&1
#    rm -f $ROOT/lib/libredhat-kernel.so.1.0.1 $ROOT/lib/libredhat-kernel.so.1
#else
#    $ROOT/bin/rpm -ivh $RPMS/glibc-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1
#fi
#$ROOT/bin/rpm -ivh $RPMS/glibc-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1
#$ROOT/bin/rpm -ivh $RPMS/glibc-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1
#$ROOT/bin/rpm -ivh $RPMS/glibc-*.rpm --force --root $ROOT >> $LOGFILE 2>&1
#$ROOT/bin/rpm -ivh $RPMS/bash-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1
#$ROOT/bin/rpm -ivh $RPMS/iputils-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1
#$ROOT/bin/rpm -ivh $RPMS/iproute-[^d]*.rpm --force --root $ROOT >> $LOGFILE 2>&1


#echo install all rpm packages
#rm -f 	$RPMS/glibc-2.*i386.rpm \
#		$RPMS/glibc-2.*i586.rpm \
#		$RPMS/kernel*i586.rpm \
#		$RPMS/PoseidonPPP*.rpm \
#		$RPMS/ppp241*.rpm \
#		$RPMS/firstboot*.rpm \
#		$RPMS/system-config-keyboard*.rpm \
#		$RPMS/anaconda*.rpm \
#		$RPMS/rhpxl*.rpm 
#		$RPMS/rhpl*.rpm # needed by booty

echo "Trying intall all rpm packages."
$ROOT/bin/rpm -ivh $RPMS/*.rpm  --root $ROOT --test || exit 1
echo "Test passed."

# Begin install all rpm packs
$ROOT/bin/rpm -ivh $RPMS/*.rpm  --root $ROOT | tee $LOGFILE

if [ "$?" != "0" ] ; then
   echo Please see $oldROOT/$LOGFILE
   echo If you get a dependency related error, 
   echo please try create-virbuild.sh with -f1 or -f2 option
   return 1
fi

echo setup
ldconfig

#echo 'canna:x:39:' >> $ROOT/etc/group
#useradd -u 39 -g 39 -d /var/lib/canna -s /bin/false -c 'Canna Service User' canna
CHROOT
########
    ROOT=$oldROOT
    RPMS=$oldRPMS
    chmod +x $1
}

# Install RPMs using cpio
# usage: vague_inst Directory PACKAGE_FILE ...
vague_inst () {
    inst_dir=$1
    shift
    mkdir -p $inst_dir
    for i in $*
    do
        rpm2cpio $i | (cd $inst_dir; cpio -idm)
    done
}

#
# Main function

#WORKDIR=`dirname $0`
#cd $WORKDIR
echo "Usage: $0 LOCALPOOL VIRBUILDDIR\n"  
echo "Please DO NOT put LOCALPOOL under VIRBUILDDIR"
echo "Enter will continue, or Ctrl+C quit"
read

if [ -z "$2" ]; then
    echo "Usage: $0 LOCALPOOL VIRBUILDDIR\n"  
    exit 0;
fi

if [ "$2" == "/" ] ; then
    echo "Please specify another directory"
    exit 0;
fi

if [ -d $2 ] && [ $(ls --inode -dl $2 | awk '{print $1}' ) -eq \
                  $(ls --inode -dl /  | awk '{print $1}' ) ]; then
    echo "Please specify another directory"
    exit 0;
fi
  
# RPMS: Pool of RPMs
# ROOT: Topdir of virbuild
RPMS=$1
pushd $2
ROOT=`pwd`
popd

umount $ROOT/proc >/dev/null 2>&1

rm -rf   $ROOT
mkdir -p $ROOT/var/lib/rpm	\
         $ROOT/tmp/RPMS		\
         $ROOT/bin		\
         $ROOT/proc		\
         $ROOT/etc

# Enable to work rpm command
vague_inst $ROOT $RPMS/glibc-2.*.rpm		\
                 $RPMS/glibc-common-2.*.rpm	\
                 $RPMS/glibc-devel-2.*.rpm	\
		 $RPMS/bzip2-libs-*.rpm	\
                 $RPMS/popt-*.rpm		\
                 $RPMS/elfutils-libelf-*.rpm	\
		 $RPMS/sqlite-*.rpm  \
		 $RPMS/openssl-*.rpm  \
		 $RPMS/krb5-libs-*.rpm \
		 $RPMS/e2fsprogs-libs-*.rpm \
		 $RPMS/expat-*.rpm \
		 $RPMS/libstdc++-*.rpm \
		 $RPMS/coreutils-*.rpm \
		 $RPMS/libgcc43-*.rpm
#		 $RPMS/dev-*.*.rpm
vague_inst $ROOT $RPMS/rpm-*.rpm

read

# Enable to work bash command
vague_inst $ROOT $RPMS/libcap-*.*.rpm
vague_inst $ROOT $RPMS/libacl-*.*.rpm
vague_inst $ROOT $RPMS/libattr-*.*.rpm
vague_inst $ROOT $RPMS/bash-*.*.rpm
vague_inst $ROOT $RPMS/ncurses-libs-*.rpm

# Enable to work install-info command
vague_inst $ROOT $RPMS/zlib-[^d]*.*.rpm
vague_inst $ROOT $RPMS/info-*.*.rpm

if [ -f /etc/resolv.conf ] ; then
    cp /etc/resolv.conf $ROOT/etc/resolv.conf
fi

vague_inst $ROOT/tmp $RPMS/gzip-*.*.rpm
cp $ROOT/tmp/bin/gzip  $ROOT/bin/

vague_inst $ROOT/tmp $RPMS/grep-*.*.rpm
cp $ROOT/tmp/bin/grep  $ROOT/bin/

vague_inst $ROOT/tmp $RPMS/coreutils-*.*.rpm
cp $ROOT/tmp/bin/ln $ROOT/bin/
cp $ROOT/tmp/bin/cat $ROOT/bin/
cp $ROOT/tmp/bin/rm $ROOT/bin/

#vague_inst $ROOT/ $RPMS/libselinux*.*.rpm
vague_inst $ROOT/ $RPMS/db4-*.rpm
vague_inst $ROOT/ $RPMS/file-libs*.rpm
vague_inst $ROOT/ $RPMS/lua-*.rpm
vague_inst $ROOT/ $RPMS/nss-*.rpm
vague_inst $ROOT/ $RPMS/nspr-*.rpm

#for install vim
vague_inst $ROOT/ $RPMS/perl-lib*.rpm
vague_inst $ROOT/ $RPMS/python-*.rpm
vague_inst $ROOT/ $RPMS/vim-*.rpm

touch $ROOT/etc/mtab

echo $ROOT > $ROOT/etc/virtroot

#cp /project/bin/simple-build-check.sh $ROOT/usr/bin

if [ -d /etc/sysconfig/network ] ; then
	cp /etc/sysconfig/network $ROOT/etc/sysconfig/ 
fi

if [ -d /etc/sysconfig/network-scripts/ifcfg-eth0 ] ; then
	cp /etc/sysconfig/network-scripts/ifcfg-eth0 \
	 $ROOT/etc/sysconfig/network-scripts/ 
fi

mkdir -p /sys /proc
mount proc $ROOT/proc -t proc
mount -t sysfs none /sys/

 
echo "virbuild $TIME"> $ROOT/virbuild
virbuildname=`basename $ROOT`
echo $virbuildname > $ROOT/etc/$virbuildname
rm -f $ROOT/usr/tmp


# I need NOT to copy RPMS
# Copy RPMS to virbuild
#for i in $RPMS/*.rpm
#do
##    [ -f $ROOT/tmp/RPMS/$(basename $i) ] || \
#    #cp $i $ROOT/tmp/RPMS/
#    ln $i $ROOT/tmp/RPMS/ || exit 1
#done
#cp $WORKDIR/dev-*.rpm $ROOT/tmp/RPMS/

# remove unneeded packs:
UNNEEDED_PACKS="glibc-2.*i386.rpm glibc-2.*i586.rpm kernel*i586.rpm PoseidonPPP ppp241 firstboot system-config-keyboard anaconda rhpxl anthy-el-xemacs poppler-qt4-devel AdobeReader_* firefox-*-resources google-desktop-linux ooobasis* openoffice.org* perl-Frontier-RPC-Client pips pipslite xorg.conf-es xorg.conf-pt_BR gnome-screensaver xscreensaver kxk-pt_BR kxk-es kxk-ru_RU kde-i18n"
for loop in $UNNEEDED_PACKS;
do
	rm -f $ROOT/tmp/RPMS/$loop*
	#rm -f $RPMS/$loop-*.rpm
done


# change root(/) directory
make_chroot_script $ROOT/tmp/chroot.sh || exit 1
/usr/sbin/chroot $ROOT /tmp/chroot.sh || exit 1

mkdir -p $ROOT/root/
cat > $ROOT/root/.bashrc <<EOF
# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# The followings are for virbuild.
export _RPM_VIRTUAL_HOSTNAME=kunlunjade.builder2.redflag-linux.com
[ -f ~/env_java.ini ] && . ~/env_java.ini

unset LD_LIBRARY_PATH
EOF

cp /etc/fstab $ROOT/etc
cp /etc/hosts $ROOT/etc

#cp /project/koumei/build/virbuild/etc/fstab $ROOT/etc
#cp /project/koumei/build/virbuild/etc/mtab $ROOT/etc
#cp /project/koumei/build/virbuild/etc/hosts $ROOT/etc
#cp /project/koumei/build/virbuild/etc/httpd/conf/httpd.conf $ROOT/etc/httpd/conf/
#mv $ROOT/etc/rpm $ROOT/etc/rpm.bak
#cp /project/koumei/build/virbuild/etc/rpm $ROOT/etc -rfa

