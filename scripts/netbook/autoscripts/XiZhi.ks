lang zh_CN.UTF-8
keyboard us
timezone Asia/Shanghai
auth --useshadow --enablemd5
#selinux --permissive
selinux --disabled
firewall --disabled
xconfig --startxonboot
part / --size 4096
services --enabled=NetworkManager --disabled=network,sshd

#repo --name="DT7 Update" --mirrorlist=http://172.16.82.249/yum/mirrorlist.php?repo=redflag-update-7.0&arch=i386
#repo --name="DT7 Base" --mirrorlist=http://172.16.82.249/yum/mirrorlist.php?repo=redflag-base-7.0&arch=i386
#repo --name="DT7 Update" --baseurl=http://172.16.82.249/yum/rpmupdate
repo --name="Red Flag Netbook Base" --baseurl=http://172.16.82.249/netbookyum/moblin-2.0-base
#repo --name="Red Flag Netbook Devel" --baseurl=http://172.16.82.249/netbookyum/devel
repo --name="Red Flag Netbook Update" --baseurl=http://172.16.82.249/netbookyum/moblin-2.0-update

%packages
@base-x
@base
@core
@fonts
#@legacy-fonts
@admin-tools
@dial-up
@hardware-support
#@printing
@games
@graphical-internet
@graphics
@sound-and-video
#@gnome-desktop
@kde-desktop

# import from moblin livecd
# >> begin <<

# >> end << 

# kde 
# >> begin <<
kdebase
kdebase-libs
kdebase-runtime
kdebase-runtime-libs
kdebase-workspace
kdebase-workspace-libs
kdebase-workspace-wallpapers
kdebindings
kde-filesystem
kde-filesystem
kde-filesystem
kdelibs
kde-l10n-Chinese
kde-l10n-Chinese-Traditional
kde-settings
kde-settings-pulseaudio
kdegraphics
kdegames
kdemultimedia
kdenetwork
kdepim
kdeplasma-addons
kdeutils
kdm
plasma-applet-miniquicklaunch
plasma-applet-minitasks
plasma-applet-panelspacer
#daisy
fancytasks
SabreTiger
kickoff
kickoff-scripts
# >> end << 


# redflag installer
rfinstaller

redflag-release
redflag-menus
zhfonts
wqy-zenhei-fonts
rfInmini

# applications
amarok
xine-lib-extras-freeworld
thunderbird
hunspell-en

gimp
guvcview
stardict
stardict-dic-zh_CN
stardict-dic-zh_TW
stardict-dic-en

linuxqq
kmess
qca2
qca-ossl

dazhihui
flash-plugin
aliedit
cooliris

firstconfig
rfthememanager

# compilers and develop tools
# >> begin <<
kernel-headers
make
gcc
rpm-build
# >> end <<

# input method
ibus
ibus-gtk
ibus-libs
ibus-m17n
ibus-pinyin
ibus-rawcode
ibus-table
ibus-table-additional
ibus-table-cangjie
ibus-table-erbi
ibus-table-wubi

#NetworkManager
NetworkManager-gnome
NetworkManager-vpnc
NetworkManager-openvpn
notification-daemon

#new games
#cinelerra

# ntfs support
ntfs-3g
ntfsprogs

#codecs
gstreamer-ffmpeg
gstreamer-plugins-ugly

# compress support
rar
unrar
zip

# default gtk theme
Clearlooks-NeXT-theme

%end

%post

cat >> /etc/skel/.gtkrc-2.0 << GTK_EOF
gtk-theme-name = "Clearlooks-NeXT"
GTK_EOF

# /etc/init.d/redflag-live will run firstconfig before kde
cat > /etc/init.d/redflag-live << LIVE_EOF
#! /bin/sh

# startup scripts for inmini livecd startup
#
# chkconfig: 345 00 99
# description: startup scripts for inmini livecd startup

. /etc/init.d/functions

if strstr "\`cat /proc/cmdline\`" liveimg ; then
	if  ! grep -q "/usr/bin/fconfigrun.sh" /usr/bin/startx ; then
		sed -i '/#!\/bin\/sh/a\su -l root -c \"/usr/bin/xinit /usr/bin/fconfigrun.sh\"' /usr/bin/startx
	fi
fi

# add redflag user with no passwd
/usr/sbin/useradd --groups audio,video -c "RedFlag inmini Live" redflag
/usr/bin/passwd -d redflag > /dev/null

su - redflag -c "mkdir -p /home/redflag/.kde/share/config/"
cat >> /home/redflag/.kde/share/config/plasma-desktop-appletsrc << MENU_EOF
//copy from dt7, add by pwp

[Containments][8][Applets][18]
geometry=160,8,160,80
immutability=1
plugin=icon
zvalue=4
[Containments][8][Applets][18][Configuration]
Url=file:///usr/share/applications/rfinstaller.desktop

//add by pwp end

MENU_EOF

LIVE_EOF

chmod +x /etc/init.d/redflag-live
/sbin/chkconfig --add redflag-live

#with Sian's suggestion, speed up
/sbin/chkconfig --del fuse
#/sbin/chkconfig --del NetworkManager

# copy from dt7, add rfinstaller.desktop to plasma desktop
su - redflag -c "mkdir -p /home/redflag/.kde/share/config/"
su - redflag -c "touch /home/redflag/.kde/share/config/plasma-desktop-appletsrc" 

# workaround avahi segfault (#279301)
touch /etc/resolv.conf

sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.conf

cat > /etc/X11/X_blacklist << X_BLACKLIST_EOF
1002:7196 radeonhd
8086:2a12 vesa
8086:29c2 vesa
10de:03d0 nouveau
X_BLACKLIST_EOF


# add by pwp
# use the locale file to add/delete some package.
mkdir -p /usr/share/apps/rfpackages_conf/
cat > /usr/share/apps/rfpackages_conf/rfpackages.locale << EOF
#               FORMAT
#               description after a '#'
#               locale=en_US.UTF-8
#               del_packages=p1,p2,p3 ...
#               add_packages=p4,p5,p6 ...
#
#               locale=zh_CN.UTF-8
#               del_packages=p1,p2,p3 ...
#               add_packages=p4,p5,p6 ...
#
# del or add some packages according to locale
locale=en_US.UTF-8
del_packages=linuxqq,firefox-en_US-resources,kickoff-scripts,

EOF
# add by pwp end

%end

%post --nochroot
# create initrd4disk start

INITRD4DISK_DIR=tmp_initrd4disk
rm -rf $INITRD4DISK_DIR
mkdir $INITRD4DISK_DIR 
pushd $INITRD4DISK_DIR
gzip -dc $LIVE_ROOT/isolinux/initrd0.img | cpio -idmv
#cp -f ../initrd4disk/sbin/real-init sbin/real-init
#cp -ar ../initrd4disk/sbin/mount.ntfs* sbin/
#cp -ar ../initrd4disk/lib/libntfs-3g* lib/
KERNEL_VERSION=$(/bin/ls lib/modules/)
echo $KERNEL_VERSION

rm -rf tmp_for_ext3fs
mkdir -p tmp_for_ext3fs
mount -o loop /var/tmp/imgcreate-*/tmp*/ext3fs.img tmp_for_ext3fs

cp -f ../init-disk init
cp -ar tmp_for_ext3fs/sbin/mount.ntfs* sbin/
cp -ar tmp_for_ext3fs/lib/libntfs-3g* lib/
cp -a tmp_for_ext3fs/lib/udev/*id lib/udev/
cp -a tmp_for_ext3fs/lib/libvolume_id.* lib/

cp tmp_for_ext3fs/lib/modules/$KERNEL_VERSION/kernel/fs/fuse/fuse.ko lib/modules/$KERNEL_VERSION/fuse.ko

umount tmp_for_ext3fs
rmdir tmp_for_ext3fs

/sbin/depmod -b . $KERNEL_VERSION
find . | cpio --quiet -c -o | gzip -9 -n > $LIVE_ROOT/isolinux/initrd4disk.img

popd

# create initrd4disk end

# create initrd4net start
INITRD4NET_DIR=tmp_initrd4net
rm -rf $INITRD4NET_DIR
mkdir $INITRD4NET_DIR 
pushd $INITRD4NET_DIR
gzip -dc ../initrd4net.img | cpio -idmv

rm -rf tmp_for_ext3fs
mkdir -p tmp_for_ext3fs
mount -o loop /var/tmp/imgcreate-*/tmp*/ext3fs.img tmp_for_ext3fs
cp -ar tmp_for_ext3fs/lib/modules/$KERNEL_VERSION/ lib/modules/
umount tmp_for_ext3fs
rmdir tmp_for_ext3fs

find . | cpio --quiet -c -o | gzip -9 -n > $LIVE_ROOT/isolinux/initrd4net.img

popd

# create initrd4net end

cp -a hdboot.sh $LIVE_ROOT/
cp -a usb-live-tool.sh $LIVE_ROOT/

%end
