#!/bin/bash

# version of your package
VERSION_qgismobile=2.6.0

# dependencies of this recipe
DEPS_qgismobile=(qgis)

# url of the package
URL_qgismobile=https://github.com/opengis-ch/QGIS-Mobile/archive/master.tar.gz

# md5 of the package
MD5_qgismobile=5b16f8a358674ca3490a64692146fa1d

# default build path
BUILD_qgismobile=$BUILD_PATH/qgismobile/$(get_directory $URL_qgismobile)

# default recipe path
RECIPE_qgismobile=$RECIPES_PATH/qgismobile

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qgismobile() {
  cd $BUILD_qgismobile

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

# function called to build the source code
function build_qgismobile() {
  try mkdir -p $BUILD_PATH/qgismobile/build
  try cd $BUILD_PATH/qgismobile/build
	push_arm
  CMAKE_INCLUDE_PATH=$DIST_PATH/include \
     try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
    -DANDROID_STL=gnustl_shared \
    -DQGIS_ANALYSIS_LIBRARY:FILEPATH=$DIST_PATH/lib/libqgis_analysis.so \
    -DQGIS_CORE_LIBRARY:FILEPATH=$DIST_PATH/lib/libqgis_core.so\
    -DQGIS_GUI_LIBRARY:FILEPATH=$DIST_PATH/lib/libqgis_gui.so \
    -DQGIS_INCLUDE_DIR:FILEPATH=$DIST_PATH/include/qgis \
    -DGEOS_CONFIG=$DIST_PATH/bin/geos-config \
    -DGEOS_CONFIG_PREFER_PATH=$DIST_PATH/bin \
    -DGEOS_INCLUDE_DIR=$DIST_PATH/include \
    -DGEOS_LIBRARY=$DIST_PATH/lib/libgeos_c.so \
    -DGEOS_LIB_NAME_WITH_PREFIX=-lgeos_c \
    -DCMAKE_INSTALL_PREFIX:PATH=$DIST_PATH \
    $BUILD_qgismobile
  try make
  try make install
	pop_arm
}

# function called after all the compile have been done
function postbuild_qgismobile() {
	true
}
