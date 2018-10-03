#!/bin/bash

# version of your package
VERSION_qscintilla=2.8.4

# dependencies of this recipe
DEPS_qscintilla=()

# url of the package
URL_qscintilla=http://downloads.sourceforge.net/project/pyqt/QScintilla2/QScintilla-${VERSION_qscintilla}/QScintilla-gpl-${VERSION_qscintilla}.tar.gz

# md5 of the package
MD5_qscintilla=28aec903ff48ae541295a4fb9c96f8ea

# default build path
BUILD_qscintilla=$BUILD_PATH/qscintilla/$(get_directory $URL_qscintilla)

# default recipe path
RECIPE_qscintilla=$RECIPES_PATH/qscintilla

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qscintilla() {
  true
}

function shouldbuild_qscintilla() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_qscintilla/build-$ARCH/libqscintilla2.so -nt $BUILD_qscintilla/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_qscintilla() {
  try mkdir -p $BUILD_qscintilla/build-$ARCH
  try cd $BUILD_qscintilla/build-$ARCH

  push_arm

  # configure
  LDFLAGS="${LDFLAGS} -L$ANDROIDNDK/sources/crystax/libs/$ARCH" \
    try qmake ../Qt4Qt5/qscintilla.pro

  # build
  try $MAKESMP

  # tweak install path
  sed -i "s|\$(INSTALL_ROOT).*/lib|\$(INSTALL_ROOT)/lib/|" Makefile
  sed -i "s|\$(INSTALL_ROOT).*/include|\$(INSTALL_ROOT)/include/|" Makefile

  # Makefile fails to create include and lib folders if not present
  test -d $STAGE_PATH/include || mkdir -p $STAGE_PATH/include
  test -d $STAGE_PATH/lib || mkdir -p $STAGE_PATH/lib

  # install
  INSTALL_ROOT=$STAGE_PATH \
    try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_qscintilla() {
  true
}
