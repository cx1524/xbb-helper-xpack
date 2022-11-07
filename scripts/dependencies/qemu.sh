# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Environment variables:
# XBB_QEMU_GIT_URL
# XBB_QEMU_GIT_BRANCH
# XBB_QEMU_GIT_COMMIT

function build_qemu()
{
  # Stick to upstream as long as possible.
  # https://github.com/qemu/qemu/tags

  # The second choice is the xPack fork.
  # https://github.com/xpack-dev-tools/qemu

  # https://github.com/archlinux/svntogit-packages/blob/packages/qemu/trunk/PKGBUILD
  # https://github.com/archlinux/svntogit-community/blob/packages/libvirt/trunk/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/qemu.rb

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-qemu/PKGBUILD

  local qemu_version="$1"
  local qemu_target="$2" # arm, riscv, tools

  qemu_src_folder_name="${XBB_QEMU_SRC_FOLDER_NAME:-qemu-${qemu_version}.git}"

  local qemu_folder_name="qemu-${qemu_version}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/"

  local qemu_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${qemu_folder_name}-installed"
  if [ ! -f "${qemu_stamp_file_path}" ] || [ "${XBB_IS_DEBUG}" == "y" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}" ]
    then
      git_clone "${XBB_QEMU_GIT_URL}" "${XBB_QEMU_GIT_BRANCH}" \
          "${XBB_QEMU_GIT_COMMIT}" "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}"

      # Simple way to customise the greeting message, instead of
      # managing a patch, or a fork.
      run_verbose sed -i.bak \
        -e 's|printf("QEMU emulator version "|printf("xPack QEMU emulator version "|' \
        "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/softmmu/vl.c"
    fi
    # exit 1

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${qemu_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${qemu_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"

      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH:-${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib}"
      elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -fstack-protector"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS

      (
        if [ ! -f "config.status" ]
        then

          xbb_show_env_develop

          echo
          echo "Running qemu ${qemu_target} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            # Although it shouldn't, the script checks python before --help.
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/configure" \
              --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--bindir=${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin")

          # This seems redundant, but without it the greeting
          # string is suffixed by -dirty.
          config_options+=("--with-pkgversion=${XBB_QEMU_GIT_COMMIT}")

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("--cross-prefix=${XBB_CROSS_COMPILE_PREFIX}-")
          fi

          config_options+=("--cc=${CC}")
          config_options+=("--cxx=${CXX}")

          # CFLAGS, CXXFLAGS and LDFLAGS are used directly.
          config_options+=("--extra-cflags=${CPPFLAGS}")
          config_options+=("--extra-cxxflags=${CPPFLAGS}")

          config_options+=("--python=python3")

          if [ "${qemu_target}" == "arm" ]
          then
            config_options+=("--target-list=arm-softmmu,aarch64-softmmu")
            config_options+=("--disable-tools")
          elif [ "${qemu_target}" == "riscv" ]
          then
            config_options+=("--target-list=riscv32-softmmu,riscv64-softmmu")
            config_options+=("--disable-tools")
          elif [ "${qemu_target}" == "tools" ]
          then
            config_options+=("--target-list=") # None
            config_options+=("--enable-tools")
          else
            echo "Unsupported qemu_target ${qemu_target}"
            exit 1
          fi

          if [ "${XBB_IS_DEBUG}" == "y" ]
          then
            config_options+=("--enable-debug")
          fi

          config_options+=("--enable-nettle")
          config_options+=("--enable-lzo")

          # Not toghether with nettle.
          # config_options+=("--enable-gcrypt")

          if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
          then
            config_options+=("--enable-libssh")
            config_options+=("--enable-curses")
            config_options+=("--enable-vde")
          fi

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # For now, Cocoa builds fail on macOS 10.13.
            if [ "${XBB_ENABLE_QEMU_SDL:-"n"}" == "y" ]
            then
              # In the first Arm release.
              config_options+=("--disable-cocoa")
              config_options+=("--enable-sdl")
            else
              config_options+=("--enable-cocoa")
              config_options+=("--disable-sdl")
            fi
            # Prevent codesign issues caused by including the Hypervisor.
            config_options+=("--disable-hvf")
          else
            config_options+=("--enable-sdl")
          fi

          config_options+=("--disable-bsd-user")
          config_options+=("--disable-guest-agent")
          config_options+=("--disable-gtk")

          if [ "${XBB_WITH_STRIP}" != "y" ]
          then
            config_options+=("--disable-strip")
          fi

          config_options+=("--disable-werror")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}/configure" \
            ${config_options[@]}

        fi
        cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/configure-log-$(ndate).txt"
      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/configure-output-$(ndate).txt"

      (
        echo
        echo "Running qemu ${qemu_target} make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} # V=1

        run_verbose make install

        if [ "${qemu_target}" == "arm" ]
        then
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/qemu-system-aarch64"
        elif [ "${qemu_target}" == "riscv" ]
        then
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/qemu-system-riscv64"
        elif [ "${qemu_target}" == "tools" ]
        then
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/qemu-img"
        else
          echo "Unsupported qemu_target ${qemu_target}"
          exit 1
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${qemu_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${qemu_src_folder_name}" \
        "qemu-${qemu_version}"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${qemu_stamp_file_path}"

  else
    echo "Component qemu ${qemu_target} already installed."
  fi

  # Define this function at package level.
  tests_add "test_qemu_${qemu_target}" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
}

# -----------------------------------------------------------------------------

