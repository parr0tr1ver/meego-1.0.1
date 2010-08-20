#!/bin/sh 

set -x

# project code name XiZhi/王羲之
build_log=build_XiZhi

function usage() 
{
	echo Usage: $0 SRPM-directory
	exit 1
}

function signal_handler()
{
	echo 'catch signal, exiting'
	exit 2
}

trap signal_handler SIGQUIT SIGINT

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
		echo "building $srpm " >> $build_log.$build_time

		rpmbuild --target i586 --clean --rebuild $srpm >> $build_log.$build_time 2>&1 
		if [ $? -eq 0 ]; then
			mv $srpm $result_dir
			echo "build $srpm successfully!" >> $build_log.$build_time
		else
			echo "build $srpm failed! :(" >> $build_log.$build_time
		fi

		echo '--------------------------------------------------------' >> $build_log.$build_time
		echo >> $build_log.$build_time

	done

	popd
done
