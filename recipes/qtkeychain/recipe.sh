#!/bin/bash

# version of your package
VERSION_qtkeychain=0.8.0

# dependencies of this recipe
DEPS_qtkeychain=()

# url of the package
#URL_qtkeychain=https://github.com/frankosterfeld/qtkeychain/archive/v${VERSION_qtkeychain}.tar.gz
URL_qtkeychain=https://github.com/hasselmm/qtkeychain/archive/androidkeystore.tar.gz

# md5 of the package
MD5_qtkeychain=8ac371cb68aad1582e7b8e7b0b4530cd

# default build path
BUILD_qtkeychain=$BUILD_PATH/qtkeychain/$(get_directory $URL_qtkeychain)

# default recipe path
RECIPE_qtkeychain=$RECIPES_PATH/qtkeychain

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qtkeychain() {
  cd $BUILD_qtkeychain
  # check marker
  if [ -f .patched ]; then
    return
  fi

  try patch --verbose --forward -p1 < $RECIPE_qtkeychain/patches/qtkeychain_qio.patch
  try patch --verbose --forward -p1 < $RECIPE_qtkeychain/patches/qtkeychain_console.patch
  try patch --verbose --forward -p1 < $RECIPE_qtkeychain/patches/cxx11.patch

  touch .patched
}

function shouldbuild_qtkeychain() {
 # If lib is newer than the sourcecode skip build
 if [ $BUILD_qtkeychain/build-$ARCH/libqtkeychain2.so -nt $BUILD_qtkeychain/.patched ]; then
  DO_BUILD=0
 fi
}

# function called to build the source code
function build_qtkeychain() {
 try mkdir -p $BUILD_qtkeychain/build-$ARCH
 try cd $BUILD_qtkeychain/build-$ARCH

	push_arm

 # configure
 try cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/tools/android.toolchain.cmake \
  -DANDROID_ABI=$ARCH \
  -DANDROID_NDK=$ANDROID_NDK \
  -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI \
  -DQT4_BUILD=OFF \
  -DQCA_SUFFIX=qt5 \
  -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
  -DBUILD_TESTS=OFF \
  -DBUILD_TOOLS=OFF \
  -DWITH_nss_PLUGIN=OFF \
  -DWITH_pkcs11_PLUGIN=OFF \
  $BUILD_qtkeychain
 # try $MAKESMP
 try $MAKESMP install

	pop_arm
}

# function called after all the compile have been done
function postbuild_qtkeychain() {
	true
}


# -DBUILD_PLUGINS=auto
# -DBUILD_SHARED_LIBS=ON
# -DBUILD_TESTS=ON
# -DBUILD_TOOLS=ON
# -DCMAKE_BUILD_TYPE=Release
# -DCMAKE_INSTALL_PREFIX=/usr/local
# -DDEVELOPER_MODE=OFF
# -DPKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config \
# -DPKGCONFIG_INSTALL_PREFIX=/usr/lib/x86_64-linux-gnu/pkgconfig
# -DQCA_BINARY_INSTALL_DIR=/usr/lib/x86_64-linux-gnu/qt5/bin
# -DQCA_DOC_INSTALL_DIR=/usr/share/qt5/doc/html/qtkeychain
# -DQCA_FEATURE_INSTALL_DIR=/usr/lib/x86_64-linux-gnu/qt5/mkspecs/features
# -DQCA_INCLUDE_INSTALL_DIR=/usr/include/x86_64-linux-gnu/qt5
# -DQCA_LIBRARY_INSTALL_DIR=/usr/lib/x86_64-linux-gnu
# -DQCA_MAN_INSTALL_DIR=/usr/share/qt5/man
# -DQCA_PLUGINS_INSTALL_DIR=/usr/lib/x86_64-linux-gnu/qt5/plugins
# -DQCA_PREFIX_INSTALL_DIR=/usr
# -DQCA_PRIVATE_INCLUDE_INSTALL_DI=/usr/include/x86_64-linux-gnu/qt5
# -DQCA_SUFFIX
# -DQT4_BUILD=OFF
# -DUSE_RELATIVE_PATHS=OFF
# -DWITH_botan_PLUGIN
# -DWITH_cyrus-sasl_PLUGIN
# -DWITH_gcrypt_PLUGIN
# -DWITH_gnupg_PLUGIN
# -DWITH_logger_PLUGIN
# -DWITH_nss_PLUGIN
# -DWITH_ossl_PLUGIN
# -DWITH_pkcs11_PLUGIN
# -DWITH_softstore_PLUGIN
