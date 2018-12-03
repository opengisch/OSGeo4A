#!/bin/bash

# version of your package
VERSION_exiv2=0.26

# dependencies of this recipe
DEPS_exiv2=(expat iconv)

# url of the package
#URL_exiv2=http://www.exiv2.org/builds/exiv2-0.26-trunk.tar.gz
URL_exiv2=https://github.com/Exiv2/exiv2/archive/d8a15e1d132e260dd333ebc5af1e6929257a6d0f.zip

# md5 of the package
MD5_exiv2=7a423fabb9bfbdaecbcaa24db1c5abd3

# default build path
BUILD_exiv2=$BUILD_PATH/exiv2/$(get_directory $URL_exiv2)

# default recipe path
RECIPE_exiv2=$RECIPES_PATH/exiv2

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_exiv2() {
  cd $BUILD_exiv2

  # check marker
  if [ -f .patched ]; then
    return
  fi
}

function shouldbuild_exiv2() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/exiv2/build-$ARCH/exiv2/exiv2.so -nt $BUILD_exiv2/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_exiv2() {
  try mkdir -p $BUILD_PATH/exiv2/build-$ARCH
  try cd $BUILD_PATH/exiv2/build-$ARCH
  push_arm
  try cmake \
      -DEXIV2_ENABLE_NLS=OFF \
      -DICONV_INCLUDE_DIR=$STAGE_PATH/include \
      -DICONV_LIBRARY=$STAGE_PATH/lib/libiconv.so \
      -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
      -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
      -DANDROID=ON \
      -DANDROID_ABI=$ARCH \
      -DANDROID_NDK=$ANDROID_NDK \
      -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
      -DANDROID_TOOLCHAIN_VERSION=gcc-4.9 \
      $BUILD_exiv2
  try $MAKESMP
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_exiv2() {
	true
}
