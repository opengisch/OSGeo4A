#!/bin/bash

# version of your package
VERSION_geos=3.7.1

# dependencies of this recipe
DEPS_geos=()

# url of the package
URL_geos=http://download.osgeo.org/geos/geos-${VERSION_geos}.tar.bz2

# md5 of the package
MD5_geos=62149456d21dabee44999f644c986ab0

# default build path
BUILD_geos=$BUILD_PATH/geos/$(get_directory $URL_geos)

# default recipe path
RECIPE_geos=$RECIPES_PATH/geos

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_geos() {
  cd $BUILD_geos

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_OUT_PATH/.packages/config.sub $BUILD_geos
  try cp $ROOT_OUT_PATH/.packages/config.guess $BUILD_geos
  try patch -p1 < $RECIPE_geos/patches/geos.patch

  touch .patched
}

function shouldbuild_geos() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/geos/build-$ARCH/lib/libgeos.so -nt $BUILD_geos/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_geos() {
  try mkdir -p $BUILD_PATH/geos/build-$ARCH
  try cd $BUILD_PATH/geos/build-$ARCH
  push_arm
#    -DANDROID_STL=gnustl_shared \
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    $BUILD_geos
  echo '#define GEOS_SVN_REVISION 0' > $BUILD_PATH/geos/build-$ARCH/geos_svn_revision.h
  try $MAKESMP
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_geos() {
	true
}
