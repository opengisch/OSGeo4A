#!/bin/bash

# version of your package
VERSION_qwtpolar=1.1.0

# dependencies of this recipe
DEPS_qwtpolar=(qwt)

# url of the package
URL_qwtpolar=http://downloads.sourceforge.net/project/qwtpolar/qwtpolar/$VERSION_qwtpolar/qwtpolar-${VERSION_qwtpolar}.tar.bz2

# md5 of the package
MD5_qwtpolar=fa6ac4e9dbebe81e41e482c7d2a24159

# default build path
BUILD_qwtpolar=$BUILD_PATH/qwtpolar/$(get_directory $URL_qwtpolar)

# default recipe path
RECIPE_qwtpolar=$RECIPES_PATH/qwtpolar

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qwtpolar() {
  cd $BUILD_qwtpolar

  # check marker
  if [ -f .patched ]; then
    return
  fi

  patch -p1 < $RECIPES_PATH/qwtpolar/patches/qwtpolar-features.patch
  echo "INCLUDEPATH += $DIST_PATH/include" >> qwtpolarconfig.pri
  echo "LIBS += $DIST_PATH/lib/libqwt.so" >> qwtpolarconfig.pri
  sed -i "s|QWT_POLAR_INSTALL_PREFIX    = .*|QWT_POLAR_INSTALL_PREFIX = $DIST_PATH|" qwtpolarconfig.pri

  touch .patched
}

# function called to build the source code
function build_qwtpolar() {
  try mkdir -p $BUILD_PATH/qwtpolar/build
  try cd $BUILD_PATH/qwtpolar/build
	push_arm
  try qmake $BUILD_qwtpolar
  try make # -j$CORES
  sed -i "s|\$(INSTALL_ROOT)/libs/armeabi-v7a/|\$(INSTALL_ROOT)$DIST_PATH/lib/|g" src/Makefile
  try make install #-j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_qwtpolar() {
	true
}
