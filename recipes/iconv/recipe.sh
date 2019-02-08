#!/bin/bash

# version of your package
VERSION_iconv=1.14

# dependencies of this recipe
DEPS_iconv=()

# url of the package
URL_iconv=http://ftpmirror.gnu.org/gnu/libiconv/libiconv-${VERSION_iconv}.tar.gz

# md5 of the package
MD5_iconv=e34509b1623cec449dfeb73d7ce9c6c6

# default build path
BUILD_iconv=$BUILD_PATH/iconv/$(get_directory $URL_iconv)

# default recipe path
RECIPE_iconv=$RECIPES_PATH/iconv

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_iconv() {
  cd $BUILD_iconv

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try patch -p1 < $RECIPES_PATH/iconv/patches/libiconv.patch
  try cp $ROOT_PATH/.packages/config.sub $BUILD_iconv/build-aux
  try cp $ROOT_PATH/.packages/config.guess $BUILD_iconv/build-aux
  try cp $ROOT_PATH/.packages/config.sub $BUILD_iconv/libcharset/build-aux
  try cp $ROOT_PATH/.packages/config.guess $BUILD_iconv/libcharset/build-aux

  touch .patched
}

function shouldbuild_iconv() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/iconv/build-$ARCH/libcharset/lib/.libs/libcharset.so -nt $BUILD_iconv/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_iconv() {
  try mkdir -p $BUILD_PATH/iconv/build-$ARCH
  try cd $BUILD_PATH/iconv/build-$ARCH

  push_arm

  try $BUILD_iconv/configure \
    --prefix=$STAGE_PATH \
    --host=$TOOLCHAIN_PREFIX \
    --build=x86_64
  try $MAKESMP
  try make install

  pop_arm
}

# function called after all the compile have been done
function postbuild_iconv() {
	true
}
