#!/bin/sh 

set -x

function usage() 
{
	echo Usage: $0 SRPM-directory
	exit 1
}

if [ $# -lt 1 ]; then 
	usage
fi

for para in "$*"; do
	echo $para
	pushd $para

	build_time=`date +%s`
	result_dir=finished.$build_time
	mkdir $result_dir

	for srpm in `ls *.src.rpm`; do
		rpmbuild --target i586 --clean --rebuild $srpm &> build_log.$build_time
		if [ $? -eq 0 ]; then
			mv $srpm $result_dir
		fi
	done

	popd
done
