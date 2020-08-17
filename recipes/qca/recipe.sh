#!/bin/bash

# version of your package

VERSION_qca=2.2.1

# dependencies of this recipe
DEPS_qca=(openssl zlib)

# url of the package
# URL_qca=http://delta.affinix.com/download/qca/2.0/qca-${VERSION_qca}.tar.gz
# URL_qca=http://quickgit.kde.org/?p=qca.git&a=snapshot&h=4f966b0217c10b6fd3c12caf7d2467759fbec7f7&fmt=tgz
URL_qca=https://github.com/KDE/qca/archive/v${VERSION_qca}.tar.gz
#URL_qca=https://github.com/KDE/qca/archive/32343842d359a60e3619f97aac983d587f6eca16.zip

# md5 of the package
MD5_qca=6116b6d0ad81d166edc26b14a1dbf39e

# default build path
BUILD_qca=$BUILD_PATH/qca/$(get_directory $URL_qca)

# default recipe path
RECIPE_qca=$RECIPES_PATH/qca

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qca() {
  cd $BUILD_qca
  # check marker
  if [ -f .patched ]; then
    return
  fi

  # UPSTREAM patch: https://phabricator.kde.org/D23289
  try patch -p1 < $RECIPE_qca/patches/no_setuid.patch

  touch .patched
}

function shouldbuild_qca() {
 # If lib is newer than the sourcecode skip build
 if [ $BUILD_qca/build-$ARCH/lib/libqca-qt5.so -nt $BUILD_qca/.patched ]; then
  DO_BUILD=0
 fi
}

# function called to build the source code
function build_qca() {
 try mkdir -p $BUILD_qca/build-$ARCH
 try cd $BUILD_qca/build-$ARCH

 push_arm

 # configure
 try $CMAKECMD \
  -DQT4_BUILD=OFF \
  -DQCA_SUFFIX=qt5 \
  -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
  -DBUILD_TESTS=OFF \
  -DBUILD_TOOLS=OFF \
  -DWITH_nss_PLUGIN=OFF \
  -DWITH_pkcs11_PLUGIN=OFF \
  -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE \
  $BUILD_qca

 try $MAKESMP install

 pop_arm
}

# function called after all the compile have been done
function postbuild_qca() {
	true
}
