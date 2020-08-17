#!/bin/bash

# version of your package
VERSION_sqlite3=3330000

# dependencies of this recipe
DEPS_sqlite3=()

# url of the package
URL_sqlite3=http://www.sqlite.org/2020/sqlite-amalgamation-${VERSION_sqlite3}.zip

# md5 of the package
MD5_sqlite3=944829c3d88a958be935480b8e56b1fb

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

  try cp $RECIPES_PATH/sqlite3/CMakeLists.txt $BUILD_sqlite3
  try cp $RECIPES_PATH/sqlite3/sqlite3_config.h.in $BUILD_sqlite3

  touch .patched
}

function shouldbuild_sqlite3() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/sqlite3/build-$ARCH/.libs/libsqlite3.so -nt $BUILD_sqlite3/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_sqlite3() {
  try mkdir -p $BUILD_PATH/sqlite3/build-$ARCH
  try cd $BUILD_PATH/sqlite3/build-$ARCH
	push_arm
  export CFLAGS="${CFLAGS} -DSQLITE_ENABLE_COLUMN_METADATA"
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    $BUILD_sqlite3
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_sqlite3() {
  true
}
