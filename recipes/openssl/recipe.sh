#!/bin/bash

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

  true
}

# function called to build the source code
function build_openssl() {
  try mkdir -p $BUILD_PATH/openssl/build-$ARCH
  try cd $BUILD_PATH/openssl/build-$ARCH

   ### SETUP ENVIROMENT

   push_arm
   ### SETUP ENV
   export _ANDROID_NDK_ROOT=$ANDROIDNDK
   export _ANDROID_NDK=$ANDROIDNDK
   export _ANDROID_EABI=$TOOLCHAIN_PREFIX-$TOOLCHAIN_VERSION
   export _ANDROID_ARCH=arch-$SHORTARCH
   export _ANDROID_API=android-$ANDROIDAPI
   export ANDROID_TOOLCHAIN=$ANDROIDNDK/toolchains/$TOOLCHAIN_BASEDIR-$TOOLCHAIN_VERSION/prebuilt/$PYPLATFORM-x86_64/bin
   export CROSS_COMPILE=$ANDROID_EABI-
   export ANDROID_DEV=$_ANDROID_NDK/platforms/android-$_ANDROID_API/$_ANDROID_ARCH/usr

   # CC is overwwriten to use ccache, but there is no $NDK_TOOLCHAIN_BASENAMEccache
   export CC=$NDK_TOOLCHAIN_BASENAMEgcc
   export AR=$NDK_TOOLCHAIN_BASENAMEar
   #export CXX=$NDK_TOOLCHAIN_BASENAMEg++
   #export LINK=${CXX}
   #export LD=$NDK_TOOLCHAIN_BASENAMEld
   #export RANLIB=$NDK_TOOLCHAIN_BASENAMEranlib
   #export STRIP=$NDK_TOOLCHAIN_BASENAMEstrip

   # SETENV ANDROID script
   #chmod a+x ./../../../recipes/openssl/Setenv-android.sh
   #bash ./../../../recipes/openssl/Setenv-android.sh

   #NOTE _ANDROID_ARCH is not matching any os/compiler for Configure list
   ./../openssl-${VERSION_openssl}/Configure shared  android-arm  -D__ANDROID_API__=$ANDROIDAPI
   #make clean
   make CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs

   ### RESET ENVIROMENT
   pop_arm
}

# function called after all the compile have been done
function postbuild_openssl() {
	true
}
