---
title: Getting Started with xPack {{ appName }}

date: 2020-09-28 17:49:00 +0300

---

[![GitHub package.json version](https://img.shields.io/github/package-json/v/xpack-dev-tools/{{ appLcName }}-xpack)](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/blob/xpack/package.json)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/xpack-dev-tools/{{ appLcName }}-xpack)](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/releases/)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/{{ appLcName }}.svg?color=blue)](https://www.npmjs.com/package/@xpack-dev-tools/{{ appLcName }}/)
[![license](https://img.shields.io/github/license/xpack-dev-tools/{{ appLcName }}-xpack)](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/blob/xpack/LICENSE)

## Overview

**xPack {{ appName }}** is a standalone cross-platform (Windows, macOS, GNU/Linux)
binary distribution of [{{ appName }}](https://{{ appLcName }}.org),
intended for reproducible builds.

{{ appName }}, the **Open On-Chip Debugger**, is an open source project hosted on
[SourceForge](http://sourceforge.net/p/{{ appLcName }}/code/).

**xPack {{ appName }}** is an open source project hosted on GitHub as
[`xpack-dev-tools/{{ appLcName }}-xpack`](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack);
it provides the platform specific binaries as
[release assets](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/releases).

In addition to the binary archives and the package metadata,
this project also includes the
[build scripts](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/tree/xpack/scripts).

## Features

All binaries are:

- **self-contained** (include all required libraries)
- **file-system relocatable** (can be installed in any location)
- built on a slightly older system (to make them run on a wide range of systems)

## Benefits

The main advantages of using the **xPack {{ appName }}** are:

- a convenient, uniform and portable install/uninstall/upgrade procedure;
  the same procedure is used for all major
  platforms (**Intel Windows** 64-bit,
  **Intel GNU/Linux** 64-bit,
  **Arm GNU/Linux** 64/32-bit,
  **Intel macOS** 64-bit,
  **Apple Silicon macOS** 64-bit)
- multiple versions of the same package can be installed at the same time on
  the same system
- no need to worry about dependent libraries, all are included
- a good integration with development environments (no need for Docker images)
- projects can be tied to specific tools versions; this provides a good
  reproducibility, especially useful in **CI/CD** environments.

## Compatibility

The **xPack {{ appName }}** is fully compatible with the original **{{ appName }}**
source distribution.

## Install

The binaries can be installed automatically as **binary xPacks** or manually as
**portable archives**.

The details of installing the **xPack {{ appName }}** on various platforms are
presented in the separate
[Install Guide](/docs/install/) page.

## Documentation

The original {{ appName }} documentation is available from the project web:

- https://{{ appLcName }}.org/pages/documentation.html [![PDF](/img/pdf-24.png)](https://{{ appLcName }}.org/doc/pdf/{{ appLcName }}.pdf)

## Release schedule

This distribution generally follows the official
[{{ appName }}](https://{{ appLcName }}.org), with
additional releases based on the current Git form time to time.

## Support

The quick advice for getting support is to use the
[GitHub Discussions](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/discussions/).

For additional information, please refer to the
[Help Center](/docs/support/) page.

## Change log

The release and change log is available in the repository
[`CHANGELOG.md`](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/blob/xpack/CHANGELOG.md) file.

## Maintainer & Developer info

For information on the workflow used to make releases, please see the
[Maintainer Info](/docs/maintainer-info/) page.

For information on how to build the binaries, please see the
[Developer Info](/docs/developer-info/) page.

However, the ultimate source for details are the build scripts themselves,
all available from the
[`{{ appLcName }}-xpack.git/scripts`](https://github.com/xpack-dev-tools/{{ appLcName }}-xpack/tree/xpack/scripts/)
folder. The scripts include common code from the [`@xpack-dev-tools/xbb-helper`](https://github.com/xpack-dev-tools/xbb-helper-xpack) package.

## License

Unless otherwise stated, the original content is released under the terms of the
[MIT License](https://opensource.org/licenses/mit/),
with all rights reserved to
[Liviu Ionescu](https://github.com/ilg-ul).

The binary distributions include several open-source components; the
corresponding licenses are available in the installed
`distro-info/licenses` folder.

## Releases

The list of releases is available in the [Releases](/docs/releases/) pages.
