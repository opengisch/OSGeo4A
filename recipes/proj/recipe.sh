#!/bin/bash

# version of your package
VERSION_proj=5.3

# dependencies of this recipe
DEPS_proj=(sqlite3)

# url of the package
URL_proj=https://github.com/OSGeo/proj.4/archive/a8cbe0c66974871f5a7bd7ef94001ebf461ac7ea.tar.gz

# md5 of the package
MD5_proj=a7d111fb0253e5f7b0a531f0659bcad3

# default build path
BUILD_proj=$BUILD_PATH/proj/$(get_directory $URL_proj)

# default recipe path
RECIPE_proj=$RECIPES_PATH/proj

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_proj() {
  cd $BUILD_proj

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_proj() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/proj/build-$ARCH/src/.libs/libproj.so -nt $BUILD_proj/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_proj() {
  try mkdir -p $BUILD_PATH/proj/build-$ARCH
  try cd $BUILD_PATH/proj/build-$ARCH

  push_arm

#  try $BUILD_proj/configure \
#    --prefix=$STAGE_PATH \
#    --host=$TOOLCHAIN_PREFIX \
#    --build=x86_64
  try cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROIDNDK/build/cmake/android.toolchain.cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DANDROID=ON \
    -DANDROID_ABI=$ARCH \
    -DANDROID_NDK=$ANDROID_NDK \
    -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
    -DPROJ_TESTS=OFF \
    -DEXE_SQLITE3=$(which sqlite3) \
    $BUILD_proj
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_proj() {
	true
}
