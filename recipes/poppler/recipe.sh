#!/bin/bash

# version of your package
VERSION_poppler=21.01.0

# dependencies of this recipe
DEPS_poppler=(freetype libpng)

# url of the package
URL_poppler=https://gitlab.freedesktop.org/poppler/poppler/-/archive/poppler-${VERSION_poppler}/poppler-poppler-${VERSION_poppler}.tar.gz
# md5 of the package
MD5_poppler=591f6f306dadcc087a2ea1c23bd420af

# default build path
BUILD_poppler=$BUILD_PATH/poppler/$(get_directory $URL_poppler)

# default recipe path
RECIPE_poppler=$RECIPES_PATH/poppler

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_poppler() {
  cd $BUILD_poppler

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_poppler() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/poppler/build-$ARCH/lib/libpoppler.so -nt $BUILD_poppler/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_poppler() {
  try mkdir -p $BUILD_PATH/poppler/build-$ARCH
  try cd $BUILD_PATH/poppler/build-$ARCH
  push_arm
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DENABLE_DCTDECODER=none \
    -DENABLE_UTILS=OFF \
    -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
    $BUILD_poppler
  try $MAKESMP
  try $MAKESMP install
  try cp $STAGE_PATH/lib/libpoppler_$ARCH.so $STAGE_PATH/lib/libpoppler.so
  pop_arm
}

# function called after all the compile have been done
function postbuild_poppler() {
	true
}
