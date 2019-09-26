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
  echo "INCLUDEPATH += $STAGE_PATH/include" >> qwtpolarconfig.pri
  echo "LIBS += $STAGE_PATH/lib/libqwt.so" >> qwtpolarconfig.pri
  sed -i "s|QWT_POLAR_INSTALL_PREFIX    = .*|QWT_POLAR_INSTALL_PREFIX = $STAGE_PATH|" qwtpolarconfig.pri

  touch .patched
}

function shouldbuild_qwtpolar() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_qwtpolar/lib/libqwtpolar.so -nt $BUILD_qwtpolar/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_qwtpolar() {
  try mkdir -p $BUILD_PATH/qwtpolar/build-$ARCH
  try cd $BUILD_PATH/qwtpolar/build-$ARCH

  push_arm

  try qmake $BUILD_qwtpolar
  try $MAKESMP
  sed -i "s|\$(INSTALL_ROOT)/libs/${ARCH}/|\$(INSTALL_ROOT)$STAGE_PATH/lib/|g" src/Makefile
  try make install

  pop_arm
}

# function called after all the compile have been done
function postbuild_qwtpolar() {
	true
}
