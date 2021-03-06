#
# live.py : LiveImageCreator class for creating Live CD images
#
# Copyright 2007, Red Hat  Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

import os
import os.path
import glob
import shutil
import subprocess
import logging

from imgcreate.errors import *
from imgcreate.fs import *
from imgcreate.creator import *

class LiveImageCreatorBase(LoopImageCreator):
    """A base class for LiveCD image creators.

    This class serves as a base class for the architecture-specific LiveCD
    image creator subclass, LiveImageCreator.

    LiveImageCreator creates a bootable ISO containing the system image,
    bootloader, bootloader configuration, kernel and initramfs.

    """

    def __init__(self, *args):
        """Initialise a LiveImageCreator instance.

        This method takes the same arguments as ImageCreator.__init__().

        """
        LoopImageCreator.__init__(self, *args)

        self.skip_compression = False
        """Controls whether to use squashfs to compress the image."""

        self.skip_minimize = False
        """Controls whether an image minimizing snapshot should be created.

        This snapshot can be used when copying the system image from the ISO in
        order to minimize the amount of data that needs to be copied; simply,
        it makes it possible to create a version of the image's filesystem with
        no spare space.

        """

        self._timeout = kickstart.get_timeout(self.ks, 10)
        """The bootloader timeout from kickstart."""

        self._default_kernel = kickstart.get_default_kernel(self.ks, "kernel")
        """The default kernel type from kickstart."""

        self.__isodir = None

        self.__modules = ["=ata", "sym53c8xx", "aic7xxx", "=usb", "=firewire", "=mmc", "=pcmcia", "mptsas", "udf"]
        self.__modules.extend(kickstart.get_modules(self.ks))

        self._isofstype = "iso9660"

    #
    # Hooks for subclasses
    #
    def _configure_bootloader(self, isodir):
        """Create the architecture specific booloader configuration.

        This is the hook where subclasses must create the booloader
        configuration in order to allow a bootable ISO to be built.

        isodir -- the directory where the contents of the ISO are to be staged

        """
        raise CreatorError("Bootloader configuration is arch-specific, "
                           "but not implemented for this arch!")

    def _get_kernel_options(self):
        """Return a kernel options string for bootloader configuration.

        This is the hook where subclasses may specify a set of kernel options
        which should be included in the images bootloader configuration.

        A sensible default implementation is provided.

        """
        r = kickstart.get_kernel_args(self.ks)
        if os.path.exists(self._instroot + "/usr/bin/rhgb"):
            r += " rhgb"
        if os.path.exists(self._instroot + "/usr/bin/plymouth"):
            r += " rhgb"
        return r
        
    def _get_mkisofs_options(self, isodir):
        """Return the architecture specific mkisosfs options.

        This is the hook where subclasses may specify additional arguments to
        mkisofs, e.g. to enable a bootable ISO to be built.

        By default, an empty list is returned.

        """
        return []

    #
    # Helpers for subclasses
    #
    def _has_checkisomd5(self):
        """Check whether checkisomd5 is available in the install root."""
        def exists(instroot, path):
            return os.path.exists(instroot + path)

        if (exists(self._instroot, "/usr/lib/anaconda-runtime/checkisomd5") or
            exists(self._instroot, "/usr/bin/checkisomd5")):
            return True

        return False

    #
    # Actual implementation
    #
    def _base_on(self, base_on):
        """helper function to extract ext3 file system from a live CD ISO"""
        isoloop = DiskMount(LoopbackDisk(base_on, 0), self._mkdtemp())

        try:
            isoloop.mount()
        except MountError, e:
            raise CreatorError("Failed to loopback mount '%s' : %s" %
                               (base_on, e))

        # legacy LiveOS filesystem layout support, remove for F9 or F10
        if os.path.exists(isoloop.mountdir + "/squashfs.img"):
            squashimg = isoloop.mountdir + "/squashfs.img"
        else:
            squashimg = isoloop.mountdir + "/LiveOS/squashfs.img"
            
        squashloop = DiskMount(LoopbackDisk(squashimg, 0), self._mkdtemp(), "squashfs")

        try:
            if not squashloop.disk.exists():
                raise CreatorError("'%s' is not a valid live CD ISO : "
                                   "squashfs.img doesn't exist" % base_on)

            try:
                squashloop.mount()
            except MountError, e:
                raise CreatorError("Failed to loopback mount squashfs.img "
                                   "from '%s' : %s" % (base_on, e))

            # legacy LiveOS filesystem layout support, remove for F9 or F10
            if os.path.exists(squashloop.mountdir + "/os.img"):
                os_image = squashloop.mountdir + "/os.img"
            else:
                os_image = squashloop.mountdir + "/LiveOS/ext3fs.img"

            if not os.path.exists(os_image):
                raise CreatorError("'%s' is not a valid live CD ISO : neither "
                                   "LiveOS/ext3fs.img nor os.img exist" %
                                   base_on)

            shutil.copyfile(os_image, self._image)
        finally:
            squashloop.cleanup()
            isoloop.cleanup()

    def _mount_instroot(self, base_on = None):
        LoopImageCreator._mount_instroot(self, base_on)
        self.__write_initrd_conf(self._instroot + "/etc/sysconfig/mkinitrd")

    def _unmount_instroot(self):
        try:
            os.unlink(self._instroot + "/etc/sysconfig/mkinitrd")
        except:
            pass
        LoopImageCreator._unmount_instroot(self)

    def __ensure_isodir(self):
        if self.__isodir is None:
            self.__isodir = self._mkdtemp("iso-")
        return self.__isodir

    def _create_bootconfig(self):
        """Configure the image so that it's bootable."""
        self._configure_bootloader(self.__ensure_isodir())

    def _get_post_scripts_env(self, in_chroot):
        env = LoopImageCreator._get_post_scripts_env(self, in_chroot)

        if not in_chroot:
            env["LIVE_ROOT"] = self.__ensure_isodir()

        return env

    def __write_initrd_conf(self, path):
        if not os.path.exists(os.path.dirname(path)):
            makedirs(os.path.dirname(path))
        f = open(path, "a")

        f.write('LIVEOS="yes"\n')
        f.write('PROBE="no"\n')
        f.write('MODULES+="squashfs ext4 ext3 ext2 vfat msdos "\n')
        f.write('MODULES+="sr_mod sd_mod ide-cd cdrom "\n')

        for module in self.__modules:
            if module == "=usb":
                f.write('MODULES+="ehci_hcd uhci_hcd ohci_hcd "\n')
                f.write('MODULES+="usb_storage usbhid "\n')
            elif module == "=firewire":
                f.write('MODULES+="firewire-sbp2 firewire-ohci "\n')
                f.write('MODULES+="sbp2 ohci1394 ieee1394 "\n')
            elif module == "=mmc":
                f.write('MODULES+="mmc_block sdhci sdhci-pci "\n')
            elif module == "=pcmcia":
                f.write('MODULES+="pata_pcmcia  "\n')
            else:
                f.write('MODULES+="' + module + ' "\n')

        f.close()

    def __create_iso(self, isodir):
        iso = self._outdir + "/" + self.name + ".iso"

        args = ["/usr/bin/mkisofs",
                "-J", "-r",
                "-hide-rr-moved", "-hide-joliet-trans-tbl",
                "-V", self.fslabel,
                "-o", iso]

        args.extend(self._get_mkisofs_options(isodir))
        if self._isofstype == "udf":
            args.append("-allow-limited-size")

        args.append(isodir)

        if subprocess.call(args) != 0:
            raise CreatorError("ISO creation failed!")

        self.__implant_md5sum(iso)

    def __implant_md5sum(self, iso):
        """Implant an isomd5sum."""
        if os.path.exists("/usr/bin/implantisomd5"):
            implantisomd5 = "/usr/bin/implantisomd5"
        elif os.path.exists("/usr/lib/anaconda-runtime/implantisomd5"):
            implantisomd5 = "/usr/lib/anaconda-runtime/implantisomd5"
        else:
            logging.warn("isomd5sum not installed; not setting up mediacheck")
            
        subprocess.call([implantisomd5, iso])

    def _stage_final_image(self):
        try:
            makedirs(self.__ensure_isodir() + "/LiveOS")

            minimal_size = self._resparse()

            if not self.skip_minimize:
                create_image_minimizer(self.__isodir + "/LiveOS/osmin.img",
                                       self._image, minimal_size)

            if self.skip_compression:
                shutil.move(self._image, self.__isodir + "/LiveOS/ext3fs.img")
                if os.stat(self.__isodir + "/LiveOS/ext3fs.img").st_size >= 4*1024*1024*1024:
                    self._isofstype = "udf"
                    logging.warn("Switching to UDF due to size of LiveOS/ext3fs.img")
            else:
                makedirs(os.path.join(os.path.dirname(self._image), "LiveOS"))
                shutil.move(self._image,
                            os.path.join(os.path.dirname(self._image),
                                         "LiveOS", "ext3fs.img"))
                mksquashfs(os.path.dirname(self._image),
                           self.__isodir + "/LiveOS/squashfs.img")
                if os.stat(self.__isodir + "/LiveOS/squashfs.img").st_size >= 4*1024*1024*1024:
                    self._isofstype = "udf"
                    logging.warn("Switching to UDF due to size of LiveOS/squashfs.img")


            self.__create_iso(self.__isodir)
        finally:
            shutil.rmtree(self.__isodir, ignore_errors = True)
            self.__isodir = None

class x86LiveImageCreator(LiveImageCreatorBase):
    """ImageCreator for x86 machines"""
    def _get_mkisofs_options(self, isodir):
        return [ "-b", "isolinux/isolinux.bin",
                 "-c", "isolinux/boot.cat",
                 "-no-emul-boot", "-boot-info-table",
                 "-boot-load-size", "4" ]

    def _get_required_packages(self):
        return ["syslinux"] + LiveImageCreatorBase._get_required_packages(self)

    def _get_isolinux_stanzas(self, isodir):
        return ""

    def __find_syslinux_menu(self):
        for menu in ("vesamenu.c32", "menu.c32"):
            for dir in ("/usr/lib/syslinux/", "/usr/share/syslinux/"):
                if os.path.isfile(self._instroot + dir + menu):
                    return menu

        raise CreatorError("syslinux not installed : "
                           "no suitable *menu.c32 found")

    def __find_syslinux_mboot(self):
        #
        # We only need the mboot module if we have any xen hypervisors
        #
        if not glob.glob(self._instroot + "/boot/xen.gz*"):
            return None

        return "mboot.c32"

    def __copy_syslinux_files(self, isodir, menu, mboot = None):
        files = ["isolinux.bin", menu]
        if mboot:
            files += [mboot]

        for f in files:
            if os.path.exists(self._instroot + "/usr/lib/syslinux/" + f):
                path = self._instroot + "/usr/lib/syslinux/" + f
            elif os.path.exists(self._instroot + "/usr/share/syslinux/" + f):
                path = self._instroot + "/usr/share/syslinux/" + f
            if not os.path.isfile(path):
                raise CreatorError("syslinux not installed : "
                                   "%s not found" % path)

            shutil.copy(path, isodir + "/isolinux/")

    def __copy_syslinux_background(self, isodest):
#        background_path = self._instroot + \
#                          "/usr/lib/anaconda-runtime/syslinux-vesa-splash.jpg"

        background_path = "./redflag.jpg"

        if not os.path.exists(background_path):
            return False

        shutil.copyfile(background_path, isodest)

        return True

    def __copy_kernel_and_initramfs(self, isodir, version, index):
        bootdir = self._instroot + "/boot"

        shutil.copyfile(bootdir + "/vmlinuz-" + version,
                        isodir + "/isolinux/vmlinuz" + index)

        shutil.copyfile(bootdir + "/initrd-" + version + ".img",
                        isodir + "/isolinux/initrd" + index + ".img")

        is_xen = False
        if os.path.exists(bootdir + "/xen.gz-" + version[:-3]):
            shutil.copyfile(bootdir + "/xen.gz-" + version[:-3],
                            isodir + "/isolinux/xen" + index + ".gz")
            is_xen = True

        return is_xen

    def __is_default_kernel(self, kernel, kernels):
        if len(kernels) == 1:
            return True

        if kernel == self._default_kernel:
            return True

        if kernel.startswith("kernel-") and kernel[7:] == self._default_kernel:
            return True

        return False

    def __get_basic_syslinux_config(self, **args):
        return """
default %(menu)s
timeout %(timeout)d

%(background)s
menu title Welcome to %(name)s!
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color timeout_msg 0 #ffffffff #00000000
menu color timeout 0 #ffffffff #00000000
menu color cmdline 0 #ffffffff #00000000
menu hidden
menu hiddenrow 5
""" % args

    def __get_image_stanza(self, is_xen, **args):
        if not is_xen:
            template = """label %(short)s
  menu label %(long)s
  kernel vmlinuz%(index)s
  append initrd=initrd%(index)s.img root=CDLABEL=%(fslabel)s rootfstype=%(isofstype)s %(liveargs)s %(extra)s
"""
        else:
            template = """label %(short)s
  menu label %(long)s
  kernel mboot.c32
  append xen%(index)s.gz --- vmlinuz%(index)s root=CDLABEL=%(fslabel)s rootfstype=%(isofstype)s %(liveargs)s %(extra)s --- initrd%(index)s.img
"""
        return template % args

    def __get_image_stanzas(self, isodir):
        versions = []
        kernels = self._get_kernel_versions()
        for kernel in kernels:
            for version in kernels[kernel]:
                versions.append(version)

        kernel_options = self._get_kernel_options()

        checkisomd5 = self._has_checkisomd5()

        cfg = ""

        index = "0"
        for version in versions:
            is_xen = self.__copy_kernel_and_initramfs(isodir, version, index)

            default = self.__is_default_kernel(kernel, kernels)

            if default:
                long = "Boot"
            elif kernel.startswith("kernel-"):
                long = "Boot %s(%s)" % (self.name, kernel[7:])
            else:
                long = "Boot %s(%s)" % (self.name, kernel)

#            cfg += self.__get_image_stanza(is_xen,
#                                           fslabel = self.fslabel,
#                                           isofstype = "auto",
#                                           liveargs = kernel_options,
#                                           long = long,
#                                           short = "linux" + index,
#                                           extra = "",
#                                           index = index)

            cfg += self.__get_image_stanza(is_xen,
                                           fslabel = self.fslabel,
                                           isofstype = "auto",
                                           liveargs = kernel_options,
                                           long = "Redflag Inmini LiveCD Boot",
                                           short = "Redflag Inmini LiveCD Boot",
                                           extra = "live_locale=zh_CN.UTF-8",
                                           index = index)
            
            if default:
                cfg += "menu default\n"

            cfg += self.__get_image_stanza(is_xen,
                                           fslabel = self.fslabel,
                                           isofstype = "auto",
                                           liveargs = kernel_options,
                                           long = "Redflag Inmini LiveCD INSTALL",
                                           short = "INSTALL",
                                           extra = "live_locale=zh_CN.UTF-8 rfinstaller",
                                           index = index)

            cfg += self.__get_image_stanza(is_xen,
                                           fslabel = self.fslabel,
                                           isofstype = "auto",
                                           liveargs = kernel_options,
                                           long = "Safe Mode",
                                           short = "Safe Mode",
                                           extra = "live_locale=zh_CN.UTF-8 safemode acpi=off",
                                           index = index)

            if checkisomd5:
                cfg += self.__get_image_stanza(is_xen,
                                               fslabel = self.fslabel,
                                               isofstype = "auto",
                                               liveargs = kernel_options,
                                               long = "Verify and " + long,
                                               short = "check" + index,
                                               extra = "check",
                                               index = index)

            index = str(int(index) + 1)

        return cfg

    def __get_memtest_stanza(self, isodir):
        memtest = glob.glob(self._instroot + "/boot/memtest86*")
        if not memtest:
            return ""

        shutil.copyfile(memtest[0], isodir + "/isolinux/memtest")

        return """label memtest
  menu label Memory Test
  kernel memtest
"""

    def __get_local_stanza(self, isodir):
        return """label local
  menu label Boot from local drive
  localboot 0xffff
"""

    def _configure_syslinux_bootloader(self, isodir):
        """configure the boot loader"""
        makedirs(isodir + "/isolinux")

        menu = self.__find_syslinux_menu()

        self.__copy_syslinux_files(isodir, menu,
                                   self.__find_syslinux_mboot())

        background = ""
        if self.__copy_syslinux_background(isodir + "/isolinux/splash.jpg"):
            background = "menu background splash.jpg"

        cfg = self.__get_basic_syslinux_config(menu = menu,
                                               background = background,
                                               name = self.name,
                                               timeout = self._timeout * 10)

        cfg += self.__get_image_stanzas(isodir)
        cfg += self.__get_memtest_stanza(isodir)
        cfg += self.__get_local_stanza(isodir)
        cfg += self._get_isolinux_stanzas(isodir)

        cfgf = open(isodir + "/isolinux/isolinux.cfg", "w")
        cfgf.write(cfg)
        cfgf.close()

    def __copy_efi_files(self, isodir):
        if not os.path.exists(self._instroot + "/boot/efi/EFI/redhat/grub.efi"):
            return False
        shutil.copy(self._instroot + "/boot/efi/EFI/redhat/grub.efi",
                    isodir + "/EFI/boot/grub.efi")
        shutil.copy(self._instroot + "/boot/grub/splash.xpm.gz",
                    isodir + "/EFI/boot/splash.xpm.gz")

        return True

    def __get_basic_efi_config(self, **args):
        return """
default=0
splashimage=/EFI/boot/splash.xpm.gz
timeout %(timeout)d
hiddenmenu

""" %args

    def __get_efi_image_stanza(self, **args):
        return """title %(long)s
  kernel /EFI/boot/vmlinuz%(index)s root=CDLABEL=%(fslabel)s rootfstype=%(isofstype)s %(liveargs)s %(extra)s
  initrd /EFI/boot/initrd%(index)s.img
""" %args

    def __get_efi_image_stanzas(self, isodir, name):
        # FIXME: this only supports one kernel right now...

        kernel_options = self._get_kernel_options()
        checkisomd5 = self._has_checkisomd5()

        cfg = ""

        for index in range(0, 9):
            # we don't support xen kernels
            if os.path.exists("%s/EFI/boot/xen%d.gz" %(isodir, index)):
                continue
            cfg += self.__get_efi_image_stanza(fslabel = self.fslabel,
                                               isofstype = "auto",
                                               liveargs = kernel_options,
                                               long = name,
                                               extra = "", index = index)
            if checkisomd5:
                cfg += self.__get_efi_image_stanza(fslabel = self.fslabel,
                                                   isofstype = "auto",
                                                   liveargs = kernel_options,
                                                   long = "Verify and Boot " + name,
                                                   extra = "check",
                                                   index = index)
            break

        return cfg

    def _configure_efi_bootloader(self, isodir):
        """Set up the configuration for an EFI bootloader"""
        makedirs(isodir + "/EFI/boot")

        if not self.__copy_efi_files(isodir):
            shutil.rmtree(isodir + "/EFI")
            return

        for f in os.listdir(isodir + "/isolinux"):
            os.link("%s/isolinux/%s" %(isodir, f),
                    "%s/EFI/boot/%s" %(isodir, f))


        cfg = self.__get_basic_efi_config(name = self.name,
                                          timeout = self._timeout)
        cfg += self.__get_efi_image_stanzas(isodir, self.name)

        cfgf = open(isodir + "/EFI/boot/grub.conf", "w")
        cfgf.write(cfg)
        cfgf.close()

        # first gen mactel machines get the bootloader name wrong apparently
        if rpmUtils.arch.getBaseArch() == "i386":
            os.link(isodir + "/EFI/boot/grub.efi", isodir + "/EFI/boot/boot.efi")
            os.link(isodir + "/EFI/boot/grub.conf", isodir + "/EFI/boot/boot.conf")

        # for most things, we want them named boot$efiarch
        efiarch = {"i386": "ia32", "x86_64": "x64"}
        efiname = efiarch[rpmUtils.arch.getBaseArch()]
        os.rename(isodir + "/EFI/boot/grub.efi", isodir + "/EFI/boot/boot%s.efi" %(efiname,))
        os.link(isodir + "/EFI/boot/grub.conf", isodir + "/EFI/boot/boot%s.conf" %(efiname,))


    def _configure_bootloader(self, isodir):
        self._configure_syslinux_bootloader(isodir)
        self._configure_efi_bootloader(isodir)

class ppcLiveImageCreator(LiveImageCreatorBase):
    def _get_mkisofs_options(self, isodir):
        return [ "-hfs", "-nodesktop", "-part"
                 "-map", isodir + "/ppc/mapping",
                 "-hfs-bless", isodir + "/ppc/mac",
                 "-hfs-volid", self.fslabel ]

    def _get_required_packages(self):
        return ["yaboot"] + \
               LiveImageCreatorBase._get_required_packages(self)

    def _get_excluded_packages(self):
        # kind of hacky, but exclude memtest86+ on ppc so it can stay in cfg
        return ["memtest86+"] + \
               LiveImageCreatorBase._get_excluded_packages(self)

    def __copy_boot_file(self, destdir, file):
        for dir in ["/usr/share/ppc64-utils",
                    "/usr/lib/anaconda-runtime/boot"]:
            path = self._instroot + dir + "/" + file
            if not os.path.exists(path):
                continue
            
            makedirs(destdir)
            shutil.copy(path, destdir)
            return

        raise CreatorError("Unable to find boot file " + file)

    def __kernel_bits(self, kernel):
        testpath = (self._instroot + "/lib/modules/" +
                    kernel + "/kernel/arch/powerpc/platforms")

        if not os.path.exists(testpath):
            return { "32" : True, "64" : False }
        else:
            return { "32" : False, "64" : True }

    def __copy_kernel_and_initramfs(self, destdir, version):
        bootdir = self._instroot + "/boot"

        makedirs(destdir)

        shutil.copyfile(bootdir + "/vmlinuz-" + version,
                        destdir + "/vmlinuz")

        shutil.copyfile(bootdir + "/initrd-" + version + ".img",
                        destdir + "/initrd.img")

    def __get_basic_yaboot_config(self, **args):
        return """
init-message = "Welcome to %(name)s"
timeout=%(timeout)d
""" % args

    def __get_image_stanza(self, **args):
        return """

image=/ppc/ppc%(bit)s/vmlinuz
  label=%(short)s
  initrd=/ppc/ppc%(bit)s/initrd.img
  read-only
  append="root=CDLABEL=%(fslabel)s rootfstype=%(isofstype)s %(liveargs)s %(extra)s"
""" % args


    def __write_yaboot_config(isodir, bit):
        cfg = self.__get_basic_yaboot_config(name = self.name,
                                             timeout = self._timeout * 100)

        kernel_options = self._get_kernel_options()

        cfg += self.__get_image_stanza(fslabel = self.fslabel,
                                       isofstype = "auto",
                                       short = "linux",
                                       long = "Run from image",
                                       extra = "",
                                       bit = bit,
                                       liveargs = kernel_options)

        if self._has_checkisomd5():
            cfg += self.__get_image_stanza(fslabel = self.fslabel,
                                           isofstype = "auto",
                                           short = "check",
                                           long = "Verify and run from image",
                                           extra = "check",
                                           bit = bit,
                                           liveargs = kernel_options)

        f = open(isodir + "/ppc/ppc" + bit + "/yaboot.conf", "w")
        f.write(cfg)
        f.close()

    def __write_not_supported(isodir, bit):
        makedirs(isodir + "/ppc/ppc" + bit)

        message = "Sorry, this LiveCD does not support your hardware"

        f = open(isodir + "/ppc/ppc" + bit + "/yaboot.conf", "w")
        f.write('init-message = "' + message + '"')
        f.close()


    def __write_dualbits_yaboot_config(isodir, **args):
        cfg = """
init-message = "\nWelcome to %(name)s!\nUse 'linux32' for 32-bit kernel.\n\n"
timeout=%(timeout)d
default=linux

image=/ppc/ppc64/vmlinuz
	label=linux64
	alias=linux
	initrd=/ppc/ppc64/initrd.img
	read-only

image=/ppc/ppc32/vmlinuz
	label=linux32
	initrd=/ppc/ppc32/initrd.img
	read-only
""" % args

        f = open(isodir + "/etc/yaboot.conf", "w")
        f.write(cfg)
        f.close()

    def _configure_bootloader(self, isodir):
        """configure the boot loader"""
        havekernel = { 32: False, 64: False }

        self.__copy_boot_file("mapping", isodir + "/ppc")
        self.__copy_boot_file("bootinfo.txt", isodir + "/ppc")
        self.__copy_boot_file("ofboot.b", isodir + "/ppc/mac")

        shutil.copyfile(self._instroot + "/usr/lib/yaboot/yaboot",
                        isodir + "/ppc/mac/yaboot")

        makedirs(isodir + "/ppc/chrp")
        shutil.copyfile(self._instroot + "/usr/lib/yaboot/yaboot",
                        isodir + "/ppc/chrp/yaboot")

        subprocess.call(["/usr/sbin/addnote", isodir + "/ppc/chrp/yaboot"])

        #
        # FIXME: ppc should support multiple kernels too...
        #
        kernel = self._get_kernel_versions().values()[0][0]

        kernel_bits = self.__kernel_bits(kernel)

        for (bit, present) in kernel_bits.items():
            if not present:
                self.__write_not_supported(isodir, bit)
                continue

            self.__copy_kernel_and_initramfs(isodir + "/ppc/ppc" + bit, kernel)
            self.__write_yaboot_config(isodir, bit)

        makedirs(isodir + "/etc")
        if kernel_bits["32"] and not kernel_bits["64"]:
            shutil.copyfile(isodir + "/ppc/ppc32/yaboot.conf",
                            isodir + "/etc/yaboot.conf")
        elif kernel_bits["64"] and not kernel_bits["32"]:
            shutil.copyfile(isodir + "/ppc/ppc64/yaboot.conf",
                            isodir + "/etc/yaboot.conf")
        else:
            self.__write_dualbits_yaboot_config(isodir,
                                                name = self.name,
                                                timeout = self._timeout * 100)

        #
        # FIXME: build 'netboot' images with kernel+initrd, like mk-images.ppc
        #

class ppc64LiveImageCreator(ppcLiveImageCreator):
    def _get_excluded_packages(self):
        # FIXME:
        #   while kernel.ppc and kernel.ppc64 co-exist,
        #   we can't have both
        return ["kernel.ppc"] + \
               ppcLiveImageCreator._get_excluded_packages(self)

arch = rpmUtils.arch.getBaseArch()
if arch in ("i386", "x86_64"):
    LiveImageCreator = x86LiveImageCreator
elif arch in ("ppc",):
    LiveImageCreator = ppcLiveImageCreator
elif arch in ("ppc64",):
    LiveImageCreator = ppc64LiveImageCreator
else:
    raise CreatorError("Architecture not supported!")
