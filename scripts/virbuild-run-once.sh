#!/bin/sh
# run this script once for some settings for virbuild

# should bind /dev outside the virbuild
# mount -v --bind /dev $virbuild/dev

# some rpm configs
# do NOT build debug info packages
cat > $HOME/.rpmmacros << EOF
%debug_package %{nil}
%_unpackaged_files_terminate_build    0
EOF


