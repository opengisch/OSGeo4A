#!/bin/bash

# version of your package
VERSION_hostsip=4.16.4

# dependencies of this recipe
DEPS_hostsip=()

# url of the package
URL_hostsip=http://downloads.sourceforge.net/project/pyqt/sip/sip-${VERSION_hostsip}/sip-${VERSION_hostsip}.tar.gz

# md5 of the package
MD5_hostsip=a9840670a064dbf8f63a8f653776fec9

# default build path
BUILD_hostsip=$BUILD_PATH/hostsip/$(get_directory $URL_hostsip)

# default recipe path
RECIPE_hostsip=$RECIPES_PATH/hostsip

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_hostsip() {
	true
}

# function called to build the source code
function build_hostsip() {
  cd $BUILD_hostsip
  $HOSTPYTHON configure.py
  make -j$CORES
}

# function called after all the compile have been done
function postbuild_hostsip() {
	true
}
