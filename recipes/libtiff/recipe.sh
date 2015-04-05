#!/bin/bash

# version of your package
VERSION_libtiff=4.0.3

# dependencies of this recipe
DEPS_libtiff=()

# url of the package
URL_libtiff=http://download.osgeo.org/libtiff/tiff-${VERSION_libtiff}.tar.gz

# md5 of the package
MD5_libtiff=051c1068e6a0627f461948c365290410

# default build path
BUILD_libtiff=$BUILD_PATH/libtiff/$(get_directory $URL_libtiff)

# default recipe path
RECIPE_libtiff=$RECIPES_PATH/libtiff

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libtiff() {
  cd $BUILD_libtiff

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_PATH/.packages/config.sub $BUILD_libtiff/config
  try cp $ROOT_PATH/.packages/config.guess $BUILD_libtiff/config
  try patch -p1 < $RECIPE_libtiff/patches/libtiff.patch

  touch .patched
}

# function called before build_libtiff
# set DO_BUILD=0 if you know that it does not require a rebuild
function shouldbuild_libtiff() {
# If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libtiff/build-$ARCH/libtiff/libtiff.la -nt $BUILD_libtiff/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libtiff() {
  try mkdir -p $BUILD_PATH/libtiff/build-$ARCH
  try cd $BUILD_PATH/libtiff/build-$ARCH
	push_arm
  try $BUILD_libtiff/configure --prefix=$STAGE_PATH --host=${TOOLCHAIN_PREFIX}
  try make install
	pop_arm
}

# function called after all the compile have been done
function postbuild_libtiff() {
	true
}
