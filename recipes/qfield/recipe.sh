#!/bin/bash

# version of your package
VERSION_qfield=0.2.3

# dependencies of this recipe
DEPS_qfield=(qgis)

# url of the package
URL_qfield=https://github.com/opengis-ch/QGIS-Mobile/archive/master.tar.gz

# md5 of the package
MD5_qfield=5b16f8a358674ca3490a64692146fa1d

# default build path
BUILD_qfield=$BUILD_PATH/qfield/$(get_directory $URL_qfield)

# default recipe path
RECIPE_qfield=$RECIPES_PATH/qfield

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qfield() {
  true
}

# function called to build the source code
function build_qfield() {
  return
  try mkdir -p $BUILD_PATH/qfield/build
  try cd $BUILD_PATH/qfield/build
	push_arm
  CMAKE_INCLUDE_PATH=$STAGE_PATH/include \
     try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
    -DANDROID_STL=gnustl_shared \
    -DQGIS_ANALYSIS_LIBRARY:FILEPATH=$STAGE_PATH/lib/libqgis_analysis.so \
    -DQGIS_CORE_LIBRARY:FILEPATH=$STAGE_PATH/lib/libqgis_core.so\
    -DQGIS_GUI_LIBRARY:FILEPATH=$STAGE_PATH/lib/libqgis_gui.so \
    -DQGIS_INCLUDE_DIR:FILEPATH=$STAGE_PATH/include/qgis \
    -DGEOS_CONFIG=$STAGE_PATH/bin/geos-config \
    -DGEOS_CONFIG_PREFER_PATH=$STAGE_PATH/bin \
    -DGEOS_INCLUDE_DIR=$STAGE_PATH/include \
    -DGEOS_LIBRARY=$STAGE_PATH/lib/libgeos_c.so \
    -DGEOS_LIB_NAME_WITH_PREFIX=-lgeos_c \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DLIBRARY_OUTPUT_PATH_ROOT:PATH=$STAGE_PATH \
    -DENABLE_TESTS:BOOL=FALSE \
    -DANDROID_NATIVE_API_LEVEL=19 \
    -DGIT_EXECUTABLE=`which git` \
    $BUILD_qfield
  ${SILENCE_OUTPUT} qfield "$MAKESMP" install
  try make install
	pop_arm
}

# function called after all the compile have been done
function postbuild_qfield() {
	true
}
