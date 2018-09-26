#!/bin/bash

# NOTES
# 1) The SYS_getrandom is disabled by patch, look at openssl FAQ about random function
# 2) Built without threading support
 
# version of your package
VERSION_openssl=1.1.1

# dependencies of this recipe
DEPS_openssl=()

# url of the package
URL_openssl=https://www.openssl.org/source/openssl-${VERSION_openssl}.tar.gz


# default recipe path
RECIPE_openssl=$RECIPES_PATH/openssl

# default build path
BUILD_openssl=$BUILD_PATH/openssl/$(get_directory $URL_openssl)

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_openssl() {
  echo "patching $BUILD_PATH/openssl/openssl-${VERSION_openssl}/config"
  try sed -i 's/android-armeabi/android-arm/g' $BUILD_PATH/openssl/openssl-${VERSION_openssl}/config
  
  # ad random seed & patch of rand_unix.c: https://mta.openssl.org/pipermail/openssl-users/2018-September/008860.html 
  try patch -p1 $BUILD_PATH/openssl/openssl-${VERSION_openssl}/crypto/rand/rand_unix.c $RECIPE_openssl/patches/rand_unix.patch

  touch .patched
}

function shouldbuild_openssl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_openssl/build-$ARCH/libssl.so -nt $BUILD_openssl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_openssl() {
  try mkdir -p $BUILD_PATH/openssl/build-$ARCH
  try cd $BUILD_PATH/openssl/build-$ARCH

  push_arm

  # https://wiki.openssl.org/index.php/Android
  export _ANDROID_ARCH=arch-$SHORTARCH
  export _ANDROID_EABI=$TOOLCHAIN_PREFIX-$TOOLCHAIN_VERSION
  export _ANDROID_NDK=$ANDROIDNDK
  export _ANDROID_NDK_ROOT=$ANDROIDNDK
  export ANDROID_SDK_ROOT=$ANDROIDSDK
  export _ANDROID_API=android-$ANDROIDAPI

  export MACHINE=${ARCH}
  export RELEASE=2.6.37
  export SYSTEM=android
  # export ARCH is exported in distribute.sh

  export CROSS_COMPILE=$ANDROID_EABI-
  export ANDROID_DEV=$_ANDROID_NDK/platforms/android-$_ANDROID_API/$_ANDROID_ARCH/usr
  export HOSTCC=gcc

  export ANDROID_TOOLCHAIN=$ANDROIDNDK/toolchains/$TOOLCHAIN_BASEDIR-$TOOLCHAIN_VERSION/prebuilt/$PYPLATFORM-x86_64/bin
     
  # tools are prefixed in config
  export CC=$NDK_TOOLCHAIN_BASENAMEgcc
  export AR=$NDK_TOOLCHAIN_BASENAMEar
  export CXX=$NDK_TOOLCHAIN_BASENAMEg++
  export LINK=${CXX}
  export LD=$NDK_TOOLCHAIN_BASENAMEld
  export RANLIB=$NDK_TOOLCHAIN_BASENAMEranlib
  export STRIP=$NDK_TOOLCHAIN_BASENAMEstrip
  
  # sysroot confuses the config command
  CFLAGS_WITHOUT_QUOTES=$(eval echo $CFLAGS)
  CFLAGS_WITHOUT_SYSROOT=${CFLAGS_WITHOUT_QUOTES//"--sysroot $NDKPLATFORM"/}

  # no-threads: build falling on ./libcrypto.so: error: undefined reference to 'pthread_atfork'
  ./../openssl-${VERSION_openssl}/config no-threads shared no-comp no-hw no-engine --openssldir=/usr/local/ssl/$ANDROIDAPI/ -D__ANDROID_API__=$ANDROIDAPI --prefix=/  $(eval echo $CFLAGS_WITHOUT_SYSROOT)
    
  ${MAKESMP} depend
  ${MAKESMP} CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs

  # install
  try ${MAKE} DESTDIR=$STAGE_PATH install
    
  pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
  true
}
