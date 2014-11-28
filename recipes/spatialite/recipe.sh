#!/bin/bash

# version of your package
VERSION_spatialite=4.2.0

# dependencies of this recipe
DEPS_spatialite=()

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

  try cp $BUILD_PATH/tmp/config.sub $BUILD_spatialite/conftools
  try cp $BUILD_PATH/tmp/config.guess $BUILD_spatialite/conftools
  try patch -p1 < $RECIPE_spatialite/patches/spatialite.patch

  touch .patched
}

# function called to build the source code
function build_spatialite() {
  try mkdir -p $BUILD_PATH/spatialite/build
  try cd $BUILD_PATH/spatialite/build
	push_arm
  printenv
  try $BUILD_spatialite/configure --prefix=$DIST_PATH --host=arm-linux-androideabi
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_spatialite() {
	true
}
