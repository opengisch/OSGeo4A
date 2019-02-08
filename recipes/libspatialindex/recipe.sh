#!/bin/bash

# version of your package
VERSION_libspatialindex=1.9.0

# dependencies of this recipe
DEPS_libspatialindex=()

# url of the package
URL_libspatialindex=https://github.com/libspatialindex/libspatialindex/archive/${VERSION_libspatialindex}.tar.gz

# md5 of the package
MD5_libspatialindex=aa658bf627cd57b5277d204bac0605fc

# default build path
BUILD_libspatialindex=$BUILD_PATH/libspatialindex/$(get_directory $URL_libspatialindex)

# default recipe path
RECIPE_libspatialindex=$RECIPES_PATH/libspatialindex

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libspatialindex() {
  cd $BUILD_libspatialindex

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_PATH/.packages/config.sub $BUILD_libspatialindex
  try cp $ROOT_PATH/.packages/config.guess $BUILD_libspatialindex
  touch .patched
}

function shouldbuild_libspatialindex() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libspatialindex/build-$ARCH/.libs/libspatialindex.so -nt $BUILD_libspatialindex/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libspatialindex() {
  try mkdir -p $BUILD_PATH/libspatialindex/build-$ARCH
  try cd $BUILD_PATH/libspatialindex/build-$ARCH

  push_arm

  try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROIDNDK/build/cmake/android.toolchain.cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DANDROID=ON \
    -DANDROID_ABI=$ARCH \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
    $BUILD_libspatialindex

  try $MAKESMP
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_libspatialindex() {
	true
}
