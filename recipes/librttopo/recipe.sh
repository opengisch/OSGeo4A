#!/bin/bash

# version of your package
VERSION_librttopo=1.1.0

# dependencies of this recipe
DEPS_librttopo=(geos)

# url of the package
URL_librttopo=https://git.osgeo.org/gitea/rttopo/librttopo/archive/librttopo-${VERSION_librttopo}.tar.gz

# md5 of the package
MD5_librttopo=0952b78943047ca69a9e6cbef6146869

# default build path
BUILD_librttopo=$BUILD_PATH/librttopo/$(get_directory $URL_librttopo)

# default recipe path
RECIPE_librttopo=$RECIPES_PATH/librttopo

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_librttopo() {
  cd $BUILD_librttopo

  # check marker
  if [ -f .patched ]; then
    return
  fi

  ./autogen.sh

  touch .patched
}

function shouldbuild_librttopo() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/librttopo/build-$ARCH/lib/librttopo.so -nt $BUILD_librttopo/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_librttopo() {
  try mkdir -p $BUILD_PATH/librttopo/build-$ARCH
  try cd $BUILD_PATH/librttopo/build-$ARCH

  push_arm
  
  #try $BUILD_librttopo/autogen.sh
  try $BUILD_librttopo/configure \
    --host=$TOOLCHAIN_PREFIX \
    --build=x86_64 \
    --prefix=$STAGE_PATH \
    --with-geosconfig=$STAGE_PATH/bin/geos-config
  try $MAKESMP
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_librttopo() {
	true
}
