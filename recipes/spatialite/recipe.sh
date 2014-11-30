#!/bin/bash

# version of your package
VERSION_spatialite=4.2.0

# dependencies of this recipe
DEPS_spatialite=(sqlite proj iconv freexl geos)

# url of the package
URL_spatialite=http://www.gaia-gis.it/gaia-sins/libspatialite-${VERSION_spatialite}.tar.gz

# md5 of the package
MD5_spatialite=83305ed694a77152120d1f74c5151779

# default build path
BUILD_spatialite=$BUILD_PATH/spatialite/$(get_directory $URL_spatialite)

# default recipe path
RECIPE_spatialite=$RECIPES_PATH/spatialite

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_spatialite() {
  cd $BUILD_spatialite

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_spatialite
  try cp $BUILD_PATH/tmp/config.guess $BUILD_spatialite
  try patch -p1 < $RECIPE_spatialite/patches/spatialite.patch

  touch .patched
}

# function called to build the source code
function build_spatialite() {
  try mkdir -p $BUILD_PATH/spatialite/build
  try cd $BUILD_PATH/spatialite/build
	push_arm
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS} -lgeos -lgeos_c -lstdc++ -lsupc++ -llog" \
    try $BUILD_spatialite/configure \
    --prefix=$DIST_PATH \
    --host=arm-linux-androideabi \
    --with-geosconfig=$DIST_PATH/bin/geos-config \
    --enable-libxml2=no
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_spatialite() {
	true
}
