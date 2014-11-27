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

# function called to build the source code
function build_qscintilla() {
  try mkdir -p $BUILD_qscintilla/build
  try cd $BUILD_qscintilla/build

	push_arm

  # configure
  try qmake ../Qt4Qt5/qscintilla.pro

  # build
  try make -j$CORES

  # tweak install path
  sed -i "s|\$(INSTALL_ROOT).*/lib|\$(INSTALL_ROOT)/lib/|" Makefile
  sed -i "s|\$(INSTALL_ROOT).*/include|\$(INSTALL_ROOT)/include/|" Makefile

  # Makefile fails to create include and lib folders if not present
  test -d $DIST_PATH/include || mkdir -p $DIST_PATH/include
  test -d $DIST_PATH/lib || mkdir -p $DIST_PATH/lib

  # install
  export INSTALL_ROOT=$DIST_PATH
  try make install

	pop_arm
}

# function called after all the compile have been done
function postbuild_qscintilla() {
	true
}
