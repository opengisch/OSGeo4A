#!/bin/bash

# version of your package
VERSION_gdal=3.3.2

# dependencies of this recipe
DEPS_gdal=(iconv sqlite3 geos postgresql expat openjpeg libspatialite webp libpng poppler)

# url of the package
URL_gdal=https://download.osgeo.org/gdal/$VERSION_gdal/gdal-${VERSION_gdal}.tar.gz

# md5 of the package
MD5_gdal=fd82c580ec9e16a0a46cd176243a8a56

# default build path
BUILD_gdal=$BUILD_PATH/gdal/$(get_directory $URL_gdal)

# default recipe path
RECIPE_gdal=$RECIPES_PATH/gdal

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_gdal() {
  cd $BUILD_gdal

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_OUT_PATH/.packages/config.sub $BUILD_gdal
  try cp $ROOT_OUT_PATH/.packages/config.guess $BUILD_gdal
  # Remove bundled lib
  try rm -rf $BUILD_gdal/frmts/zlib

  touch .patched
}

function shouldbuild_gdal() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/gdal/build-$ARCH/.libs/libgdal.so -nt $BUILD_gdal/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_gdal() {
  try rsync -a $BUILD_gdal/ $BUILD_PATH/gdal/build-$ARCH/
  try cd $BUILD_PATH/gdal/build-$ARCH

  push_arm

  try ${BUILD_PATH}/gdal/build-$ARCH/configure \
    --host=$TOOLCHAIN_PREFIX \
    --build=x86_64 \
    --prefix=$STAGE_PATH \
    --with-sqlite3=$STAGE_PATH \
    --with-spatialite=$STAGE_PATH \
    --with-geos=$STAGE_PATH/bin/geos-config \
    --with-pg=no \
    --with-expat=$STAGE_PATH \
    --with-openjpeg=$STAGE_PATH \
    --with-poppler=$STAGE_PATH \
    --with-jpeg=internal \
    --with-libtiff=internal \
    --with-geotiff=internal
  try $MAKESMP
  try $MAKESMP install &> install.log
  pop_arm
}

# function called after all the compile have been done
function postbuild_gdal() {
  true
}
