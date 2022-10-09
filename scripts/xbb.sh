#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2022 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function xbb_set_env()
{
  # Defaults, to ensure the variables are defined.
  PATH="${PATH:-""}"
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-""}"

  # Set the actual to the requested. This is useful in case the target was
  # temporarily changed for native builds.
  TARGET_PLATFORM="${REQUESTED_TARGET_PLATFORM}"
  TARGET_ARCH="${REQUESTED_TARGET_ARCH}"
  TARGET_BITS="${REQUESTED_TARGET_BITS}"
  TARGET_MACHINE="${REQUESTED_TARGET_MACHINE}"

  DASH_V=""
  if [ "${IS_DEVELOP}" == "y" ]
  then
    DASH_V="-v"
  fi

  CI="false"

  DOT_EXE=""
  # Compute the BUILD/HOST/TARGET for configure.
  XBB_CROSS_COMPILE_PREFIX=""
  if [ "${REQUESTED_TARGET_PLATFORM}" == "win32" ]
  then

    # Disable tests when cross compiling for Windows.
    WITH_TESTS="n"

    DOT_EXE=".exe"

    SHLIB_EXT="dll"

    # Use the 64-bit mingw-w64 gcc to compile Windows binaries.
    XBB_CROSS_COMPILE_PREFIX="x86_64-w64-mingw32"

    XBB_BUILD=$(xbb_config_guess)
    XBB_HOST="${XBB_CROSS_COMPILE_PREFIX}"
    XBB_TARGET="${XBB_HOST}"

  elif [ "${REQUESTED_TARGET_PLATFORM}" == "linux" ]
  then

    SHLIB_EXT="so"

    XBB_BUILD=$(xbb_config_guess)
    XBB_HOST="${XBB_BUILD}"
    XBB_TARGET="${XBB_HOST}"

  elif [ "${REQUESTED_TARGET_PLATFORM}" == "darwin" ]
  then

    SHLIB_EXT="dylib"

    XBB_BUILD=$(xbb_config_guess)
    XBB_HOST="${XBB_BUILD}"
    XBB_TARGET="${XBB_HOST}"

  else
    echo "Unsupported REQUESTED_TARGET_PLATFORM=${REQUESTED_TARGET_PLATFORM}."
    exit 1
  fi

  # ---------------------------------------------------------------------------

  RELEASE_VERSION="${RELEASE_VERSION:-$(xbb_get_current_version)}"

  TARGET_FOLDER_NAME="${TARGET_PLATFORM}-${TARGET_ARCH}"

  # Decide where to run the build for the requested target.
  if [ ! -z ${WORK_FOLDER_PATH+x} ]
  then
    # If the work folder is defined in the environent
    # (usually something like "${HOME}/Work")
    # group all targets below a versioned application folder.
    TARGET_WORK_FOLDER_PATH="${WORK_FOLDER_PATH}/${APP_LC_NAME}-${RELEASE_VERSION}/${TARGET_FOLDER_NAME}"
  elif [ ! -z "${REQUESTED_BUILD_RELATIVE_FOLDER}" ]
  then
    # If the user provides an explicit relative folder, use it.
    TARGET_WORK_FOLDER_PATH="${project_folder_path}/${REQUESTED_BUILD_RELATIVE_FOLDER}"
  else
    # The default is inside the project build folder.
    TARGET_WORK_FOLDER_PATH="${project_folder_path}/build/${TARGET_FOLDER_NAME}"
  fi
  BUILD_GIT_PATH="${project_folder_path}"

  DOWNLOAD_FOLDER_PATH="${DOWNLOAD_FOLDER_PATH:-"${HOME}/Work/cache"}"

  SOURCES_FOLDER_NAME="${SOURCES_FOLDER_NAME:-sources}"
  SOURCES_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${SOURCES_FOLDER_NAME}"
  mkdir -pv "${SOURCES_FOLDER_PATH}"

  BUILD_FOLDER_NAME="${BUILD_FOLDER_NAME-build}"
  BUILD_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${BUILD_FOLDER_NAME}"
  mkdir -pv "${BUILD_FOLDER_PATH}"

  INSTALL_FOLDER_NAME="${INSTALL_FOLDER_NAME:-install}"
  INSTALL_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${INSTALL_FOLDER_NAME}"

  DEPENDENCIES_INSTALL_FOLDER_PATH="${INSTALL_FOLDER_PATH}/dependencies"
  mkdir -pv "${DEPENDENCIES_INSTALL_FOLDER_PATH}"
  APPLICATION_INSTALL_FOLDER_PATH="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"
  mkdir -pv "${APPLICATION_INSTALL_FOLDER_PATH}"

  APPLICATION_DOC_INSTALL_FOLDER_PATH="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}/share/doc"

  # Deprecated!
  # APP_PREFIX="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"
  # The documentation location is now the same on all platforms.
  # APP_PREFIX_DOC="${APP_PREFIX}/share/doc"

  STAMPS_FOLDER_NAME="${STAMPS_FOLDER_NAME:-stamps}"
  STAMPS_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${STAMPS_FOLDER_NAME}"
  mkdir -pv "${STAMPS_FOLDER_PATH}"

  LOGS_FOLDER_NAME="${LOGS_FOLDER_NAME:-logs}"
  LOGS_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${LOGS_FOLDER_NAME}"
  mkdir -pv "${LOGS_FOLDER_PATH}"

  DEPLOY_FOLDER_NAME="${DEPLOY_FOLDER_NAME:-deploy}"
  # DEPLOY_FOLDER_PATH="${PROJECT_WORK_FOLDER_PATH}/${DEPLOY_FOLDER_NAME}"
  DEPLOY_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${DEPLOY_FOLDER_NAME}"
  mkdir -pv "${DEPLOY_FOLDER_PATH}"

  TESTS_FOLDER_NAME="${TESTS_FOLDER_NAME:-tests}"
  TESTS_FOLDER_PATH="${TARGET_WORK_FOLDER_PATH}/${TESTS_FOLDER_NAME}"
  # Created if needed.

  DISTRO_INFO_NAME=${DISTRO_INFO_NAME:-"distro-info"}

  if [ ! -z "$(which pkg-config-verbose)" -a "${IS_DEVELOP}" == "y" ]
  then
    PKG_CONFIG="$(which pkg-config-verbose)"
  elif [ ! -z "$(which pkg-config)" ]
  then
    PKG_CONFIG="$(which pkg-config)"
  fi

  # Hopefully defining it empty would be enough...
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-""}

  # Prevent pkg-config to search the system folders (configured in the
  # pkg-config at build time).
  PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-""}

  # libtool fails with the old Ubuntu /bin/sh.
  # export SHELL="/bin/bash"
  # export CONFIG_SHELL="/bin/bash"

  export PATH
  export LD_LIBRARY_PATH

  export CI
  export DOT_V
  export DOT_EXE
  export SHLIB_EXT

  export TARGET_PLATFORM
  export TARGET_ARCH
  export TARGET_BITS
  export TARGET_MACHINE

  export XBB_BUILD
  export XBB_HOST
  export XBB_TARGET

  export TARGET_WORK_FOLDER_PATH
  export DOWNLOAD_FOLDER_PATH
  export SOURCES_FOLDER_PATH
  export BUILD_FOLDER_PATH
  export INSTALL_FOLDER_PATH
  export DEPENDENCIES_INSTALL_FOLDER_PATH
  export APPLICATION_INSTALL_FOLDER_PATH
  export STAMPS_FOLDER_PATH
  export DEPLOY_FOLDER_PATH
  export TESTS_FOLDER_PATH

  export BUILD_GIT_PATH
  export DISTRO_INFO_NAME

  export PKG_CONFIG
  export PKG_CONFIG_PATH
  export PKG_CONFIG_LIBDIR

  # ---------------------------------------------------------------------------

  echo
  echo "XBB environment..."
  env | sort
}

function xbb_config_guess()
{
  echo "$(bash ${helper_folder_path}/config/config.guess)"
}

function xbb_get_current_version()
{
  local version_file_path="${scripts_folder_path}/VERSION"
  if [ $# -ge 1 ]
  then
    version_file_path="$1"
  fi

  # Extract only the first line
  cat "${version_file_path}" | sed -e '2,$d'
}

function xbb_set_compiler_env()
{
  if [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    xbb_prepare_clang_env
  elif [ "${TARGET_PLATFORM}" == "linux" ]
  then
    xbb_prepare_gcc_env
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    export NATIVE_CC="gcc"
    export NATIVE_CXX="g++"

    xbb_prepare_gcc_env "${XBB_CROSS_COMPILE_PREFIX}-"
  else
    echo "Unsupported TARGET_PLATFORM=${TARGET_PLATFORM}."
    exit 1
  fi

  echo

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    (
      set +e
      which ${NATIVE_CXX} || true
      ${NATIVE_CXX} --version || true
    )
  fi

  which ${CXX}
  ${CXX} --version

  which make
  make --version
}

function xbb_unset_compiler_env()
{
  unset CC
  unset CXX
  unset AR
  unset AS
  unset DLLTOOL
  unset LD
  unset NM
  unset OBJCOPY
  unset OBJDUMP
  unset RANLIB
  unset READELF
  unset SIZE
  unset STRIP
  unset WINDRES
  unset WINDMC
  unset RC

  unset XBB_CPPFLAGS

  unset XBB_CFLAGS
  unset XBB_CXXFLAGS

  unset XBB_CFLAGS_NO_W
  unset XBB_CXXFLAGS_NO_W

  unset XBB_LDFLAGS
  unset XBB_LDFLAGS_LIB
  unset XBB_LDFLAGS_APP
  unset XBB_LDFLAGS_APP_STATIC_GCC
}

function xbb_prepare_gcc_env()
{
  local prefix="${1:-}"
  local suffix="${2:-}"

  echo_develop "[xbb_prepare_gcc_env]"

  xbb_unset_compiler_env

  export CC="${prefix}gcc${suffix}"
  export CXX="${prefix}g++${suffix}"

  # These are the special GCC versions, not the binutils ones.
  export AR="${prefix}gcc-ar${suffix}"
  export NM="${prefix}gcc-nm${suffix}"
  export RANLIB="${prefix}gcc-ranlib${suffix}"

  # From binutils.
  export AS="${prefix}as"
  export DLLTOOL="${prefix}dlltool"
  export LD="${prefix}ld"
  export OBJCOPY="${prefix}objcopy"
  export OBJDUMP="${prefix}objdump"
  export READELF="${prefix}readelf"
  export SIZE="${prefix}size"
  export STRIP="${prefix}strip"
  export WINDRES="${prefix}windres"
  export WINDMC="${prefix}windmc"
  export RC="${prefix}windres"

  xbb_set_compiler_flags
}

function xbb_prepare_clang_env()
{
  local prefix="${1:-}"
  local suffix="${2:-}"

  echo_develop "[xbb_prepare_clang_env]"

  xbb_unset_compiler_env

  export CC="${prefix}clang${suffix}"
  export CXX="${prefix}clang++${suffix}"

  export AR="${prefix}ar"
  export AS="${prefix}as"
  # export DLLTOOL="${prefix}dlltool"
  export LD="${prefix}ld"
  export NM="${prefix}nm"
  # export OBJCOPY="${prefix}objcopy"
  export OBJDUMP="${prefix}objdump"
  export RANLIB="${prefix}ranlib"
  # export READELF="${prefix}readelf"
  export SIZE="${prefix}size"
  export STRIP="${prefix}strip"
  # export WINDRES="${prefix}windres"
  # export WINDMC="${prefix}windmc"
  # export RC="${prefix}windres"

  xbb_set_compiler_flags
}

function xbb_set_compiler_flags()
{
  XBB_CPPFLAGS=""

  XBB_CFLAGS="-ffunction-sections -fdata-sections -pipe"
  XBB_CXXFLAGS="-ffunction-sections -fdata-sections -pipe"

  if [ "${TARGET_ARCH}" == "x64" -o "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
  then
    XBB_CFLAGS+=" -m${TARGET_BITS}"
    XBB_CXXFLAGS+=" -m${TARGET_BITS}"
  fi

  XBB_LDFLAGS=""

  if [ "${IS_DEBUG}" == "y" ]
  then
    XBB_CFLAGS+=" -g -O0"
    XBB_CXXFLAGS+=" -g -O0"
    XBB_LDFLAGS+=" -g -O0"
  else
    XBB_CFLAGS+=" -O2"
    XBB_CXXFLAGS+=" -O2"
    XBB_LDFLAGS+=" -O2"
  fi

  if [ "${IS_DEVELOP}" == "y" ]
  then
    XBB_LDFLAGS+=" -v"
  fi

  if [ "${TARGET_PLATFORM}" == "linux" ]
  then
    # Do not add -static here, it fails.
    # Do not try to link pthread statically, it must match the system glibc.
    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libgcc -static-libstdc++"
  elif [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    if [ "${TARGET_ARCH}" == "x64" ]
    then
      export MACOSX_DEPLOYMENT_TARGET="10.13"
    elif [ "${TARGET_ARCH}" == "arm64" ]
    then
      export MACOSX_DEPLOYMENT_TARGET="11.0"
    else
      echo "Unknown TARGET_ARCH ${TARGET_ARCH}"
      exit 1
    fi

    if [[ ${CC} =~ .*clang.* ]]
    then
      XBB_CFLAGS+=" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
      XBB_CXXFLAGS+=" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    fi

    # Note: macOS linker ignores -static-libstdc++, so
    # libstdc++.6.dylib should be handled.
    XBB_LDFLAGS+=" -Wl,-macosx_version_min,${MACOSX_DEPLOYMENT_TARGET}"

    # With GCC 11.2 path are longer, and post-processing may fail:
    # error: /Library/Developer/CommandLineTools/usr/bin/install_name_tool: changing install names or rpaths can't be redone for: /Users/ilg/Work/gcc-11.2.0-2/darwin-x64/install/gcc/libexec/gcc/x86_64-apple-darwin17.7.0/11.2.0/g++-mapper-server (for architecture x86_64) because larger updated load commands do not fit (the program must be relinked, and you may need to use -headerpad or -headerpad_max_install_names)
    XBB_LDFLAGS+=" -Wl,-headerpad_max_install_names"

    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,-dead_strip"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libstdc++"
    if [[ ${CC} =~ .*gcc.* ]]
    then
      XBB_LDFLAGS_APP_STATIC_GCC+=" -static-libgcc"
    fi
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then

    # Note: use this explcitly in the application.
    # prepare_gcc_env "${CROSS_COMPILE_PREFIX}-"

    # To make `access()` not fail when passing a non-zero mode.
    # https://sourceforge.net/p/mingw-w64/mailman/message/37372220/
    # Do not add it to XBB_CPPFLAGS, since the current macro
    # crashes C++ code, like in `llvm/lib/Support/LockFileManager.cpp`:
    # `if (sys::fs::access(LockFileName.c_str(), sys::fs::AccessMode::Exist) ==`
    XBB_CFLAGS+=" -D__USE_MINGW_ACCESS"

    # llvm fails. Enable it only when needed.
    if false
    then
      # To prevent "too many sections", "File too big" etc.
      # Unfortunately some builds fail, so it must be used explictly.
      # TODO: check if the RISC-V toolchain no longer fails.
      XBB_CFLAGS+=" -Wa,-mbig-obj"
      XBB_CXXFLAGS+=" -Wa,-mbig-obj"
    fi

    # CRT_glob is from Arm script
    # -static avoids libwinpthread-1.dll
    # -static-libgcc avoids libgcc_s_sjlj-1.dll
    XBB_LDFLAGS_LIB="${XBB_LDFLAGS}"
    XBB_LDFLAGS_APP="${XBB_LDFLAGS} -Wl,--gc-sections"
    XBB_LDFLAGS_APP_STATIC_GCC="${XBB_LDFLAGS_APP} -static-libgcc -static-libstdc++"
  else
    echo "Unsupported TARGET_PLATFORM=${TARGET_PLATFORM}."
    exit 1
  fi

  XBB_CFLAGS_NO_W="${XBB_CFLAGS} -w"
  XBB_CXXFLAGS_NO_W="${XBB_CXXFLAGS} -w"

  set +u
  echo
  echo "CC=${CC}"
  echo "CXX=${CXX}"
  echo "XBB_CPPFLAGS=${XBB_CPPFLAGS}"
  echo "XBB_CFLAGS=${XBB_CFLAGS}"
  echo "XBB_CXXFLAGS=${XBB_CXXFLAGS}"

  echo "XBB_LDFLAGS_LIB=${XBB_LDFLAGS_LIB}"
  echo "XBB_LDFLAGS_APP=${XBB_LDFLAGS_APP}"
  echo "XBB_LDFLAGS_APP_STATIC_GCC=${XBB_LDFLAGS_APP_STATIC_GCC}"
  set -u

  # ---------------------------------------------------------------------------

  # CC & co were exported by prepare_gcc_env.
  export XBB_CPPFLAGS

  export XBB_CFLAGS
  export XBB_CXXFLAGS

  export XBB_CFLAGS_NO_W
  export XBB_CXXFLAGS_NO_W

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC_GCC
}

function xbb_set_binaries_install()
{
  export BINARIES_INSTALL_FOLDER_PATH="$1"
}

function xbb_set_libraries_install()
{
  export LIBRARIES_INSTALL_FOLDER_PATH="$1"
}

# Add the freshly built binaries.
function xbb_activate_installed_bin()
{
  echo "xbb_activate_installed_bin"

  # Add the XBB bin to the PATH.
  if [ ! -z ${DEPENDENCIES_INSTALL_FOLDER_PATH+x} ]
  then
    # When invoked from tests, the libs are not available.
    PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}/bin:${PATH}"
  fi

  if [ ! -z ${APPLICATION_INSTALL_FOLDER_PATH+x} ]
  then
    PATH="${APPLICATION_INSTALL_FOLDER_PATH}/bin:${APPLICATION_INSTALL_FOLDER_PATH}/usr/bin:${PATH}"
  fi

  if [ ! -z ${TEST_BIN_PATH+x} ]
  then
    PATH="${TEST_BIN_PATH}:${PATH}"
  fi

  export PATH
}

# Add the freshly built headers and libraries.
function xbb_activate_installed_dev()
{
  local name_suffix=${1-''}

  echo "xbb_activate_installed_dev${name_suffix}"

  # Add XBB include in front of XBB_CPPFLAGS.
  XBB_CPPFLAGS="-I${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/include ${XBB_CPPFLAGS}"

  if [ -d "${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib" ]
  then
    # Add XBB lib in front of XBB_LDFLAGS.
    XBB_LDFLAGS="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS}"
    XBB_LDFLAGS_LIB="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib ${XBB_LDFLAGS_APP_STATIC_GCC}"

    # Add XBB lib in front of PKG_CONFIG_PATH.
    PKG_CONFIG_PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib/pkgconfig:${PKG_CONFIG_PATH}"

    # Needed by internal binaries, like the bootstrap compiler, which do not
    # have a rpath.
    if [ -z "${LD_LIBRARY_PATH}" ]
    then
      LD_LIBRARY_PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib"
    else
      LD_LIBRARY_PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib:${LD_LIBRARY_PATH}"
    fi
  fi

  # Used by libffi, for example.
  if [ -d "${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64" ]
  then
    # For 64-bit systems, add XBB lib64 in front of paths.
    XBB_LDFLAGS="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_LIB="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_LIB}"
    XBB_LDFLAGS_APP="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_APP}"
    XBB_LDFLAGS_APP_STATIC_GCC="-L${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64 ${XBB_LDFLAGS_APP_STATIC_GCC}"

    PKG_CONFIG_PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64/pkgconfig:${PKG_CONFIG_PATH}"

    if [ -z "${LD_LIBRARY_PATH}" ]
    then
      LD_LIBRARY_PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64"
    else
      LD_LIBRARY_PATH="${DEPENDENCIES_INSTALL_FOLDER_PATH}${name_suffix}/lib64:${LD_LIBRARY_PATH}"
    fi
  fi

  export XBB_CPPFLAGS

  export XBB_LDFLAGS
  export XBB_LDFLAGS_LIB
  export XBB_LDFLAGS_APP
  export XBB_LDFLAGS_APP_STATIC_GCC

  export PKG_CONFIG_PATH
  export LD_LIBRARY_PATH

  if [ "${IS_DEVELOP}" == "y" ]
  then
    echo
    env | sort
  fi
}

function xbb_activate_cxx_rpath()
{
  local cxx_lib_path=""

  if [[ ${CC} =~ .*gcc.* ]]
  then
    cxx_lib_path="$(realpath $(dirname $(${CXX} -print-file-name=libstdc++.so.6)))"
    if [ "${cxx_lib_path}" == "libstdc++.so.6" ]
    then
      return
    fi
  fi

  if [ -z "${cxx_lib_path}" ]
  then
    return
  fi

  if [ -z "${LD_LIBRARY_PATH}" ]
  then
    LD_LIBRARY_PATH="${cxx_lib_path}"
  else
    LD_LIBRARY_PATH="${cxx_lib_path}:${LD_LIBRARY_PATH}"
  fi

  export LD_LIBRARY_PATH
}

# -----------------------------------------------------------------------------
