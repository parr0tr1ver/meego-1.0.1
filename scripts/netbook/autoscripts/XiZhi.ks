lang zh_CN.UTF-8
keyboard us
timezone Asia/Shanghai
auth --useshadow --enablemd5
#selinux --permissive
selinux --disabled
firewall --disabled
xconfig --startxonboot
services --enabled=NetworkManager --disabled=network,sshd
part / --size=6120

repo --name="Red Flag inMini 2010 Base" --baseurl=file:///XiZhi-repo-201009061712
repo --name="Red Flag inMini 2010 Update" --baseurl=file:///XiZhi-repo-201009061712-update

%packages

# import from moblin livecd
# >> begin <<
#abrt
#abrt-addon-ccpp
#abrt-addon-kerneloops
#abrt-addon-python
#abrt-desktop
#abrt-gui
#abrt-libs
#abrt-netbook
#abrt-plugin-bugzilla
#abrt-plugin-httpreporter
#abrt-plugin-logger
#abrt-plugin-runapp
acl
acpid
#adobe-release-i386
alsa-lib
alsa-plugins-pulseaudio
alsa-utils
#anerley
#aria2
#art-sharp2
atk
attr
#augeas-libs
authconfig
#authconfig-gtk
autoconf
automake
avahi
avahi-glib
avahi-gobject
avahi-ui
#banshee-1
#banshee-1-backend-engine-gstreamer
#banshee-1-backend-platform-gnome
#banshee-1-backend-platform-meego
#banshee-1-backend-platform-unix
#banshee-1-branding-meego
#banshee-1-client-classic
#banshee-1-core
#banshee-1-dmp
#banshee-1-dmp-mtp
#banshee-1-extensions-default
#banshee-1-lang
basesystem
bash
#bisho
bluez
bluez-libs
#bognor-regis
bootchart
btrfs-progs
bzip2
bzip2-libs
ca-certificates
cairo
c-ares
#carrick
#cheese
chkconfig
#chrome-meego-extension
#chromium
#chromium-libs
cjkuni-fonts
clutter
clutter-gesture
clutter-gtk
clutter-imcontext
comps-extras
#connman
ConsoleKit
ConsoleKit-libs
ConsoleKit-x11
coreutils
coreutils-libs
cpio
cracklib
cracklib-dicts
cracklib-python
cups
cups-libs
curl
cyrus-sasl-lib
cyrus-sasl-md5
cyrus-sasl-plain
db4
db4-utils
dbus
dbus-glib
dbus-libs
dbus-python
dbus-x11
dejavu-fonts-common
dejavu-sans-fonts
deltarpm
desktop-file-utils
#DeviceKit-power
device-mapper
device-mapper-libs
dhclient
dhcpv6-client
dmidecode
docbook-dtds
dosfstools
droid-fonts-common
droid-sans-fonts
droid-sans-mono-fonts
droid-serif-fonts
e2fsprogs
e2fsprogs-libs
ecryptfs-utils
eggdbus
eject
elfutils
elfutils-libelf
elfutils-libs
#empathy
enchant
#eog
#evince
#evince-libs
#evolution
evolution-data-server
#evolution-libs
exempi
expat
farsight2
fastinit
file
file-libs
#file-roller
filesystem
findutils
firefox
#firstboot
flac
#flash-plugin
fontconfig
fontpackages-filesystem
foomatic
foomatic-db
foomatic-db-filesystem
foomatic-db-ppds
freetype
#frozen-bubble
fuse
gamin
#garage-client-services
#garage-netbook-ui
gawk
gcalctool
gcalctool-doc
GConf-dbus
#gconf-sharp2
gdb
gdbm
#gdu-nautilus-extension
gedit
generic-logos
geoclue
gettext
ghostscript
ghostscript-fonts
#glade-sharp2
glib2
glibc
glibc-common
#glib-sharp2
glx-utils
gmime
gmp
gnome-bluetooth
gnome-bluetooth-gnome
gnome-bluetooth-libs
#gnome-bluetooth-moblin
#gnome-control-center-netbook
#gnome-desktop
gnome-disk-utility
gnome-disk-utility-libs
gnome-disk-utility-ui-libs
#gnome-doc-utils
#gnome-doc-utils-stylesheets
#gnome-games
#gnome-games-help
#gnome-icon-theme
gnome-keyring
gnome-keyring-pam
#gnome-media
#gnome-media-libs
#gnome-menus
#gnome-mime-data
#gnome-packagekit
#gnome-python2
#gnome-python2-canvas
#gnome-python2-desktop
#gnome-python2-gnomekeyring
#gnome-python2-gnomevfs
#gnome-screensaver
#gnome-settings-daemon
#gnome-sharp2
#gnome-terminal
#gnome-utils
#gnome-vfs2
#gnome-vfs-sharp2
gnupg
gnupg2
gnutls
#google-gadgets
#google-gadgets-meego
gpgme
#gpg-pubkey
grep
grub
grubby
gssdp
gst-plugins-bad-free
gst-plugins-base
gst-plugins-good
gstreamer
gtk2
gtkhtml3
#gtk-sharp2
gtksourceview2
guile
gupnp
gupnp-av
gupnp-igd
#gvfs
#gvfs-gphoto2
#gvfs-obexftp
#gvfs-smb
gypsy
gzip
hdparm
hicolor-icon-theme
hunspell
hwdata
info
iproute
iputils
iso-codes
#jakarta-commons-cli
#jakarta-commons-lang
#jakarta-commons-logging
jana
jasper
jasper-libs
#java-1.5.0-gcj
#java_cup
#jpackage-utils
json-glib
kbd
kernel-devel
kernel-headers
kernel-netbook
kernel-netbook-devel
keyutils
keyutils-libs
krb5-libs
lcms
lcms-libs
less
libacl
libarchive
libart_lgpl
libasyncns
libatasmart
libattr
libblkid
libbonobo
libbonoboui
#libcanberra
#libcanberra-gtk2
libcap
libchamplain
libchewing
libcom_err
libcroco
libcurl
libdaemon
libdrm
libedit
liberation-fonts-common
liberation-fonts-compat
liberation-mono-fonts
liberation-sans-fonts
liberation-serif-fonts
libevent
libexif
libffi
libfontenc
libgcc
#libgcj
libgcrypt
libgee
libglade2
libgnome
libgnomecanvas
libgnomekbd
libgnome-keyring
libgnomeui
libgpg-error
libgphoto2
libgsf
libgtop2
libgudev1
libgweather
libhangul
libical
libICE
libicu
libIDL
libidn
libjpeg
libksba
libmng
libmtp
libnice
libnl
libnotify
libogg
liboil
libpciaccess
libpng
libproxy
libproxy-gnome
libproxy-python
libproxy-webkit
libpurple
libqttracker
librsvg2
libsexy
libsilc
libSM
libsmbclient
libsndfile
libsocialweb
libsocialweb-keys
libsoup
libspectre
libss
libstdc++
libtalloc
libtasn1
libtdb
libthai
libtheora
libtiff
libtool-ltdl
libudev
libusb
libuser
libuser-python
libutempter
libuuid
libvisual
libvorbis
libwnck
libX11
libXau
libXaw
libxcb
libXcomposite
libXcursor
libXdamage
libXdmcp
libXext
libXfixes
libXfont
libXft
libXi
libXinerama
libxkbfile
libxklavier
libxml2
libxml2-python
libXmu
libXpm
libXrandr
libXrender
libXres
libXScrnSaver
libxslt
libXt
libXtst
libXv
libXxf86misc
libXxf86vm
libzypp
linux-firmware
lockdev
logrotate
lua
m2crypto
m4
mailcap
makebootfat
MAKEDEV
matchbox-panel
meego-help
#meego-netbook-intro
meego-netbook-repo
#meego-non-oss-repo
meego-release
meego-repos
mesa-dri-i915-driver
mesa-dri-i965-driver
mesa-dri-swrast-driver
mesa-libGL
mesa-libGLU
messagingframework
mingetty
minizip
mkinitrd
mobile-broadband-provider-info
#moblin-cursor-theme
#moblin-gtk-engine
#moblin-icon-theme
#moblin-menus
#moblin-panel-applications
#moblin-panel-datetime
#moblin-panel-devices
#moblin-panel-myzone
#moblin-panel-pasteboard
#moblin-panel-people
#moblin-panel-status
#moblin-panel-web
#moblin-panel-zones
#moblin-sound-theme
moblin-user-skel
moblin-ux-settings
module-init-tools
#mono-addins
#mono-core
#mono-data
#mono-zeroconf
mozilla-filesystem
mtools
#mutter
#mutter-moblin
#mutter-moblin-branding-upstream
#mx
#nautilus
#nautilus-extensions
ncurses
ncurses-base
ncurses-libs
#ndesk-dbus
#ndesk-dbus-glib
netbook-backgrounds
net-tools
#neverball
notify-python
#notify-sharp
nspr
nss
nss-mdns
nss-softokn-freebl
nss-sysinit
ntp
ntpdate
o3read
obexd
obex-data-server
ofono
opengl-games-utils
openjpeg-libs
openldap
openobex
openssh
openssh-clients
openssl
ORBit2
PackageKit
PackageKit-browser-plugin
PackageKit-device-rebind
PackageKit-glib
PackageKit-gtk-module
PackageKit-qt
PackageKit-zypp
pam
pam-modules-cracklib
pango
#papyon
parted
passwd
pciutils
pcre
perl
perl-File-BaseDir
perl-File-DesktopEntry
perl-File-MimeInfo
perl-gettext
perl-libs
perl-Module-Pluggable
perl-Pod-Escapes
perl-Pod-Simple
perl-SDL
perl-version
phonon-backend-gstreamer
pidgin-sipe
pixman
pkgconfig
plymouth-lite
pm-utils
polkit
polkit-gnome
poppler
poppler-glib
poppler-utils
popt
prelink
procps
psmisc
pth
pulseaudio
pulseaudio-module-x11
pycairo
pygobject2
pygpgme
pygtk2
pygtk2-libglade
#pyOpenSSL
pyparted
python
python-decorator
python-iniparse
python-libs
python-numeric
python-pycurl
python-sexy
#python-telepathy
python-urlgrabber
qt
qt-mobility
qt-sqlite
qt-x11
rarian
rarian-compat
readline
rest
rhpl
rootfiles
rpm
rpm-libs
rpm-python
rsync
rsyslog
rtkit
samba-winbind-clients
sample-media
satsolver-tools
#scim
#scim-bridge
#scim-bridge-clutter
#scim-bridge-gtk
#scim-chewing
#scim-hangul
#scim-pinyin
#scim-skk
SDL
SDL_gfx
SDL_image
SDL_mixer
SDL_net
SDL_Pango
SDL_ttf
sed
setup
sg3_utils-libs
sgml-common
shadow-utils
shared-mime-info
#sinjdoc
skkdic
sound-theme-freedesktop
speex
sqlite
sreadahead
startup-notification
sudo
#syncevolution
#syncevolution-evolution
#syncevolution-gtk
syslinux
syslinux-extlinux
#system-config-date
#system-config-date-docs
#system-config-language
#system-config-printer
#system-config-printer-libs
sysvinit
sysvinit-tools
taglib
#taglib-sharp
tar
tasks
#telepathy-butterfly
#telepathy-farsight
#telepathy-filesystem
#telepathy-gabble
#telepathy-glib
#telepathy-haze
#telepathy-idle
#telepathy-mission-control
#telepathy-salut
time
tmpwatch
totem-pl-parser
#tracker
trousers
ttmkfdir
tzdata
udev
udev-rules-netbook
udisks
unique
unzip
urw-fonts
usbutils
usermode
usermode-gtk
usleep
util-linux-ng
uxlaunch
v8
vim-minimal
vlgothic-fonts
vlgothic-fonts-common
vte
WebKit-gtk
wireless-tools
wpa_supplicant
xdg-user-dirs
xdg-user-dirs-gtk
xdg-utils
xinetd
xkeyboard-config
xml-common
xmlrpc-c
xmlrpc-c-client
xorg-x11-apps
xorg-x11-drv-evdev
xorg-x11-drv-intel
xorg-x11-drv-keyboard
xorg-x11-drv-kvm
xorg-x11-drv-mouse
xorg-x11-drv-synaptics
xorg-x11-drv-vesa
xorg-x11-drv-vmmouse
xorg-x11-drv-vmware
xorg-x11-drv-void
xorg-x11-fonts-100dpi
xorg-x11-fonts-ISO8859-1-100dpi
xorg-x11-fonts-misc
xorg-x11-fonts-Type1
xorg-x11-font-utils
xorg-x11-server
xorg-x11-server-common
xorg-x11-server-utils
xorg-x11-server-Xorg
xorg-x11-twm
xorg-x11-utils
xorg-x11-utils-iceauth
xorg-x11-utils-rgb
xorg-x11-utils-sessreg
xorg-x11-utils-xcmsdb
xorg-x11-utils-xdpyinfo
xorg-x11-utils-xdriinfo
xorg-x11-utils-xev
xorg-x11-utils-xfd
xorg-x11-utils-xfontsel
xorg-x11-utils-xgamma
xorg-x11-utils-xhost
xorg-x11-utils-xlsatoms
xorg-x11-utils-xlsclients
xorg-x11-utils-xlsfonts
xorg-x11-utils-xmodmap
xorg-x11-utils-xprop
xorg-x11-utils-xrandr
xorg-x11-utils-xrdb
xorg-x11-utils-xrefresh
xorg-x11-utils-xset
xorg-x11-utils-xsetroot
xorg-x11-utils-xvinfo
xorg-x11-utils-xwininfo
xorg-x11-xauth
xorg-x11-xinit
xorg-x11-xkb-utils
xterm
xulrunner
xz-libs
#yelp
yum
yum-metadata-parser
yum-utils
zenity
zip
zlib
zypper
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
#kdebindings
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
#amarok
xine-lib-extras-freeworld
thunderbird
hunspell-en

gimp
#guvcview
stardict
stardict-dic-zh_CN
stardict-dic-zh_TW
stardict-dic-en

linuxqq
kmess
qca2
qca-ossl

dazhihui
flashplugin
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
diffutils
vim-enhanced
# >> end <<

# input method
#ibus
#ibus-gtk
#ibus-libs
#ibus-m17n
#ibus-pinyin
#ibus-rawcode
#ibus-table
#ibus-table-additional
#ibus-table-cangjie
#ibus-table-erbi
#ibus-table-wubi

NetworkManager
NetworkManager-gnome
#NetworkManager-vpnc
#NetworkManager-openvpn
notification-daemon

# ntfs support
ntfs-3g
ntfsprogs

#codecs
#gstreamer-ffmpeg
#gstreamer-plugins-ugly

# compress support
rar
unrar
zip

# default gtk theme
#Clearlooks-NeXT-theme

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
