#!/bin/bash

# version of your package
VERSION_qgis=2.6.0

# dependencies of this recipe
# DEPS_qgis=(gdal qwt qwtpolar qscintilla spatialite spatialindex expat)
DEPS_qgis=(gsl)

# url of the package
URL_qgis=https://github.com/m-kuhn/QGIS/archive/android-2_6.tar.gz

# md5 of the package
MD5_qgis=ee40de40d0d406a882e74bba1860cae9

# default build path
BUILD_qgis=$BUILD_PATH/qgis/$(get_directory $URL_qgis)

# default recipe path
RECIPE_qgis=$RECIPES_PATH/qgis

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qgis() {
  cd $BUILD_qgis

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $BUILD_PATH/tmp/config.sub $BUILD_qgis
  try cp $BUILD_PATH/tmp/config.guess $BUILD_qgis
  try patch -p1 < $RECIPE_qgis/patches/qgis.patch
  try patch -p1 < $RECIPE_qgis/patches/qgis_std_nan.patch

  touch .patched
}

# function called to build the source code
function build_qgis() {
  try mkdir -p $BUILD_PATH/qgis/build
  try cd $BUILD_PATH/qgis/build
	push_arm
  printenv
#  CXXFLAGS="${CXXFLAGS} -I${ANDROIDNDK}/sources/cxx-stl/gnu-libstdc++/4.9/include" \
#  LDFLAGS="${LDFLAGS} -L${ANDROIDNDK}/sources/cxx-stl/gnu-libstdc++/4.9/armeabi-v7a" \
#    try $BUILD_qgis/configure --prefix=$DIST_PATH --host=arm-linux-androideabi
  try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
    -DFLEX_EXECUTABLE=/usr/bin/flex \
    -DBISON_EXECUTABLE=/usr/bin/bison \
    -DGDAL_CONFIG=$DIST_PATH/bin/gdal-config \
    -DGDAL_CONFIG_PREFER_FWTOOLS_PAT=/bin_safe \
    -DGDAL_CONFIG_PREFER_PATH=$DIST_PATH/bin \
    -DGDAL_INCLUDE_DIR=$DIST_PATH/include \
    -DGDAL_LIBRARY=$DIST_PATH/lib/libgdal.so \
    -DGEOS_CONFIG=$DIST_PATH/bin/geos-config \
    -DGEOS_CONFIG_PREFER_PATH=$DIST_PATH/bin \
    -DGEOS_INCLUDE_DIR=$DIST_PATH/include \
    -DGEOS_LIBRARY=$DIST_PATH/lib/libgeos_c.so \
    -DGEOS_LIB_NAME_WITH_PREFIX=-lgeos_c \
    -DGSL_CONFIG=$DIST_PATH/bin/gsl-config \
    -DGSL_CONFIG_PREFER_PATH=$DIST_PATH/bin \
    -DGSL_EXE_LINKER_FLAGS=-Wl,-rpath, \
    -DGSL_INCLUDE_DIR=$DIST_PATH/include/gsl \
    -DICONV_INCLUDE_DIR=$DIST_PATH/include \
    -DICONV_LIBRARY=$DIST_PATH/lib/libiconv.so \
    -DSQLITE3_INCLUDE_DIR=$DIST_PATH/include \
    -DSQLITE3_LIBRARY=$DIST_PATH/lib/libsqlite3.so \
    -DWITH_BINDINGS=OFF \
    -DWITH_INTERNAL_SPATIALITE=OFF \
    -DWITH_GRASS=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=$DIST_PATH \
    -DENABLE_QT5=ON \
    -DENABLE_TESTS=OFF \
    -DEXPAT_INCLUDE_DIR=$DIST_PATH/include \
    -DEXPAT_LIBRARY=$DIST_PATH/lib/libexpat.so \
    -DQWT_INCLUDE_DIR=$DIST_PATH/include \
    -DQWT_LIBRARY=$DIST_PATH/lib/libqwt.so \
    -DWITH_INTERNAL_QWTPOLAR=OFF \
    -DQWTPOLAR_INCLUDE_DIR=$DIST_PATH/include \
    -DQWTPOLAR_LIBRARY=$DIST_PATH/lib/libqwtpolar.so \
    -DQSCINTILLA_INCLUDE_DIR=$DIST_PATH/include \
    -DQSCINTILLA_LIBRARY=$DIST_PATH/lib/libqscintilla2.so \
    -DSPATIALINDEX_LIBRARY=$DIST_PATH/lib/libspatialindex.so \
    -DWITH_APIDOC=OFF \
    -DWITH_ASTYLE=OFF \
    $BUILD_qgis
  echo '#define qgis_SVN_REVISION 0' > $BUILD_PATH/qgis/build/qgis_svn_revision.h
  # try make -j$CORES
  try make install -j$CORES
	pop_arm
}

# function called after all the compile have been done
function postbuild_qgis() {
	true
}
