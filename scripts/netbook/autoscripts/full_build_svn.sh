#!/bin/bash

export LANG=C

if [ $# -lt 1 -o $# -gt 2 ]; then
        echo "Usage: $0 svn_directory [package] "
        exit 1
fi

echo $1
pushd $1

if [ $? -ne 0 ]; then
	echo "please input a valid path"
	exit 6
fi

KSVN_DIR=`pwd`

#echo $KSVN_DIR
popd

source_dir=$HOME/rpmbuild/SOURCES
svn_log=/tmp/fullbuild_svnlog

pushd $KSVN_DIR

pkg_list="kdelibs kdebase kdebase-runtime  kdebase-workspace  kde-settings plasma-applet-minitasks kickoff rfthememanager"

if [ $# -eq 2 ]; then
	pkg_list=${2%%/}
fi


svn up $pkg_list
if [ $? != 0 ]; then
	echo "svn up $pkg_list failed"
	exit 7
fi

for pkg in $pkg_list
do
        if [ $# -eq 2 ]; then
                if [ ! -d $KSVN_DIR/$2 ]; then
                        echo "$2 does NOT exist. Please check..."
                        exit 5
                fi

                if [ ${2%%/} != "$pkg" ]; then
                        continue;
                fi
        fi

        if [ ! -d $KSVN_DIR/$pkg ]; then
                echo "$pkg does NOT exist!"
                exit 2
        fi

	if [ -f $pkg/$pkg.spec ]; then
		spec=$pkg.spec
	elif [ `ls $pkg/*.spec | wc -l ` -eq 1 ]; then
		ab_spec=$pkg/*.spec
		spec=${ab_spec##*/}
	else
		echo "Please clean your spec files under $pkg"
		exit 4
	fi

        version=`sed -n '/Version:/p' $pkg/$spec  | awk -F: '{print $2}' | tr -d " \t"`

	# increase the release No.
	release=`sed -n '/Release:/p' $pkg/$spec  | awk -F: '{print $2}' | tr -d " \t"`
	rel_suf1='%{?dist}'
	rel_suf2='.redflag'
	
	if [ "${release%$rel_suf1}" != "$release" ]; then
		release_no=${release%$rel_suf1}
		suffix=$rel_suf1
	elif [ "${release%$rel_suf2}" != "$release" ]; then
		release_no=${release%$rel_suf2}
		suffix=$rel_suf2
	fi
	echo "src release is $release"
	release_no=$(( $release_no + 1 ))
	release=$release_no$suffix
	echo "release is $release"
	echo "suffix is $suffix"

	svn_old_release=0
	tmp_rel=$(sed -n '/%changelog/{n;p}' $pkg/$spec | grep -E '\-r[[:digit:]]+$' | awk ' { print $NF; }')
	echo "tmp_rel is $tmp_rel"
	if [ "$tmp_rel" != "" ]; then
		svn_old_release=${tmp_rel#-r}
		echo "svn_old_release is $svn_old_release"
	fi
	echo "svn_old_release is $svn_old_release"
	
	# has update?
	updated=true
	if [ `svn log -r HEAD:$(( $svn_old_release + 1 )) | wc -l` -lt 6 ]; then
		if [ `svn log -r HEAD:$(( $svn_old_release + 1 )) | grep -c "update $spec for build"` -eq 1 ]; then 
			updated=false
		fi
	fi

	# changelog; if has update, modify the spec
	if [ $updated ]; then
		changelog_date=`date +"%a %b %d %Y"`
		svn_release=$(svn info $pkg | sed -n '/Revision/p' | awk -F: ' { print $2; }' | tr -d " \t")

		rm -f $svn_log
		echo "* $changelog_date packager <bugzilla@redflag-linux.com> - $version-$release_no -r$svn_release" > $svn_log

		# ok, got the update log
		svn log -r HEAD:$(( $svn_old_release + 1 )) $pkg >> $svn_log
		sed -i '2,$s/^/- /' $svn_log

		# modify the spec
		sed -i "s/Release:.*$/Release:\t$release/" $pkg/$spec

		if grep '%changelog' $pkg/$spec; then
			sed -i "/%changelog/r $svn_log" $pkg/$spec
		else
			sed -i -e '$a\%changelog' $pkg/$spec
			cat $svn_log >> $pkg/$spec
		fi

		# commit the spec file
		svn ci $pkg/$spec -m "update $spec for build"
	fi

	rm -rf $pkg-$version
	cp -rf $pkg $pkg-$version
	rm -rf `find $pkg-$version -name .svn`
        tar cjf $pkg-$version.tar.bz2 $pkg-$version 
        if [ $? -ne 0 ]; then
                echo "Error: packaging failed."
                exit 3
        fi
	
	mv $pkg-$version.tar.bz2 $source_dir
	rm -rf $pkg-$version

	rpmbuild --target i586 --clean -ba $pkg/$spec

	if [ $? -ne 0 ]; then
		echo "Error: build package $pkg failed"
		exit 4
	fi

	if [ $pkg == "kdelibs" ]; then
		sudo rpm -Uvh $HOME/rpmbuild/RPMS/*/$pkg-*$version*.rpm
	fi
done

echo "Build package $pkg_list  under $KSVN_DIR succeed."

