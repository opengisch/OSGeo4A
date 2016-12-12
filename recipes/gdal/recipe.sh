#!/bin/bash

# version of your package
VERSION_gdal=2.1.2

# dependencies of this recipe
DEPS_gdal=(iconv sqlite3 geos libtiff postgresql)

# url of the package
URL_gdal=http://download.osgeo.org/gdal/$VERSION_gdal/gdal-${VERSION_gdal}.tar.gz

# md5 of the package
MD5_gdal=bd283ff1f88dfe8d750dbc5ecb7c73a8

# default build path
BUILD_gdal=$BUILD_PATH/gdal/$(get_directory $URL_gdal)

# default recipe path
RECIPE_gdal=$RECIPES_PATH/gdal

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_gdal() {
  cd $BUILD_gdal

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_PATH/.packages/config.sub $BUILD_gdal
  try cp $ROOT_PATH/.packages/config.guess $BUILD_gdal
  try patch -p1 < $RECIPE_gdal/patches/gdal.patch
  # try patch -p1 < $RECIPE_gdal/patches/memdebug.patch

  touch .patched
}

function shouldbuild_gdal() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/gdal/build-$ARCH/.libs/libgdal.so -nt $BUILD_gdal/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_gdal() {
  try rsync -a $BUILD_gdal/ $BUILD_PATH/gdal/build-$ARCH/
  try cd $BUILD_PATH/gdal/build-$ARCH
	push_arm
  LIBS="-lgnustl_shared -lsupc++ -lstdc++" \
  LDFLAGS="${LDFLAGS} -L$ANDROIDNDK/sources/cxx-stl/gnu-libstdc++/$TOOLCHAIN_VERSION/libs/${ARCH}" \
    try ${BUILD_PATH}/gdal/build-$ARCH/configure \
    --prefix=$STAGE_PATH \
    --host=${TOOLCHAIN_PREFIX} \
    --with-sqlite3=$STAGE_PATH \
    --with-geos=$STAGE_PATH/bin/geos-config \
    --with-pg=no
  try make
  try make install &> install.log
	pop_arm
}

# function called after all the compile have been done
function postbuild_gdal() {
	true
}
