#!/bin/bash

# version of your package
VERSION_sqlite=3080702

# dependencies of this recipe
DEPS_sqlite=()

# url of the package
URL_sqlite=http://www.sqlite.org/2014/sqlite-autoconf-${VERSION_sqlite}.tar.gz

# md5 of the package
MD5_sqlite=0f847048745ddbdf0c441c82d096fbb4

# default build path
BUILD_sqlite=$BUILD_PATH/sqlite/$(get_directory $URL_sqlite)

# default recipe path
RECIPE_sqlite=$RECIPES_PATH/sqlite

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_sqlite() {
  cd $BUILD_sqlite

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_sqlite
  try cp $BUILD_PATH/tmp/config.guess $BUILD_sqlite
  try patch -p1 < $RECIPE_sqlite/patches/sqlite.patch

  touch .patched
}

# function called to build the source code
function build_sqlite() {
  try mkdir -p $BUILD_PATH/sqlite/build
  try cd $BUILD_PATH/sqlite/build
	push_arm
  try $BUILD_sqlite/configure --prefix=$DIST_PATH --host=arm-linux-androideabi
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_sqlite() {
	true
}
