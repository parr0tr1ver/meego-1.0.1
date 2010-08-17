#!/bin/sh

function usage() 
{
	echo Usage: $0 SRPM-directory
	exit 1
}

pushd $1
#if [ ! -e '
