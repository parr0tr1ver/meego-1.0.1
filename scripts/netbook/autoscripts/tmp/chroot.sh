#! /bin/bash -x

export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin

rm -f /tmp/create-virbuild.log
##### 
# below are very ugly. I'll fix later, hopefully  

# create /dev/null
mkdir -p /dev/
/bin/mknod /dev/null c 1 3

echo now installing rpms...... please wait a few minutes

//bin/rpm --initdb --root /

# disable the following line for test
if false; then
//bin/rpm -ivh /tmp/RPMS/libselinux-*.rpm --force --nodeps --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/setup-*.rpm  --force    --root / > /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/glibc-common-*.rpm --force --nodeps --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/glibc-2.*i686.rpm --force --nodeps --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/filesystem-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/libgcc-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/tzdata-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/setup-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/filesystem-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
//bin/rpm -ivh /tmp/RPMS/bash-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1

if [ -f /tmp/RPMS/ldconfig-*.rpm ] ; then
    //bin/rpm -ivh /tmp/RPMS/ldconfig-*.rpm --force --root / >> /tmp/create-virbuild.log
fi
//bin/rpm -ivh /tmp/RPMS/basesystem-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
fi

#echo / | grep '/work/rhas' > /dev/null 2>&1
#if [ 0 = 0 ] ; then
#    if [ ! -d //lib ] ; then
#	echo "//lib: no such directory."
#	exit 1
#    fi
#    ln -s /lib/kernel/2.4.9-e.3/libredhat-kernel.so.1.0.1 //lib/libredhat-kernel.so.1.0.1
#    ln -s /lib/libredhat-kernel.so.1.0.1 //lib/libredhat-kernel.so.1
#    //bin/rpm -ivh /tmp/RPMS/glibc-[^d]*.rpm /tmp/RPMS/libaio*.rpm --force --nodeps --root / >> /tmp/create-virbuild.log 2>&1
#    rm -f //lib/libredhat-kernel.so.1.0.1 //lib/libredhat-kernel.so.1
#else
#    //bin/rpm -ivh /tmp/RPMS/glibc-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
#fi
#//bin/rpm -ivh /tmp/RPMS/glibc-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
#//bin/rpm -ivh /tmp/RPMS/glibc-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
#//bin/rpm -ivh /tmp/RPMS/glibc-*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
#//bin/rpm -ivh /tmp/RPMS/bash-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
#//bin/rpm -ivh /tmp/RPMS/iputils-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1
#//bin/rpm -ivh /tmp/RPMS/iproute-[^d]*.rpm --force --root / >> /tmp/create-virbuild.log 2>&1


#echo install all rpm packages
#rm -f 	/tmp/RPMS/glibc-2.*i386.rpm #		/tmp/RPMS/glibc-2.*i586.rpm #		/tmp/RPMS/kernel*i586.rpm #		/tmp/RPMS/PoseidonPPP*.rpm #		/tmp/RPMS/ppp241*.rpm #		/tmp/RPMS/firstboot*.rpm #		/tmp/RPMS/system-config-keyboard*.rpm #		/tmp/RPMS/anaconda*.rpm #		/tmp/RPMS/rhpxl*.rpm 
#		/tmp/RPMS/rhpl*.rpm # needed by booty

echo "Trying intall all rpm packages."
//bin/rpm -ivh /tmp/RPMS/*.rpm  --root / --test || exit 1
echo "Test passed."

# Begin install all rpm packs
//bin/rpm -ivh /tmp/RPMS/*.rpm  --root / | tee /tmp/create-virbuild.log

if [ "0" != "0" ] ; then
   echo Please see .//tmp/create-virbuild.log
   echo If you get a dependency related error, 
   echo please try create-virbuild.sh with -f1 or -f2 option
   return 1
fi

echo setup
ldconfig

#echo 'canna:x:39:' >> //etc/group
#useradd -u 39 -g 39 -d /var/lib/canna -s /bin/false -c 'Canna Service User' canna
