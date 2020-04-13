#!/bin/bash

# version of your package
VERSION_protobuf=3.0.2 # Has to match host version

# dependencies of this recipe
DEPS_protobuf=(zlib)

# url of the package
#URL_protobuf=http://www.protobuf.org/builds/protobuf-0.26-trunk.tar.gz
URL_protobuf=https://github.com/protocolbuffers/protobuf/archive/v${VERSION_protobuf}/protobuf-cpp-${VERSION_protobuf}.tar.gz

# md5 of the package
MD5_protobuf=7349a7f43433d72c6d805c6ca22b7eeb

# default build path
BUILD_protobuf=$BUILD_PATH/protobuf/$(get_directory $URL_protobuf)

# default recipe path
RECIPE_protobuf=$RECIPES_PATH/protobuf

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_protobuf() {
  cd $BUILD_protobuf

  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_protobuf() {
  # If lib is newer than the sourcecode skip build
  if [ $STAGE_PATH/lib/libprotobuf.so -nt $BUILD_protobuf/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_protobuf() {
  try mkdir -p $BUILD_PATH/protobuf/build-$ARCH
  try cd $BUILD_PATH/protobuf/build-$ARCH
  push_arm
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -Dprotobuf_BUILD_TESTS=OFF \
    -DANDROID_LINKER_FLAGS="-landroid -llog" \
    $BUILD_protobuf/cmake
  try $MAKESMP install
  pop_arm
}

# function called after all the compile have been done
function postbuild_protobuf() {
	true
}
