#!/bin/bash

# version of your package
VERSION_exiv2=0.27

# dependencies of this recipe
DEPS_exiv2=(expat iconv zlib)

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

  try patch -p1 < $RECIPE_exiv2/patches/exiv2.patch
  touch .patched
}

function shouldbuild_exiv2() {
  # If lib is newer than the sourcecode skip build
  if [ $STAGE_PATH/lib/libexiv2.so -nt $BUILD_exiv2/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_exiv2() {
  try mkdir -p $BUILD_PATH/exiv2/build-$ARCH
  try cd $BUILD_PATH/exiv2/build-$ARCH
  push_arm
  try $CMAKECMD \
    -DEXIV2_BUILD_EXIV2_COMMAND=OFF \
    -DEXIV2_BUILD_SAMPLES=OFF \
    -DEXIV2_BUILD_UNIT_TESTS=OFF \
    -DEXIV2_BUILD_DOC=OFF \
    -DEXIV2_ENABLE_NLS=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    $BUILD_exiv2
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_exiv2() {
	true
}
