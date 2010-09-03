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

	build_time=`date +%Y%m%d%H%M`
	result_dir=finished.$build_time
	mkdir $result_dir

	tdir=$(basename `pwd`)
	log_file=$tdir\_$build_log.$build_time
	echo log file is $log_file
	#read


	sum=`ls *.src.rpm | wc -l`
	count=1
	failed=0
	for srpm in `ls *.src.rpm`; do
		echo "building $srpm $count/$sum" >> $log_file

		rpmbuild --target i586 --clean --rebuild $srpm >> $log_file 2>&1 
		if [ $? -eq 0 ]; then
			mv $srpm $result_dir/
			echo "build $srpm successfully!" >> $log_file
		else
			echo "build $srpm failed! :(" >> $log_file
			let failed=failed+1
		fi

		echo '--------------------------------------------------------' >> $log_file
		echo >> $log_file

		let count=count+1
	done

	echo "Build finished! Left $failed/$sum rpm failed!" >> $log_file

	popd
done
