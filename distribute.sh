#!/bin/bash

# By default use all available cores, override in config.conf if desired
if [ -f /proc/cpuinfo ]; then
  CORES=$(cat /proc/cpuinfo | grep processor | wc -l)
else
  # on MacOS there is no such file
  if hash sysctl 2>/dev/null; then
     CORES=$(sysctl -n hw.ncpu)
  else
     echo "Unable to determine number of cpu cores, using single core. Override this in config.conf"
     CORES=1
  fi
fi

# Load configuration
source `dirname $0`/config.conf

# Modules
MODULES=

# Resolve Python path
PYTHON="$(which python3)"
if [ "X$PYTHON" == "X" ]; then
    error "Unable to find python3"
    exit 1
fi

# Paths
ROOT_PATH="$(dirname $($PYTHON -c 'from __future__ import print_function; import os,sys;print(os.path.realpath(sys.argv[1]))' $0))"
ROOT_OUT_PATH="${ROOT_PATH}/../build-android"
STAGE_PATH="${ROOT_OUT_PATH}/stage/$ARCH"
RECIPES_PATH="$ROOT_PATH/recipes"
BUILD_PATH="${ROOT_OUT_PATH}/build"
LIBS_PATH="${ROOT_OUT_PATH}/build/libs"
PACKAGES_PATH="${PACKAGES_PATH:-$ROOT_OUT_PATH/.packages}"

# Tools
export LIBLINK_PATH="$BUILD_PATH/objects"
export LIBLINK="$ROOT_PATH/src/tools/liblink"

MD5SUM=$(which md5sum)
if [ "X$MD5SUM" == "X" ]; then
  MD5SUM=$(which md5)
  if [ "X$MD5SUM" == "X" ]; then
    error "you need at least md5sum or md5 installed."
    exit 1
  else
    MD5SUM="$MD5SUM -r"
  fi
fi

WGET=$(which wget)
if [ "X$WGET" == "X" ]; then
  WGET=$(which curl)
  if [ "X$WGET" == "X" ]; then
    error "you need at least wget or curl installed."
    exit 1
  else
    WGET="$WGET -L -o"
  fi
  WHEAD="curl -L -I"
else
  WGET="$WGET -O"
  WHEAD="wget --spider -q -S"
fi

case $OSTYPE in
  darwin*)
    SED="sed -i .orig"
    ;;
  *)
    SED="sed -i"
    ;;
esac


# Internals
CRED="\x1b[31;01m"
CBLUE="\x1b[34;01m"
CGRAY="\x1b[30;01m"
CRESET="\x1b[39;49;00m"
DO_CLEAN_BUILD=0
DO_SET_X=0

# Use ccache ?
which ccache &>/dev/null
if [ $? -eq 0 ]; then
  export CC="ccache gcc"
  export CXX="ccache g++"
  export NDK_CCACHE="ccache"
fi

function try () {
    "$@" || exit -1
}

function info() {
  echo -e "$CBLUE"$@"$CRESET";
}

function error() {
  echo -e "$CRED"$@"$CRESET";
}

function debug() {
  echo -e "$CGRAY"$@"$CRESET";
}

function get_directory() {
  case $1 in
    *.tar.gz) directory=$(basename $1 .tar.gz) ;;
    *.tar.xz) directory=$(basename $1 .tar.xz) ;;
    *.tgz)    directory=$(basename $1 .tgz) ;;
    *.tar.bz2)  directory=$(basename $1 .tar.bz2) ;;
    *.tbz2)   directory=$(basename $1 .tbz2) ;;
    *.zip)    directory=$(basename $1 .zip) ;;
    *)
      error "Unknown file extension $1"
      exit -1
      ;;
  esac
  echo $directory
}

function push_arm() {
  info "Entering in ${ARCH} environment"

  # save for pop
  export OLD_PATH=$PATH
  export OLD_CFLAGS=$CFLAGS
  export OLD_CXXFLAGS=$CXXFLAGS
  export OLD_LDFLAGS=$LDFLAGS
  export OLD_CC=$CC
  export OLD_CXX=$CXX
  export OLD_AR=$AR
  export OLD_RANLIB=$RANLIB
  export OLD_STRIP=$STRIP
  export OLD_MAKE=$MAKE
  export OLD_LD=$LD
  export OLD_CMAKECMD=$CMAKECMD
  export OLD_ANDROID_CMAKE_LINKER_FLAGS=$ANDROID_CMAKE_LINKER_FLAGS

  # this must be something depending of the API level of Android
  PYPLATFORM=$($PYTHON -c 'from __future__ import print_function; import sys; print(sys.platform)')
  if [ "$PYPLATFORM" == "linux2" ]; then
    PYPLATFORM="linux"
  elif [ "$PYPLATFORM" == "linux3" ]; then
    PYPLATFORM="linux"
  fi

  # Setup compiler toolchain based on CPU architecture
  if [ "X${ARCH}" == "Xx86" ]; then
      export TOOLCHAIN_FULL_PREFIX=i686-linux-android${ANDROIDAPI}
      export TOOLCHAIN_SHORT_PREFIX=i686-linux-android
      export TOOLCHAIN_PREFIX=i686-linux-android
      export TOOLCHAIN_BASEDIR=x86
      export QT_ARCH_PREFIX=x86
      export QT_ANDROID=${QT_ANDROID_BASE}/android_x86
      export ANDROID_SYSTEM=android
  elif [ "X${ARCH}" == "Xarmeabi-v7a" ]; then
      export TOOLCHAIN_FULL_PREFIX=armv7a-linux-androideabi${ANDROIDAPI}
      export TOOLCHAIN_SHORT_PREFIX=arm-linux-androideabi
      export TOOLCHAIN_PREFIX=arm-linux-androideabi
      export TOOLCHAIN_BASEDIR=arm-linux-androideabi
      export QT_ARCH_PREFIX=armv7
      export QT_ANDROID=${QT_ANDROID_BASE}/android_armv7
      export ANDROID_SYSTEM=android
  elif [ "X${ARCH}" == "Xarm64-v8a" ]; then
      export TOOLCHAIN_FULL_PREFIX=aarch64-linux-android${ANDROIDAPI}
      export TOOLCHAIN_SHORT_PREFIX=aarch64-linux-android
      export TOOLCHAIN_PREFIX=aarch64-linux-android
      export TOOLCHAIN_BASEDIR=aarch64-linux-android
      export QT_ARCH_PREFIX=arm64 # watch out when changing this, openssl depends on it
      export QT_ANDROID=${QT_ANDROID_BASE}/android_arm64_v8a
      export ANDROID_SYSTEM=android64
  else
      echo "Error: Please report issue to enable support for arch (${ARCH})."
      exit 1
  fi

  export CFLAGS="-DANDROID $OFLAG -fomit-frame-pointer --sysroot $NDKPLATFORM -I$STAGE_PATH/include"
  export CFLAGS="$CFLAGS -L$ANDROIDNDK/sources/cxx-stl/llvm-libc++/libs/$ARCH -isystem $ANDROIDNDK/sources/cxx-stl/llvm-libc++/include"
  export CFLAGS="$CFLAGS -isystem $ANDROIDNDK/sysroot/usr/include -isystem $ANDROIDNDK/sysroot/usr/include/$TOOLCHAIN_SHORT_PREFIX "
  export CFLAGS="$CFLAGS -D__ANDROID_API__=$ANDROIDAPI"

  export CXXFLAGS="$CFLAGS"
  export CPPFLAGS="$CFLAGS"

  export LDFLAGS="-lm -L$STAGE_PATH/lib"
  export LDFLAGS="$LDFLAGS -L$ANDROIDNDK/sources/cxx-stl/llvm-libc++/libs/$ARCH"
  export LDFLAGS="$LDFLAGS -L$ANDROIDNDK/toolchains/llvm/prebuilt/$PYPLATFORM-x86_64/sysroot/usr/lib/$TOOLCHAIN_PREFIX/$ANDROIDAPI"

  export ANDROID_CMAKE_LINKER_FLAGS=""
  if [ "X${ARCH}" == "Xarm64-v8a" ]; then
    ANDROID_CMAKE_LINKER_FLAGS="$ANDROID_CMAKE_LINKER_FLAGS;-Wl,-rpath=$ANDROIDNDK/platforms/android-$ANDROIDAPI/arch-$QT_ARCH_PREFIX/usr/lib"
    ANDROID_CMAKE_LINKER_FLAGS="$ANDROID_CMAKE_LINKER_FLAGS;-Wl,-rpath=$ANDROIDNDK/sources/cxx-stl/llvm-libc++/libs/$ARCH"
    ANDROID_CMAKE_LINKER_FLAGS="$ANDROID_CMAKE_LINKER_FLAGS;-Wl,-rpath=$STAGE_PATH/lib"
    ANDROID_CMAKE_LINKER_FLAGS="$ANDROID_CMAKE_LINKER_FLAGS;-Wl,-rpath=$QT_ANDROID/lib"
    ANDROID_CMAKE_LINKER_FLAGS="$ANDROID_CMAKE_LINKER_FLAGS;-Wl,-lz"
    export LDFLAGS="$LDFLAGS -Wl,-rpath=$STAGE_PATH/lib"
  fi
  export PATH="$ANDROIDNDK/toolchains/llvm/prebuilt/$PYPLATFORM-x86_64/bin/:$ANDROIDSDK/tools:$ANDROIDNDK:$QT_ANDROID/bin:$PATH"

  # search compiler in the path, to fail now instead of later.
  CC=$(which ${TOOLCHAIN_FULL_PREFIX}-clang)
  if [ "X$CC" == "X" ]; then
    error "Unable to find compiler ($TOOLCHAIN_FULL_PREFIX-clang) !!"
    error "1. Ensure that SDK/NDK paths are correct"
    error "2. Ensure that you've the Android API $ANDROIDAPI SDK Platform (via android tool)"
    exit 1
  else
    debug "Compiler found at $CC"
  fi

  export CC="$TOOLCHAIN_FULL_PREFIX-clang $CFLAGS"
  export CXX="$TOOLCHAIN_FULL_PREFIX-clang++ $CXXFLAGS"
  export AR="$TOOLCHAIN_SHORT_PREFIX-ar" 
  export RANLIB="$TOOLCHAIN_SHORT_PREFIX-ranlib"
  export LD="$TOOLCHAIN_SHORT_PREFIX-ld"
  export STRIP="$TOOLCHAIN_SHORT_PREFIX-strip --strip-unneeded"
  export MAKESMP="make -j$CORES"
  export MAKE="make"
  export READELF="$TOOLCHAIN_SHORT_PREFIX-readelf"
  export CMAKECMD="cmake"
  export CMAKECMD="$CMAKECMD -DANDROID_LINKER_FLAGS=$ANDROID_CMAKE_LINKER_FLAGS"
  export CMAKECMD="$CMAKECMD -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$ANDROIDNDK/build/cmake/android.toolchain.cmake"
  export CMAKECMD="$CMAKECMD -DCMAKE_FIND_ROOT_PATH:PATH=$ANDROID_NDK;$QT_ANDROID;$BUILD_PATH;$STAGE_PATH"
  export CMAKECMD="$CMAKECMD -DANDROID_ABI=$ARCH -DANDROID_NDK=$ANDROID_NDK -DANDROID_NATIVE_API_LEVEL=$ANDROIDAPI -DANDROID=ON"


  # export environment for Qt
  export ANDROID_NDK_ROOT=$ANDROIDNDK
  # and for cmake
  export ANDROID_NDK=$ANDROIDNDK

  # This will need to be updated to support Python versions other than 2.7
  export BUILDLIB_PATH="$BUILD_hostpython/build/lib.linux-`uname -m`-2.7/"

  # Use ccache ?
  which ccache &>/dev/null
  if [ $? -eq 0 ]; then
    export CC="ccache $CC"
    export CXX="ccache $CXX"
  fi
}

function pop_arm() {
  info "Leaving ${ARCH} environment"
  export PATH=$OLD_PATH
  export CFLAGS=$OLD_CFLAGS
  export CXXFLAGS=$OLD_CXXFLAGS
  export LDFLAGS=$OLD_LDFLAGS
  export CC=$OLD_CC
  export CXX=$OLD_CXX
  export AR=$OLD_AR
  export LD=$OLD_LD
  export RANLIB=$OLD_RANLIB
  export STRIP=$OLD_STRIP
  export MAKE=$OLD_MAKE
  export CMAKECMD=$OLD_CMAKECMD
  export ANDROID_CMAKE_LINKER_FLAGS=$OLD_ANDROID_CMAKE_LINKER_FLAGS
}

function usage() {
  echo "Python for android - distribute.sh"
  echo 
  echo "Usage:   ./distribute.sh [options]"
  echo
  echo "  -h                     Show this help"
  echo "  -l                     Show a list of available modules"
  echo "  -m 'mod1 mod2'         Modules to include"
  echo "  -f                     Restart from scratch (remove the current build)"
  echo "  -x                     display expanded values (execute 'set -x')"
  echo
  echo "For developers:"
  echo "  -u 'mod1 mod2'         Modules to update (if already compiled)"
  echo
  exit 0
}

# Check installation state of a debian package list.
# Return all missing packages.
function check_pkg_deb_installed() {
    PKGS=$1
    MISSING_PKGS=""
    for PKG in $PKGS; do
        CHECK=$(dpkg -s $PKG 2>&1)
        if [ $? -eq 1 ]; then
           MISSING_PKGS="$PKG $MISSING_PKGS"
        fi
    done
  if [ "X$MISSING_PKGS" != "X" ]; then
    error "Packages missing: $MISSING_PKGS"
    error "It might break the compilation, except if you installed thoses packages manually."
  fi
}

function check_build_deps() {
    # on MacOS there is no lsb_release command
    if hash lsb_release 2>/dev/null; then
        DIST=$(lsb_release -is)
        info "Check build dependencies for $DIST"
        case $DIST in
            Debian|Ubuntu|LinuxMint)
                check_pkg_deb_installed "build-essential zlib1g-dev cython"
            ;;
            *)
                debug "Avoid check build dependencies, unknown platform $DIST"
            ;;
        esac
    else
        debug "Avoid check build dependencies, unknown platform"
    fi
}

function run_prepare() {
  info "Check environment"
  if [ "X$ANDROIDSDK" == "X" ]; then
    error "No ANDROIDSDK environment set, abort"
    exit -1
  fi
  if [ ! -d "$ANDROIDSDK" ]; then
    echo "ANDROIDSDK=$ANDROIDSDK"
    error "ANDROIDSDK path is invalid, it must be a directory. abort."
    exit 1
  fi

  if [ "X$ANDROIDNDK" == "X" ]; then
    error "No ANDROIDNDK environment set, abort"
    exit -1
  fi
  if [ ! -d "$ANDROIDNDK" ]; then
    echo "ANDROIDNDK=$ANDROIDNDK"
    error "ANDROIDNDK path is invalid, it must be a directory. abort."
    exit 1
  fi

  if [ "X$ANDROIDAPI" == "X" ]; then
    export ANDROIDAPI=14
  fi

  if [ "X$MODULES" == "X" ]; then
    usage
    exit 0
  fi

  debug "SDK located at $ANDROIDSDK"
  debug "NDK located at $ANDROIDNDK"
  debug "NDK version is $ANDROIDNDKVER"
  debug "API level set to $ANDROIDAPI"
  if [ "X${ARCH}" == "Xx86" ]; then
      export SHORTARCH="x86"
  elif [ "X${ARCH}" == "Xarmeabi-v7a" ]; then
      export SHORTARCH="arm"
  elif [ "X${ARCH}" == "Xarm64-v8a" ]; then
      export SHORTARCH="arm64"
  else
      echo "Error: Please report issue to enable support for newer arch (${ARCH})."
      exit 1
  fi

  export NDKPLATFORM="$ANDROIDNDK/platforms/android-$ANDROIDAPI/arch-$SHORTARCH"

  info "Check mandatory tools"
  # ensure that some tools are existing
  for tool in tar bzip2 unzip make gcc g++; do
    which $tool &>/dev/null
    if [ $? -ne 0 ]; then
      error "Tool $tool is missing"
      exit -1
    fi
  done

  if [ $DO_CLEAN_BUILD -eq 1 ]; then
    info "Cleaning build"
    try rm -rf $STAGE_PATH
    try rm -rf $BUILD_PATH
    try rm -rf $SRC_PATH/obj
    try rm -rf $SRC_PATH/libs
  fi

  info "Distribution will be located at $STAGE_PATH"
  if [ -e "$STAGE_PATH" ]; then
    info "The directory $STAGE_PATH already exist"
    info "Will continue using and possibly overwrite what is in there"
  fi
  try mkdir -p "$STAGE_PATH"

  # create build directory if not found
  test -d $PACKAGES_PATH || mkdir -p $PACKAGES_PATH
  test -d $BUILD_PATH || mkdir -p $BUILD_PATH
  test -d $LIBS_PATH || mkdir -p $LIBS_PATH

  # check arm env
  push_arm
  debug "PATH is $PATH"
  pop_arm
}

function in_array() {
  term="$1"
  shift
  i=0
  for key in $@; do
    if [ $term == $key ]; then
      return $i
    fi
    i=$(($i + 1))
  done
  return 255
}

function run_source_modules() {
  # preprocess version modules
  needed=($MODULES)
  while [ ${#needed[*]} -ne 0 ]; do

    # pop module from the needed list
    module=${needed[0]}
    unset needed[0]
    needed=( ${needed[@]} )

    # is a version is specified ?
    items=( ${module//==/ } )
    module=${items[0]}
    version=${items[1]}
    if [ ! -z "$version" ]; then
      info "Specific version detected for $module: $version"
      eval "VERSION_$module=$version"
    fi
  done


  needed=($MODULES)
  declare -a processed
  declare -a pymodules
  processed=()

  fn_deps='.deps'
  fn_optional_deps='.optional-deps'

  > $fn_deps
  > $fn_optional_deps

  while [ ${#needed[*]} -ne 0 ]; do

    # pop module from the needed list
    module=${needed[0]}
    original_module=${needed[0]}
    unset needed[0]
    needed=( ${needed[@]} )

    # split the version if exist
    items=( ${module//==/ } )
    module=${items[0]}
    version=${items[1]}

    # check if the module have already been declared
    in_array $module "${processed[@]}"
    if [ $? -ne 255 ]; then
      debug "Ignored $module, already processed"
      continue;
    fi

    # add this module as done
    processed=( ${processed[@]} $module )

    # read recipe
    debug "Read $module recipe"
    recipe=$RECIPES_PATH/$module/recipe.sh
    if [ ! -f $recipe ]; then
      error "Recipe $module does not exist, adding the module as pure-python package"
      pymodules+=($original_module)
      continue;
    fi
    source $RECIPES_PATH/$module/recipe.sh

    # if a version has been specified by the user, the md5 will not
    # correspond at all. so deactivate it.
    if [ ! -z "$version" ]; then
      debug "Deactivate MD5 test for $module, due to specific version"
      eval "MD5_$module="
    fi

    # append current module deps to the needed
    deps=$(echo \$"{DEPS_$module[@]}")
    eval deps=($deps)
    optional_deps=$(echo \$"{DEPS_OPTIONAL_$module[@]}")
    eval optional_deps=($optional_deps)
    if [ ${#deps[*]} -gt 0 ]; then
      debug "Module $module depend on" ${deps[@]}
      needed=( ${needed[@]} ${deps[@]} )
      echo $module ${deps[@]} >> $fn_deps
    else
      echo $module >> $fn_deps
    fi
    if [ ${#optional_deps[*]} -gt 0 ]; then
      echo $module ${optional_deps[@]} >> $fn_optional_deps
    fi
  done

  info `pwd`
  MODULES="$($PYTHON tools/depsort.py --optional $fn_optional_deps < $fn_deps)"

  info "Modules changed to $MODULES"

  PYMODULES="${pymodules[@]}"

  info "Pure-Python modules changed to $PYMODULES"
}

function run_get_packages() {
  info "Run get packages"

  if [ ! -f "$ROOT_OUT_PATH/.packages/config.sub" ]; then
    $WGET $ROOT_OUT_PATH/.packages/config.sub "http://git.savannah.gnu.org/cgit/config.git/plain/config.sub"
    $WGET $ROOT_OUT_PATH/.packages/config.guess "http://git.savannah.gnu.org/cgit/config.git/plain/config.guess"
  fi

  for module in $MODULES; do
    # download dependencies for this module
    # check if there is not an overload from environment
    module_dir=$(eval "echo \$O4A_${module}_DIR")
    if [ "$module_dir" ]
    then
      debug "\$O4A_${module}_DIR is not empty, linking $module_dir dir instead of downloading"
      directory=$(eval "echo \$BUILD_${module}")
      if [ -e $directory ]; then
        try rm -rf "$directory"
      fi
      try mkdir -p "$directory"
      try rmdir "$directory"
      try ln -s "$module_dir" "$directory"
      continue
    fi
    debug "Download package for $module"

    url="URL_$module"
    url=${!url}
    md5="MD5_$module"
    md5=${!md5}

    if [ ! -d "$BUILD_PATH/$module" ]; then
      try mkdir -p $BUILD_PATH/$module
    fi

    if [ ! -d "$PACKAGES_PATH/$module" ]; then
      try mkdir -p "$PACKAGES_PATH/$module"
    fi

    if [ "X$url" == "X" ]; then
      debug "No package for $module"
      continue
    fi

    filename=$(basename $url)
    marker_filename=".mark-$filename"
    do_download=1

    cd "$PACKAGES_PATH/$module"

    # check if the file is already present
    if [ -f $filename ]; then
      # if the marker has not been set, it might be cause of a invalid download.
      if [ ! -f $marker_filename ]; then
        rm $filename
      elif [ -n "$md5" ]; then
        # check if the md5 is correct
        current_md5=$($MD5SUM $filename | cut -d\  -f1)
        if [ "X$current_md5" == "X$md5" ]; then
          # correct, no need to download
          do_download=0
        else
          # invalid download, remove the file
          error "Module $module have invalid md5, redownload."
          rm $filename
        fi
      else
        do_download=0
      fi
    fi

    # check if the file HEAD in case of, only if there is no MD5 to check.
    check_headers=0
    if [ -z "$md5" ]; then
      if [ "X$DO_CLEAN_BUILD" == "X1" ]; then
        check_headers=1
      elif [ ! -f $filename ]; then
        check_headers=1
      fi
    fi

    if [ "X$check_headers" == "X1" ]; then
      debug "Checking if $url changed"
      $WHEAD $url &> .headers-$filename
      $PYTHON "$ROOT_PATH/tools/check_headers.py" .headers-$filename .sig-$filename
      if [ $? -ne 0 ]; then
        do_download=1
      fi
    fi

    # download if needed
    if [ $do_download -eq 1 ]; then
      info "Downloading $url"
      try rm -f $marker_filename
      try $WGET $filename $url
      touch $marker_filename
    else
      debug "Module $module already downloaded"
    fi

    # check md5
    if [ -n "$md5" ]; then
      current_md5=$($MD5SUM $filename | cut -d\  -f1)
      if [ "X$current_md5" != "X$md5" ]; then
        error "File $filename md5 check failed (got $current_md5 instead of $md5)."
        error "Ensure the file is correctly downloaded, and update MD5S_$module"
        exit -1
      fi
    fi

    # if already decompress, forget it
    cd $BUILD_PATH/$module
    directory=$(get_directory $filename)
    if [ -d "$directory" ]; then
      continue
    fi

    # decompress
    pfilename=$PACKAGES_PATH/$module/$filename
    info "Extract $pfilename"
    case $pfilename in
      *.tar.gz|*.tgz )
        try tar xzf $pfilename
        root_directory=$(basename $(try tar tzf $pfilename|head -n1))
        if [ "X$root_directory" != "X$directory" ]; then
          mv $root_directory $directory
        fi
        ;;
      *.tar.bz2|*.tbz2 )
        try tar xjf $pfilename
        root_directory=$(basename $(try tar tjf $pfilename|head -n1))
        if [ "X$root_directory" != "X$directory" ]; then
          mv $root_directory $directory
        fi
        ;;
      *.zip )
        try unzip $pfilename
        root_directory=$(basename $(try unzip -l $pfilename|sed -n 5p|awk '{print $4}'))
        if [ "X$root_directory" != "X$directory" ]; then
          mv $root_directory $directory
        fi
        ;;
      * )
        try tar xf $pfilename
        root_directory=$(basename $(try tar xf $pfilename|head -n1))
        if [ "X$root_directory" != "X$directory" ]; then
          mv $root_directory $directory
        fi
        ;;
    esac
  done
}

function run_prebuild() {
  info "Run prebuild"
  cd $BUILD_PATH
  for module in $MODULES; do
    fn=$(echo prebuild_$module)
    debug "Call $fn"
    $fn
  done
}

function run_build() {
  info "Run build"

  modules_update=($MODULES_UPDATE)

  cd $BUILD_PATH

  for module in $MODULES; do
    fn="build_$module"
    shouldbuildfn="shouldbuild_$module"
    MARKER_FN="$BUILD_PATH/.mark-$module"

    # if the module should be updated, then remove the marker.
    in_array $module "${modules_update[@]}"
    if [ $? -ne 255 ]; then
      debug "$module detected to be updated"
      rm -f "$MARKER_FN"
    fi

    # if shouldbuild_$module exist, call it to see if the module want to be
    # built again
    DO_BUILD=1
    if [ "$(type -t $shouldbuildfn)" == "function" ]; then
      $shouldbuildfn
    fi

    # if the module should be build, or if the marker is not present,
    # do the build
    if [ "X$DO_BUILD" == "X1" ] || [ ! -f "$MARKER_FN" ]; then
      debug "Call $fn"
      rm -f "$MARKER_FN"
      $fn
      touch "$MARKER_FN"
    else
      debug "Skipped $fn"
    fi
  done
}

function run_postbuild() {
  info "Run postbuild"
  cd $BUILD_PATH
  for module in $MODULES; do
    fn=$(echo postbuild_$module)
    debug "Call $fn"
    $fn
  done
}


function run() {
  check_build_deps
  for ARCH in ${ARCHES[@]}; do
    cd ${ROOT_PATH}
    STAGE_PATH="${ROOT_OUT_PATH}/stage/$ARCH"
    run_prepare
    run_source_modules
    run_get_packages
    run_prebuild
    run_build
    run_postbuild
  done
  info "All done !"
}

function list_modules() {
  modules=$(find recipes -iname 'recipe.sh' | cut -d/ -f2 | sort -u | xargs echo)
  echo "Available modules: $modules"
  exit 0
}

# Do the build
while getopts ":hCvlfxim:a:u:d:s" opt; do
  case $opt in
    h)
      usage
      ;;
    l)
      list_modules
      ;;
    s)
      run_prepare
      run_source_modules
      push_arm
      bash
      pop_arm
      exit 0
      ;;
    a)
      LAYOUT="$OPTARG"
      ;;
    i)
      INSTALL=1
      ;;
    m)
      MODULES="$OPTARG"
      ;;
    u)
      MODULES_UPDATE="$OPTARG"
      ;;
    f)
      DO_CLEAN_BUILD=1
      ;;
    x)
      DO_SET_X=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;

    *)
      echo "=> $OPTARG"
      ;;
  esac
done

if [ $DO_SET_X -eq 1 ]; then
  info "Set -x for displaying expanded values"
  set -x
fi

run
