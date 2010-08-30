#!/bin/bash

# this script should be run at 82.254, check dt7 yum/source and synchron
# mount -t nfs 172.16.82.249:/mnt/build/dtsvn/autoscripts/packager/yum/sources /home/packager/dt7_SRPMS/ 

dt7_SRPMS=/home/packager/dt7_SRPMS/
pkgs_list_file=`dirname $0`/packages_from_dt7.list

for file in `cat $pkgs_list_file`; do
        pkg_name=$(echo $file | awk -F'-' '{print  $1}')
        echo $pkg_name

        has_newer=false
        for dt7_pkg in `find  $dt7_SRPMS -name $pkg_name-*.src.rpm`; do
                rpmdev-vercmp ${dt7_pkg##*/} $file
                if [ $? -eq 11 ]; then
                        has_newer=true
                        file=$dt7_pkg
                fi
	done
	
	echo $has_newer
	
	# if has newer packages, update it
	if $has_newer ; then 
		rpm -ivh $dt7_SRPMS/$file
		if [ $(rpm -qpl $dt7_SRPMS/$file | grep '\.spec$' ) -gt 1 ]; then
			if [ $(rpm -qpl $dt7_SRPMS/$file | grep '^$pkg_name\.spec$' ) -eq 0 ]; then
				echo "Please make sure the spec file for $dt7_SRPMS/$file"
				echo "And rebuild it manully later."
				exit 1
			fi
		fi

		rpmbuild --clean --target i586 -ba $HOME/rpmbuild/SPECS/$pkg_name.spec
		if [ $? -ne 0 ] ; then
			echo "Rebuild $HOME/rpmbuild/SPECS/$pkg_name.spec failed"
			exit 2
		fi
	fi
done
