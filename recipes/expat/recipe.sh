#!/bin/bash

# version of your package
VERSION_expat=2.4.1

# dependencies of this recipe
DEPS_expat=()

# url of the package
URL_expat=http://freefr.dl.sourceforge.net/project/expat/expat/$VERSION_expat/expat-${VERSION_expat}.tar.gz

# md5 of the package
MD5_expat=8738ef9ed1c5dcc03207286ea84f4299

# default build path
BUILD_expat=$BUILD_PATH/expat/$(get_directory $URL_expat)

# default recipe path
RECIPE_expat=$RECIPES_PATH/expat

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_expat() {
  cd $BUILD_expat

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_expat() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/expat/build-$ARCH/.libs/libexpat.so -nt $BUILD_expat/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_expat() {
  try mkdir -p $BUILD_PATH/expat/build-$ARCH
  try cd $BUILD_PATH/expat/build-$ARCH

  push_arm

  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    $BUILD_expat
  
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_expat() {
	true
}
