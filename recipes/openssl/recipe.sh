#!/bin/bash


# version of your package
VERSION_openssl=1.1.1g

# dependencies of this recipe
DEPS_openssl=()

# url of the package
URL_openssl=https://www.openssl.org/source/openssl-${VERSION_openssl}.tar.gz

# md5 of the package
MD5_openssl=76766e98997660138cdaf13a187bd234

# default recipe path
RECIPE_openssl=$RECIPES_PATH/openssl

# default build path
BUILD_openssl=$BUILD_PATH/openssl/$(get_directory $URL_openssl)

# function called for preparing source code if needed
function prebuild_openssl() {
  touch .patched
}

function shouldbuild_openssl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/openssl/build-$ARCH/libssl.so -nt $BUILD_openssl/.patched ]; then
    DO_BUILD=0
  fi

  touch .patched
}

# function called to build the source code
function build_openssl() {
  try mkdir $BUILD_PATH/openssl/build-$ARCH/
  try cd $BUILD_PATH/openssl/build-$ARCH/

  # Setup compiler toolchain based on CPU architecture
  if [ "X${ARCH}" == "Xarmeabi-v7a" ]; then
      export SSL_ARCH=android-arm
  elif [ "X${ARCH}" == "Xarm64-v8a" ]; then
      export SSL_ARCH=android-arm64
  elif [ "X${ARCH}" == "Xx86" ]; then
      export SSL_ARCH=android-x86
  elif [ "X${ARCH}" == "Xx86_64" ]; then
      export SSL_ARCH=android-x86_64
  else
      echo "Error: Please report issue to enable support for arch (${ARCH})."
      exit 1
  fi

  push_arm
  export CC=$TOOLCHAIN_FULL_PREFIX-clang
  export CFLAGS=""
  export ANDROID_NDK_HOME=$ANDROIDNDK

  try $BUILD_openssl/Configure shared ${SSL_ARCH} -D__ANDROID_API__=$ANDROIDAPI --prefix=/
  ${MAKE} depend
  ${MAKE} DESTDIR=${STAGE_PATH} SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so build_libs

  # install
  try ${MAKE} SHLIB_VERSION_NUMBER= SHLIB_EXT=_1_1.so DESTDIR=$STAGE_PATH install_dev install_engines

  pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
  true
}
