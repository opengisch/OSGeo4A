#!/bin/bash

# version of your package
VERSION_libspatialite=4.2.0

# dependencies of this recipe
DEPS_libspatialite=(sqlite3 proj iconv freexl geos)

# url of the package
URL_libspatialite=http://www.gaia-gis.it/gaia-sins/libspatialite-${VERSION_libspatialite}.tar.gz

# md5 of the package
MD5_libspatialite=83305ed694a77152120d1f74c5151779

# default build path
BUILD_libspatialite=$BUILD_PATH/libspatialite/$(get_directory $URL_libspatialite)

# default recipe path
RECIPE_libspatialite=$RECIPES_PATH/libspatialite

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libspatialite() {
  cd $BUILD_libspatialite

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_libspatialite
  try cp $BUILD_PATH/tmp/config.guess $BUILD_libspatialite
  try patch -p1 < $RECIPE_libspatialite/patches/spatialite.patch

  touch .patched
}

function shouldbuild_libspatialite() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libspatialite/build/src/.libs/libspatialite.so -nt $BUILD_libspatialite/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libspatialite() {
  try mkdir -p $BUILD_PATH/libspatialite/build
  try cd $BUILD_PATH/libspatialite/build
	push_arm
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS} -lgeos -lgeos_c -lstdc++ -lsupc++ -llog" \
  LDFLAGS="${LDFLAGS} -L$ANDROIDNDK/sources/cxx-stl/gnu-libstdc++/$TOOLCHAIN_VERSION/libs/${ARCH}" \
    try $BUILD_libspatialite/configure \
    --prefix=$DIST_PATH \
    --host=arm-linux-androideabi \
    --with-geosconfig=$DIST_PATH/bin/geos-config \
    --enable-libxml2=no
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_libspatialite() {
	true
}
