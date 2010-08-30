#!/bin/bash 
name=`whoami`
if [ "$name" != "root" ] ;then
echo "Lack of competence,can't install,please change to root user"
exit
fi
dev_boot=`mount |grep "on /boot" `
devname_rot=`mount |grep "on / type" |cut -f 1 -d " "`

echo "please input the  path of ".iso" file,for example(/mnt/sda2) :"
read path_iso
test -d ${path_iso}
isofile=$?
if [ "0" != "$isofile"  ];then 
		name_iso=`basename ${path_iso}`
		dir_name=`dirname ${path_iso}`
		dir_name=`readlink -f ${dir_name}`
	else	
		dir_name=${path_iso}
		dir_name=`readlink -f ${path_iso}`
		iso=`ls ${dir_name}|grep "\.iso" `
		until [ -n "$iso" ]
		do
			echo "there is not have iso file in this directory,please input again: "
			read path_iso
			dir_name=${path_iso}
			dir_name=`readlink -f ${path_iso}`
			iso=`ls ${dir_name}|grep "\.iso" `
		done
		echo "these are all iso file,in this directory : "
		ls ${dir_name}|grep  "\.iso" > /tmp/path_iso.c
		cat -n /tmp/path_iso.c

		echo "please choose the number that you want to install:"
		read  num
		name_iso=`cat -n /tmp/path_iso.c|sed -n "/^\ *$num\\t/p"|cut -f 2 `
		rm -f /tmp/path_iso.c
fi
name_iso_dir="`ls ${dir_name}|grep -x ${name_iso}`"
name_cdrom=`ls /tmp/ |grep -x cdrom`
if [  -n  "${name_iso_dir}" ] ;then

	if [ "${name_cdrom}" = "cdrom" ] ;then
		if [  "0" = "$isofile" ];then

				mount -o loop  ${path_iso}/${name_iso}  /tmp/cdrom
		  	else
				mount -o loop  ${path_iso}  /tmp/cdrom
		fi
		else
			mkdir /tmp/cdrom
			if [ "0" = "$isofile" ];then
				mount -o loop  ${path_iso}/${name_iso}  /tmp/cdrom
				else
				mount -o loop  ${path_iso}  /tmp/cdrom
			fi
       	fi	
	vmlinuz=`ls /tmp/cdrom/isolinux/vmlinuz0`
	if [ -z "$vmlinuz" ];then
			umount /tmp/cdrom
			echo " Eerror,the iso file is not true"
			exit
		else
			cp /tmp/cdrom/isolinux/vmlinuz0 /boot/
			cp /tmp/cdrom/isolinux/initrd4disk.img /boot/
			umount /tmp/cdrom
       	fi

	if [ "${dir_name}" = "/" ] ;then
			isodev_dir=${dir_name}
			dirne="${devname_rot}"

		else
			i=2
			dir=`echo "${dir_name}"|cut -f $i -d/`
			until [ -z "$dir" ]
			do
			let i++
			dir=`echo "${dir_name}"|cut -f $i -d/`
			done
			let i--
			num=$i
			m_point=`mount|cut -f3 -d " "|grep -x "${dir_name}"`
			until [ -n "${m_point}" -o $i -eq 2 ]
			do
			let i--
			dir_m=`echo ${dir_name}|cut -f1-$i -d/`
			m_point=`mount|cut -f3 -d " "|grep -x "${dir_m}"`
			done
			if [ -z "${m_point}" ];then
				dirne=`mount|grep "on / type"|cut -f1 -d " "`
				isodev_dir=${dir_name}
				else
				dirne=`mount|grep "${m_point} "|cut -f1 -d " "`
				let i++
			        if [ "${m_point}" = "${dir_name}" ];then
					isodev_dir=/
					else
				        isodev_dir=/"`echo ${dir_name}|cut -f$i-$num -d/`"
				fi
			fi
		fi	
# I want to know the mbr in the first sector of my disk 
# will load which grub.conf and the corresponding stage2.

DIR="/tmp/mbr-experiments"
DISK="`echo $dirne|cut -c 1-8`"
RESULT=""

mkdir -p $DIR

pushd $DIR > /dev/null 2>&1

dd if=$DISK of=mbr bs=512 count=1 > /dev/null 2>&1

ABSOLUTE_ADDRESS_HEX_0X44=` hexdump mbr -s 0x44 -n 1 -e '"%02x"' `
ABSOLUTE_ADDRESS_HEX_0X45=` hexdump mbr -s 0x45 -n 1 -e '"%02x"' `
ABSOLUTE_ADDRESS_HEX_0X46=` hexdump mbr -s 0x46 -n 1 -e '"%02x"' `
ABSOLUTE_ADDRESS_HEX_0X47=` hexdump mbr -s 0x47 -n 1 -e '"%02x"' `

# this indicate how to find stage2
#   [7C44] --> Note: A very important location for anyone using GRUB!
#              This (4-byte) Quad-Word contains the location of GRUB's
#              stage2 file in sectors! You will always see the bytes
#              01 00 00 00 in this location whenever GRUB has been
#              installed in the first track (Sectors 1 ff.) of an HDD;
#              immediately following the GRUB MBR in Absolute Sector 0.
#     Example:
#              DF 0A 93 01 (1930ADFh) [ "stage2 Sector" -> 26,413,791 ]
#             [So, for this GRUB install, its stage2 file is located at
#              Absolute Sector 26413791. This value will of course vary
#              depending upon the physical location of the stage2 file!]

STAGE2_HEX_ADDRESS="$ABSOLUTE_ADDRESS_HEX_0X47$ABSOLUTE_ADDRESS_HEX_0X46$ABSOLUTE_ADDRESS_HEX_0X45$ABSOLUTE_ADDRESS_HEX_0X44"

# stage2 first sector
STAGE2_DEC_ADDRESS=$(( 0x$STAGE2_HEX_ADDRESS ))

#echo $STAGE2_DEC_ADDRESS

if [ $STAGE2_DEC_ADDRESS -eq 1 ] ; then
    dd if=$DISK of=stage1_5 bs=512 count=2 skip=1 > /dev/null 2>&1
    
    RESULT_HEX=` hexdump stage1_5 -s 0x219 -n 1 -e '"%02x"' `
    RESULT=$(( 0x$RESULT_HEX + 1 ))

else
    # use fdisk to decide which partition include the stage2 sectors,
    # any better method?
    DISK_PARTITIONS="disk_partions"
    fdisk -l -u | sed '1,/.*Device Boot.*/d' | sed '/.*Ext*/d' | sed 's/\*/ /' > $DISK_PARTITIONS
    LINE=`cat $DISK_PARTITIONS | wc -l`

    for i in `seq $LINE`
    do
	TMP_RESULT=$(cat $DISK_PARTITIONS | awk "NR==$i {print \$1}")
	TMP_START=$(cat $DISK_PARTITIONS | awk "NR==$i {print \$2}")
	TMP_END=$(cat $DISK_PARTITIONS | awk "NR==$i {print \$3}")
	if [ $STAGE2_DEC_ADDRESS -gt $TMP_START ] && [ $STAGE2_DEC_ADDRESS -lt $TMP_END ]
	then
	    RESULT=`echo $TMP_RESULT | sed 's/^[^0-9]*//'`
	    break
	fi
    done

fi

popd > /dev/null 2>&1

#echo $RESULT
disk=$DISK$RESULT
rm -fr $DIR
sector_boot="`mount|grep $disk`"
	if [ -z "${sector_boot}" ] ;then
		mount $disk /media
	        mount_point="/media"	
		sector_bot="`ls /media|grep -x "boot" `" 
		if [ -n "${sector_bot}" ];then
			file_grub=`ls /media/boot/grub/grub.conf`
			dir_grub="/media/boot/grub/grub.conf"
			else
			file_grub=`ls /media/grub/grub.conf`
			dir_grub="/media/grub/grub.conf"
		fi
		if [ -z "${file_grub}" ];then
			umount /media
			echo "Error,not have grub.conf file"
			exit
		fi
		else
		point=`mount|grep $disk|cut -f3 -d " "|sed -n '1p'`
		mount_point="$point"
		sector_bot=`ls $point|grep -x "boot"`
		if [ -n "${sector_bot}" ];then

			file_grub=`ls $point/boot/grub/grub.conf`
			dir_grub="$point/boot/grub/grub.conf"
			else
			file_grub=`ls $point/grub/grub.conf`
			dir_grub="$point/grub/grub.conf"
		fi
		
		if [ -z "${file_grub}" ];then
			echo "Error,not have grub.conf file"
			exit
		fi
	fi
#end mbr	
	ch=`echo $dirne|cut -c 6`
	if [ "$ch" = "h" ];then
		dirne=`echo $dirne|tr "hd" "sd"`
	fi

	if [ -z "$dev_boot" ] ;then

		num2_r=`mount |grep "on / type" |cut -f 1 -d " " |cut -c 10 `
		num1_r=`mount |grep "on / type" |cut -f 1 -d " " |cut -c 9 `
		if [  -z "$num2_r" ] ;then
			num=` expr ${num1_r} - 1 `
			else

			num=${num1_r}${num2_r}
			num=` expr ${num} - 1 `
		fi
		devnum=`mount |grep "on / type" |cut -f 1 -d " " |cut -c 8 `
		devnum=$(($((`echo $devnum | hexdump -n1 -e '"%d"'`))-$((`echo a | hexdump -n1 -e '"%d"'`))))

		else 
		num2_b=`mount |grep "on /boot" |cut -f 1 -d " " |cut -c 10 `
		num1_b=`mount |grep "on /boot" |cut -f 1 -d " " |cut -c 9 `
		if [  -z "$num2_b" ] ;then
			num=` expr ${num1_b} - 1 `
			else

			num=${num1_b}${num2_b}
			num=` expr ${num} - 1 `
		fi
		devnum=`mount |grep "on /boot" |cut -f 1 -d " " |cut -c 8 `
		devnum=$(($((`echo $devnum | hexdump -n1 -e '"%d"'`))-$((`echo a | hexdump -n1 -e '"%d"'`))))

        fi
	title="title Redflag-Inmini-livecd Linux Desktop"
        titl="`echo ${title}|sed 's/\s//g'`"
	rot="root (hd$devnum,$num)"  
	if [ -z "$dev_boot" ] ;then

		kernel="kernel /boot/vmlinuz0 root=CDLABEL=redflag-inmini-livecd isodev=${dirne} isodev_dir=${isodev_dir} rootfstype=iso9660 ro liveimg quiet rhgb live_locale=zh_CN.UTF-8 "  
		initrd="initrd /boot/initrd4disk.img" 
		else
		kernel="kernel /vmlinuz0 root=CDLABEL=redflag-inmini-livecd isodev=${dirne} isodev_dir=${isodev_dir} rootfstype=iso9660 ro liveimg quiet rhgb live_locale=zh_CN.UTF-8"  
		initrd="initrd /initrd4disk.img" 
	fi
	_title="`grep "title" ${dir_grub}|sed 's/\s//g'|head -n 1|grep -x  "${titl}"`"
	if [ -n "${_title}" ];then
	                n1=`grep -n title ${dir_grub}|head -n 1|cut -f 1 -d:` 
			n2=`expr $n1 + 3 `
			sed "$n1, $n2  d"  ${dir_grub} > /tmp/redflag.c
			cat /tmp/redflag.c  > ${dir_grub}
			rm -f /tmp/redflag.c		
	fi		 
	sed -i "`grep -n title  ${dir_grub}|head -n 1|cut -f1 -d:` i\\`echo $title`" ${dir_grub}  
	sed -i "`grep -n title  ${dir_grub}|head -n 1|cut -f1 -d:` a\ " ${dir_grub}  
	sed -i "`grep -n title 	${dir_grub}|head -n 1|cut -f1 -d:` a\\`echo $initrd`" ${dir_grub} 
	sed -i "`grep -n title 	${dir_grub}|head -n 1|cut -f1 -d:` a\\`echo $kernel`" ${dir_grub} 
	sed -i "`grep -n title 	${dir_grub}|head -n 1|cut -f1 -d:` a\\`echo $rot`" ${dir_grub} 
        if [ -z "${sector_boot}" ];then
		umount /media 
        fi
	echo "Successful!!!,you need reboot computer ,install"
		else
			echo "Error:the iso name is error,don't have this iso file "

fi

#end













 




