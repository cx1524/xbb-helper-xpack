# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Depends on gmp.
function build_isl()
{
  # http://isl.gforge.inria.fr - deprecated
  # https://sourceforge.net/projects/libisl/files/

  # https://github.com/archlinux/svntogit-packages/blob/packages/libisl/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/isl.rb

  # 2015-06-12 "0.15"
  # 2016-01-15 "0.16.1"
  # 2016-12-20 "0.18"
  # 2019-03-26 "0.21"
  # 2020-01-16 "0.22"
  # 2020-11-11 "0.23"
  # 2021-05-01 "0.24"
  # 2022-07-02 "0.25"

  local isl_version="$1"
  local name_suffix=${2-''}

  # The folder name as resulted after being extracted from the archive.
  local isl_src_folder_name="isl-${isl_version}"

  local isl_archive="${isl_src_folder_name}.tar.xz"
  if [[ ${isl_version} =~ 0\.1[24]\.* ]]
  then
    isl_archive="${isl_src_folder_name}.tar.gz"
  fi

  local isl_url="https://sourceforge.net/projects/libisl/files/${isl_archive}"

  # The folder name for build, licenses, etc.
  local isl_folder_name="${isl_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}"

  local isl_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${isl_folder_name}-installed"
  if [ ! -f "${isl_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${isl_url}" "${isl_archive}" \
      "${isl_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${isl_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${isl_folder_name}"

      if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
      then

        # Otherwise `configure: error: gmp.h header not found`.`
        CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"

      else

        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_LIB}"
        if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
        then
          xbb_activate_cxx_rpath
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        fi

      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running isl${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${isl_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_BUILD}")

          else

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

          fi

          config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${isl_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running isl${name_suffix} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            # /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x64/build/libs/isl-0.22/.libs/lt-isl_test_cpp: relocation error: /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x64/build/libs/isl-0.22/.libs/lt-isl_test_cpp: symbol _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm, version GLIBCXX_3.4.21 not defined in file libstdc++.so.6 with link time reference
            # FAIL isl_test_cpp (exit status: 127)
            # /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x32/build/libs/isl-0.22/.libs/lt-isl_test_cpp: relocation error: /Host/Users/ilg/Work/gcc-8.4.0-1/linux-x32/build/libs/isl-0.22/.libs/lt-isl_test_cpp: symbol _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERjj, version GLIBCXX_3.4.21 not defined in file libstdc++.so.6 with link time reference
            # FAIL isl_test_cpp (exit status: 127)
            # Similar for aarch64
            # FAIL: isl_test_cpp

            run_verbose make -j1 check || true
          else
            run_verbose make -j1 check
          fi
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${isl_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${isl_src_folder_name}" \
          "${isl_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${isl_stamp_file_path}"

  else
    echo "Library isl${name_suffix} already installed."
  fi
}

# -----------------------------------------------------------------------------

