#!/bin/bash

# version of your package
VERSION_qwt=6.1.1

# dependencies of this recipe
DEPS_qwt=()

# url of the package
URL_qwt=http://downloads.sourceforge.net/qwtect/qwt/qwt/$VERSION_qwt/qwt-${VERSION_qwt}.tar.bz2

# md5 of the package
MD5_qwt=fe4bdd561ef5584924e72e15bcf46b9e

# default build path
BUILD_qwt=$BUILD_PATH/qwt/$(get_directory $URL_qwt)

# default recipe path
RECIPE_qwt=$RECIPES_PATH/qwt

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qwt() {
  cd $BUILD_qwt

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try patch -p1 < $RECIPE_qwt/patches/qwt.patch
  try patch -p2 < $RECIPE_qwt/patches/qwt611-qt54.patch
  try patch -p1 < $RECIPE_qwt/patches/qwt-install.patch
  sed -i "s|^QWT_INSTALL_PREFIX =.*$|QWT_INSTALL_PREFIX = $DIST_PATH|" qwtconfig.pri

  touch .patched
}

function shouldbuild_qwt() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/qwt/build/lib/libqwt.so -nt $BUILD_qwt/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_qwt() {
  try mkdir -p $BUILD_PATH/qwt/build
  try cd $BUILD_PATH/qwt/build
	push_arm
  try qmake $BUILD_qwt
  # sed -i "s|\$(INSTALL_ROOT)/libs/.*/|\$(INSTALL_ROOT)$DIST_PATH/lib/|" src/Makefile
  try make
  sed -i "s|\$(INSTALL_ROOT)/libs/armeabi-v7a/|\$(INSTALL_ROOT)$DIST_PATH/lib/|g" src/Makefile
  try make install
	pop_arm
}

# function called after all the compile have been done
function postbuild_qwt() {
	true
}
