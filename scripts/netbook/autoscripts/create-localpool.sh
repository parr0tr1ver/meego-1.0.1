#!/bin/bash

WORKDIR=`dirname $0`
cd $WORKDIR
WORKDIR=`pwd`

PRODUCT_NAME="RedFlag"
#PRODUCT_VERSION="6.2"
#CODE_NAME="KunlunJade"
#REVISION="Newest"
CVS_SERVER="172.16.82.254"
export CVSROOT=:pserver:cvs@${CVS_SERVER}:2401/project/CVS
#LOCALPOOL=$1
#REVISION=$2
#DISCTYPE=${3:-DVD}

while getopts j:V:t:r:d:h opt
do
	case $opt in
	  j|V)
		_project_name=$OPTARG
		;;
	  r)
		_revision=$OPTARG
		;;
	  t)
		_disctype=$OPTARG
		;;
	  d)
		LOCALPOOL=$OPTARG
		;;
	esac
done

PROJECT_NAME=${_project_name:-KunlunJade}
REVISION=${_revision:-Newest}
DISCTYPE=${_disctype:-DVD}

case $PROJECT_NAME in
  KunlunJade|Kunlunjade|kunlunjade|DT60SP2|dt62|DT62)
	PRODUCT_VERSION="6.2"
	CODE_NAME="KunlunJade"
	;;
  Sylph|sylph|DT60SP1|DT60|dt60)
	PRODUCT_VERSION="6.0"
	CODE_NAME="Sylph"
	;;
  *)
	echo "Project $PROJECT_NAME can NOT support yet."
	exit 1
	;;
esac
	
case $DISCTYPE in
  sys|Sys|syscd|SysCD)
	DISCTYPE=SysCD
	;;
  tool|Tool|toolcd|ToolCD)
	DISCTYPE=ToolCD
	;;
  dvd|full|DVD|Full)
	DISCTYPE=DVD
	;;
esac

SNAPSHOTFILE="${PRODUCT_NAME}-Desktop-${PRODUCT_VERSION}-${DISCTYPE}.list"
POOL="/project/$CODE_NAME/pool/"

echo $PROJECT_NAME
echo $REVISION
echo $DISCTYPE
echo "press any key to continue"
read a

get_filelist() {
if [ -z $LOCALPOOL ]; then
	echo "Usage: $0 -j Project_Name -d LocalPoolDir -r [Revision]"
	return 1
fi

mkdir -p $LOCALPOOL
pushd $LOCALPOOL
rm -rf iso_filelist/
#mkdir -p iso_filelist
if [ "$REVISION" = "" ]; then
	mk_rpmlist -j $CODE_NAME || return 1
	#cvs co iso_filelist/$SNAPSHOTFILE || return 1
else
	mk_rpmlist -j $CODE_NAME -r $REVISION || return 1
#	cvs co -r $REVISION iso_filelist/$SNAPSHOTFILE || return 1
fi
mv -v mk_rpmlist.tmp/ iso_filelist
popd
#echo "Press any key to continue"
#read a
}

copy_pkg() {
rm -rf $LOCALPOOL/RPMS $LOCALPOOL/SRPMS
mkdir -p $LOCALPOOL/RPMS
mkdir -p $LOCALPOOL/SRPMS
filelist=`cat $LOCALPOOL/iso_filelist/${SNAPSHOTFILE}|grep -v TRANS.TBL|grep -v tgz$|sed -e "s/[[:space:]]*//g"|sed -e "s/#.*//g"|xargs`
for loop in $filelist;
do
	echo $loop
	cp $POOL/RPMS/$loop $LOCALPOOL/RPMS || return 1
done
[ -f $WORKDIR/dev-*rpm ] && cp $WORKDIR/dev-*rpm $LOCALPOOL/RPMS || return 1
}

# Main Function
get_filelist $REVISION || exit 1
copy_pkg || exit 1
echo "Done."
exit 0
