#!/bin/bash

# version of your package
VERSION_gettext=0.26

# dependencies of this recipe
DEPS_gettext=(expat iconv)

# url of the package
#URL_gettext=http://www.gettext.org/builds/gettext-0.26-trunk.tar.gz
URL_gettext=http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.8.1.tar.gz

# md5 of the package
MD5_gettext=97e034cf8ce5ba73a28ff6c3c0638092

# default build path
BUILD_gettext=$BUILD_PATH/gettext/$(get_directory $URL_gettext)

# default recipe path
RECIPE_gettext=$RECIPES_PATH/gettext

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_gettext() {
  cd $BUILD_gettext

  # check marker
  if [ -f .patched ]; then
    return
  fi
}

function shouldbuild_gettext() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/gettext/build-$ARCH/gettext/gettext.so -nt $BUILD_gettext/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_gettext() {
  try mkdir -p $BUILD_PATH/gettext/build-$ARCH
  try cd $BUILD_PATH/gettext/build-$ARCH
  push_arm
  try ./configure
  try $MAKESMP
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_gettext() {
	true
}
