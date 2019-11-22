# Godot Build Scripts

This repository contains scripts for compiling Godot for various platforms.

## Using this build system for your own builds

You are welcome to use these build scripts to set up your own build environment.
Here are some technical details:

### Supported platforms

- **Linux** (64-bit only)
- **macOS** (64-bit only) (NOT TESTED since the initial version of the script in 2017)
- **Windows** (64-bit + 32-bit) (NOT TESTED since the initial version of the script in 2017)
- **Android** (ARMv7, ARMv8, x86, x64)
- **Web** (emscripten)
- **iOS** (ARMv8 + ARMv7) (NOT TESTED since the initial version of the script in 2017)
- **Mono builds** can be enabled or not (when mono is available for the concerned binary).

#### Additional notes

- **Linux editors come as [AppImages](https://appimage.org/).**
  - No dependencies need to be installed before running them – just download it,
    make it executable then run it!
  - These also provide substantial file size reductions thanks to the built-in
    DEFLATE compression.
- **Windows editors are packaged into installers generated using [InnoSetup](http://www.jrsoftware.org/isinfo.php).**
  - The installers do not require administrative privileges to work.
  - These also provide built-in LZMA compression, making the download faster.

### Directory structure

These are the most important items:

|          File / directory | Purpose                                                                    |
| ------------------------: | -------------------------------------------------------------------------- |
|          `build_godot.sh` | The main build script                                                      |
|           `bare_build.sh` | A monobloc bare build script for testing purpose                           |
| `bare_build_with_mono.sh` | A monobloc bare build script with mono for testing purpose                 |
|       `synch_branches.sh` | Sync local changes and official git repo. MUST BE CHECKED BEFORE FIRST RUN |
|              `artifacts/` | Contains generated binaries and helper folders for editor and templates    |
|                  `logs /` | logs files                                                                 |
|              `resources/` | Contains resource files, such as Windows installer definition files        |
|                `scripts/` | Contains the platform-specific build and packaging scripts                 |
|                  `tools/` | Contains various utilities, such as for installing dependencies            |
|              `tools/mono` | Mono sources for customized builds (usefull for android templates)         |
| `tools/godot-mono-builds` | Scripts for building customized Mono (usefull for android templates)       |
|              `utilities/` | Contains script settings and helpers                                       |

### Log files

The build process will log building operations and deployment results in 2 files stored in the './logs' folder.
They are named as followed:

- '[date_of_the_day]_success.log' for the whole process steps AND the successfull messages.
- '[date_of_the_day]_fail.log' for the whole process steps AND the failed messages.

As these files are constantly updated during the build process, you can use them to know the current step in process (usefull when the console is flooded by compilation messages).

### Setting it up

This build system has been initially tested on Fedora 27 and Ubuntu 14.04, and then on the **latest Arch Linux release available in september 2019**
Linux builds have been made in Arch Linux.

#### Environment variables

Settings variables at the start of the main build script can be changed to customize the build process and the binaries to build.
**It's advised to check their value before launching the process.**

All the other variables used by the scripts can be found in the file './tools/variables.sh'. They can be changed too, but not necessarily.

## TODO

- test scripts on Ubuntu 16.04 to maximize templates compatability
- finish missing platforms builds and tests (check the TODOs in files)

## License

Copyright © 2017 Hugo Locurcio and contributors
Copyright © 2019 Laurent Ongaro and contributors

Files in this repository are licensed under CC0 1.0 Universal,
see [LICENSE.md](LICENSE.md) for more information.
