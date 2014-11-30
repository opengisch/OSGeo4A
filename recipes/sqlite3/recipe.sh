#!/bin/bash

# version of your package
VERSION_sqlite3=3080702

# dependencies of this recipe
DEPS_sqlite3=()

# url of the package
URL_sqlite3=http://www.sqlite.org/2014/sqlite-autoconf-${VERSION_sqlite3}.tar.gz

# md5 of the package
MD5_sqlite3=0f847048745ddbdf0c441c82d096fbb4

# default build path
BUILD_sqlite3=$BUILD_PATH/sqlite3/$(get_directory $URL_sqlite3)

# default recipe path
RECIPE_sqlite3=$RECIPES_PATH/sqlite3

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_sqlite3() {
  cd $BUILD_sqlite3

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_sqlite3
  try cp $BUILD_PATH/tmp/config.guess $BUILD_sqlite3
  try patch -p1 < $RECIPE_sqlite3/patches/sqlite.patch

  touch .patched
}

# function called to build the source code
function build_sqlite3() {
  try mkdir -p $BUILD_PATH/sqlite3/build
  try cd $BUILD_PATH/sqlite3/build
	push_arm
  try $BUILD_sqlite3/configure --prefix=$DIST_PATH --host=arm-linux-androideabi
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_sqlite3() {
	true
}
