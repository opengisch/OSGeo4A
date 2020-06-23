#!/bin/bash

# version of your package
VERSION_libpng=1.6.37

# dependencies of this recipe
DEPS_libpng=(zlib)

# url of the package
URL_libpng=ftp://ftp.simplesystems.org/pub/png/src/libpng16/libpng-${VERSION_libpng}.tar.gz

# md5 of the package
MD5_libpng=6c7519f6c75939efa0ed3053197abd54

# default build path
BUILD_libpng=$BUILD_PATH/libpng/$(get_directory $URL_libpng)

# default recipe path
RECIPE_libpng=$RECIPES_PATH/libpng

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libpng() {
  cd $BUILD_libpng

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try patch -p1 < $RECIPE_libpng/patches/android_vers.patch
}

function shouldbuild_libpng() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libpng/build-$ARCH/lib/libpng.so -nt $BUILD_libpng/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libpng() {
  try mkdir -p $BUILD_PATH/libpng/build-$ARCH
  try cd $BUILD_PATH/libpng/build-$ARCH
  push_arm

  # configure
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DHAVE_LD_VERSION_SCRIPT=OFF \
    $BUILD_libpng

  # try $MAKESMP
  try make genfiles
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_libpng() {
	true
}
