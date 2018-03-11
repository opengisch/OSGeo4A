#!/bin/bash

# version of your package
VERSION_qgis=3.0.0

# dependencies of this recipe
DEPS_qgis=(gdal qca libspatialite spatialindex expat gsl postgresql libzip qtkeychain)
# DEPS_qgis=()

# url of the package
URL_qgis=https://github.com/qgis/QGIS/archive/final-3_0_0.tar.gz

# md5 of the package
MD5_qgis=25ad0c4e6795cc661b77310ac4cf98c4

# default build path
BUILD_qgis=$BUILD_PATH/qgis/$(get_directory $URL_qgis)

# default recipe path
RECIPE_qgis=$RECIPES_PATH/qgis

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qgis() {
  true
}

# function called to build the source code
function build_qgis() {
  try mkdir -p $BUILD_PATH/qgis/build-$ARCH
  try cd $BUILD_PATH/qgis/build-$ARCH

  push_arm

  try cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
    -DANDROID_TOOLCHAIN_VERSION=gcc-4.9 \
    -DWITH_DESKTOP=ON \
    -DDISABLE_DEPRECATED=ON \
    -DWITH_QTWEBKIT=OFF \
    -DQT_LRELEASE_EXECUTABLE=`which lrelease` \
    -DFLEX_EXECUTABLE=`which flex` \
    -DBISON_EXECUTABLE=`which bison` \
    -DGDAL_CONFIG=$STAGE_PATH/bin/gdal-config \
    -DGDAL_CONFIG_PREFER_FWTOOLS_PAT=/bin_safe \
    -DGDAL_CONFIG_PREFER_PATH=$STAGE_PATH/bin \
    -DGDAL_INCLUDE_DIR=$STAGE_PATH/include \
    -DGDAL_LIBRARY=$STAGE_PATH/lib/libgdal.so \
    -DGEOS_CONFIG=$STAGE_PATH/bin/geos-config \
    -DGEOS_CONFIG_PREFER_PATH=$STAGE_PATH/bin \
    -DGEOS_INCLUDE_DIR=$STAGE_PATH/include \
    -DGEOS_LIBRARY=$STAGE_PATH/lib/libgeos_c.so \
    -DGEOS_LIB_NAME_WITH_PREFIX=-lgeos_c \
    -DGSL_CONFIG=$STAGE_PATH/bin/gsl-config \
    -DGSL_CONFIG_PREFER_PATH=$STAGE_PATH/bin \
    -DGSL_EXE_LINKER_FLAGS=-Wl,-rpath, \
    -DGSL_INCLUDE_DIR=$STAGE_PATH/include/gsl \
    -DICONV_INCLUDE_DIR=$STAGE_PATH/include \
    -DICONV_LIBRARY=$STAGE_PATH/lib/libiconv.so \
    -DSQLITE3_INCLUDE_DIR=$STAGE_PATH/include \
    -DSQLITE3_LIBRARY=$STAGE_PATH/lib/libsqlite3.so \
    -DPOSTGRES_CONFIG= \
    -DPOSTGRES_CONFIG_PREFER_PATH= \
    -DPOSTGRES_INCLUDE_DIR=$STAGE_PATH/include \
    -DPOSTGRES_LIBRARY=$STAGE_PATH/lib/libpq.so \
    -DPYTHON_EXECUTABLE=`which python3` \
    -DWITH_BINDINGS=OFF \
    -DWITH_INTERNAL_SPATIALITE=OFF \
    -DWITH_GRASS=OFF \
    -DWITH_QTMOBILITY=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DENABLE_QT5=ON \
    -DENABLE_TESTS=OFF \
    -DEXPAT_INCLUDE_DIR=$STAGE_PATH/include \
    -DEXPAT_LIBRARY=$STAGE_PATH/lib/libexpat.so \
    -DWITH_INTERNAL_QWTPOLAR=OFF \
    -DWITH_QWTPOLAR=OFF \
    -DWITH_GUI=OFF \
    -DSPATIALINDEX_LIBRARY=$STAGE_PATH/lib/libspatialindex.so \
    -DWITH_APIDOC=OFF \
    -DWITH_ASTYLE=OFF \
    -DANDROID_NDK=$ANDROIDNDK \
    -DANDROID_STL=gnustl_shared \
    -DANDROID_ABI=$ARCH \
    -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
    $BUILD_qgis

  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_qgis() {
  true
}
