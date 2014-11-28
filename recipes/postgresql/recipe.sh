#!/bin/bash

# version of your package
VERSION_postgresql=9.3.5

# dependencies of this recipe
DEPS_postgresql=(iconv)

# url of the package
URL_postgresql=https://ftp.postgresql.org/pub/source/v${VERSION_postgresql}/postgresql-${VERSION_postgresql}.tar.bz2

# md5 of the package
MD5_postgresql=5059857c7d7e6ad83b6d55893a121b59

# default build path
BUILD_postgresql=$BUILD_PATH/postgresql/$(get_directory $URL_postgresql)

# default recipe path
RECIPE_postgresql=$RECIPES_PATH/postgresql

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_postgresql() {
  cd $BUILD_postgresql

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_postgresql/conftools
  try cp $BUILD_PATH/tmp/config.guess $BUILD_postgresql/conftools
  try patch -p1 < $RECIPE_postgresql/patches/postgresql.patch

  touch .patched
}

# function called to build the source code
function build_postgresql() {
  try mkdir -p $BUILD_PATH/postgresql/build
  try cd $BUILD_PATH/postgresql/build
	push_arm
  printenv
  try $BUILD_postgresql/configure --prefix=$DIST_PATH --host=arm-linux-androideabi --without-readline
  # sed -i "s|/\* #undef HAVE_SRANDOM \*/|#define HAVE_SRANDOM 1|" $BUILD_PATH/postgresql/build/src/include/pg_config.h
  # sed -i "s|/\* #undef HAVE_RANDOM \*/|#define HAVE_RANDOM 1|" $BUILD_PATH/postgresql/build/src/include/pg_config.h
  try make install -j$CORES -C src/interfaces/libpq
	pop_arm
}

# function called after all the compile have been done
function postbuild_postgresql() {
	true
}
