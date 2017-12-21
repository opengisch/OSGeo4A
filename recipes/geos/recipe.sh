#!/bin/bash

# version of your package
VERSION_geos=3.6.2

# dependencies of this recipe
DEPS_geos=()

# url of the package
URL_geos=http://download.osgeo.org/geos/geos-${VERSION_geos}.tar.bz2

# md5 of the package
MD5_geos=a32142343c93d3bf151f73db3baa651f

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

  try cp $ROOT_PATH/.packages/config.sub $BUILD_geos
  try cp $ROOT_PATH/.packages/config.guess $BUILD_geos
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
  try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DANDROID=ON \
    -DANDROID_ABI=$ARCH \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
    -DANDROID_TOOLCHAIN_VERSION=gcc-4.9 \
    $BUILD_geos
  echo '#define GEOS_SVN_REVISION 0' > $BUILD_PATH/geos/build-$ARCH/geos_svn_revision.h
  try make
  try make install
  pop_arm
}

# function called after all the compile have been done
function postbuild_geos() {
	true
}
