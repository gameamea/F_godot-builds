#!/bin/bash

#------
# This script compiles Mono for linux, Windows, MacOS, Android and Webassembly.
# based on the Readme at https://github.com/godotengine/godot-mono-builds
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

# do not stop on build exit with error
# set -euo pipefail

# if set to 1, no question will be ask and default value will be used (needed for functions.h)
export isQuiet="${isQuiet:-0}"

# if set to 1, process will be stopped when something fails (needed for functions.h)
export stopOnFail="${stopOnFail:-0}"

# default answer to yesNo questions
export defaultYN=1

# default answer to yesNo questions if already built
export alreadyDoneYN=1

result=0

# ------------
# UMOVABLE VARIABLES
# ------------

# folder where the mono binary is installed (needed to compile mono)
MONO_BIN_PREFIX=/usr

# mono version to compile
MONO_TAG="mono-6.4.0.198"
MONO_TAG="mono-6.8.0.96"

# `DIR` contains the directory where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any location
# NOTE: can not be moved in variables.sh
export DIR="${DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"}"

# The directory where utility scripts are located
export UTILITIES_DIR="${UTILITIES_DIR:-"$DIR/utilities"}"

# add some functions
source "$UTILITIES_DIR/functions.sh"

# init variables and settings
source "$UTILITIES_DIR/variables.sh"

# folder for the mono sources
MONO_FOLDER=$(dirname $MONO_SOURCE_ROOT)

# print script usage and help
function usage() {
  echo ""
  echo "Usage:"
  echo "$(basename $0)"
  echo "Result:"
  echo " Build mono for goto."
  echo "Command line options:"
  echo " -h |--help  : Show this help and exit."
  echo " -p |--printenv  : Print the environment settings and exit."
  echo " -q |--quiet : Stop asking for user input (automatic or batch mode)."
  echo "Notes:"
  echo " Settings at the start of this file can be changed to custom build process."
  exit 0
}

function printEnv() {
  echo ""
  echo "Script parameters:"
  echo ""
  echo "isQuiet=$isQuiet"
  echo "TOOLS_MONO_BUILDS=$TOOLS_MONO_BUILDS"
  echo "ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT"
  echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
  echo "TOOLS_MONO_BUILDS=$TOOLS_MONO_BUILDS"
  echo "MONO_BUILDS_CROSS_COMPIL_FLAG=$MONO_BUILDS_CROSS_COMPIL_FLAG"
  echo "MONO_BUILDS_PREFIX_LINUX=$MONO_BUILDS_PREFIX_LINUX"
  echo "MONO_BUILDS_PREFIX_WINDOWS=$MONO_BUILDS_PREFIX_WINDOWS"
  echo "MONO_BUILDS_PREFIX_MACOS=$MONO_BUILDS_PREFIX_MACOS"
  echo "MONO_BUILDS_PREFIX_ANDROID=$MONO_BUILDS_PREFIX_ANDROID"
  echo "MONO_BUILDS_PREFIX_WEBASM=$MONO_BUILDS_PREFIX_WEBASM"
  echo "MONO_BUILDS_LINUX_FLAGS=$MONO_BUILDS_LINUX_FLAGS"
  echo "MONO_BUILDS_WINDOWS_FLAGS=$MONO_BUILDS_WINDOWS_FLAGS"
  echo "MONO_BUILDS_MACOS_FLAGS=$MONO_BUILDS_MACOS_FLAGS"
  echo "MONO_BUILDS_ANDROID_FLAGS=$MONO_BUILDS_ANDROID_FLAGS"
  echo "MONO_BUILDS_WEBASM_FLAGS=$MONO_BUILDS_WEBASM_FLAGS"
  exit 0
}

# #
# # run commands using python
function runPython() {
  printf "\n${blueOnWhite}Running:${blueOnBlack}scons $*${resetColor}\n"
  python $*
}

# ------------
# COMMAND LINE OPTIONS
# Must be done before other init
# ------------

while [ -n "$1" ]; do
  #echo_info "parameter=$1"
  case "$1" in
    -h | --help)
      usage
      ;;
    -p | --printenv)
      printEnv
      ;;
    -q | --quiet)
      export isQuiet=1
      ;;
    --)
      # The double dash makes them parameters
      shift
      break
      ;;
    *)
      echo "Bad parametre in command line"
      exit 1
      ;;
  esac
  shift
done

answer=0
yesNoS "Do you want to clean mono source and compiled version in tools folder" $answer
if [ $result -eq 1 ]; then
  rm -Rf "$MONO_BUILDS_PREFIX_LINUX"
  rm -Rf "$MONO_BUILDS_PREFIX_WINDOWS"
  rm -Rf "$MONO_BUILDS_PREFIX_MACOS"
  rm -Rf "$MONO_BUILDS_PREFIX_ANDROID"
  rm -Rf "$MONO_BUILDS_PREFIX_WEBASM"
  rm -Rf "$MONO_BUILDS_PREFIX_BCL"

  rm -Rf "$MONO_FOLDER/mono"
fi

answer=0
yesNoS "Do you want to clone mono source" $answer
if [ $result -eq 1 ]; then
  PATH=$MONO_BIN_PREFIX/bin:$PATH

  cd $MONO_FOLDER

  git clone https://github.com/mono/mono.git --recursive

  cd mono

  git fetch --all
  git checkout $MONO_TAG

  git submodule update --init --recursive

  yesNoS "Do you want to compil mono by the usual way" $answer
  if [ $result -eq 1 ]; then
    ./autogen.sh --prefix=$MONO_BIN_PREFIX
    make
    make install
  fi
fi

cd $TOOLS_MONO_BUILDS

#echo $TOOLS_MONO_BUILDS;echo "ICI";exit

#TODO: replace all the TODO_CHANGE_FILENAME_HERE by final filenames once compiled

answer=$defaultYN
label="Mono for Linux"
if [ -f "$MONO_BUILDS_PREFIX_LINUX/mono-installs/desktop-linux-x86_64-release/bin/mono" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtimes for 32-bit and 64-bit Linux.
  runPython linux.py $MONO_BUILDS_LINUX_FLAGS configure --target=i686 --target=x86_64
  runPython linux.py $MONO_BUILDS_LINUX_FLAGS make --target=i686 --target=x86_64
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

answer=$defaultYN
label="Mono for Windows"
if [ -r "$MONO_BUILDS_PREFIX_WINDOWS/mono-installs/desktop-windows-x86_64-release/bin/mono.exe" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtimes for 32-bit and 64-bit Windows.
  runPython windows.py $MONO_BUILDS_WINDOWS_FLAGS configure --target=i686 --target=x86_64 $MONO_BUILDS_CROSS_COMPIL_FLAG
  runPython windows.py $MONO_BUILDS_WINDOWS_FLAGS make --target=i686 --target=x86_64 $MONO_BUILDS_CROSS_COMPIL_FLAG
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then
    echo_success "$label built successfully"
  else
    echo_warning "$label built with error"
    echo_info "if build fail with error : undefined reference to __chk_fail\nSome file needs to be patched or a more recent version of mono source must be used"
    echo_info "see https://github.com/mono/mono/issues/18287 and https://github.com/mono/mono/pull/18312/files"
  fi

  # some link must be created to avoid following errors when building windows editor
  # RuntimeError: Could not find mono library in: /mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/mono-installs/desktop-windows-x86_64-release/lib:
  # RuntimeError: Could not find mono shared library in: /mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/mono-installs/desktop-windows-x86_64-release/bin:
  cd $MONO_BUILDS_PREFIX_WINDOWS/mono-installs/desktop-windows-x86_64-release/lib
  # create missing files
  cp -f libmono-2.0.dll.a mono-2.0-sgen.a
  cp -f libmonosgen-2.0.dll.a monosgen-2.0.a
  # note symlink does not work here
  cp -f libmono-2.0.dll.a ../bin/mono-2.0-sgen.dll
  cp -f libmonosgen-2.0.dll.a ../bin/monosgen-2.0.dll
  cd $TOOLS_MONO_BUILDS
fi

answer=0
label="Mono for MacOS"
if [ -r "$MONO_BUILDS_PREFIX_MACOS/mono-installs/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtime for 64-bit macOS.
  runPython osx.py $MONO_BUILDS_MACOS_FLAGS configure --target=x86_64
  runPython osx.py $MONO_BUILDS_MACOS_FLAGS make --target=x86_64
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

answer=$defaultYN
label="Mono for Android"
# ERRORS
# scons android.py --install-dir=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/android/mono-installs --configure-dir=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/android/mono-config --mxe-prefix=/usr make --target=all-cross-win

if [ -r "$MONO_BUILDS_PREFIX_ANDROID/mono-installs/android-x86_64-release/bin/mono-sgen-gdb.py" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  if [ ! -r "$ANDROID_SDK_ROOT/ndk-bundle" ]; then
    sudo ln -s $ANDROID_NDK_ROOT "$ANDROID_SDK_ROOT/ndk-bundle"
  fi

  echo_header "Building $label"
  echo_info "Debug version of mono for android are bypassed (too long, but can be done if necessary, script must be completed if so)"

  # Targets to mono for android builds
  # The option --target=all-runtime is a shortcut for --target=armeabi-v7a --target=x86 --target=arm64-v8a --target=x86_64. The equivalent applies for all-cross and all-cross-win.
  # uses an enumerated platforme list instead
  #ANDROID_ALL_TARGET="--target=armeabi-v7a --target=x86 --target=arm64-v8a --target=x86_64"
  #ANDROID_ALL_TARGETCROSS="--target=armeabi-v7a --target=x86 --target=arm64-v8a --target=x86_64"
  #ANDROID_ALL_TARGETWIN="--target=armeabi-v7a --target=x86 --target=arm64-v8a --target=x86_64"
  ANDROID_ALL_TARGET="--target=all-runtime"
  ANDROID_ALL_TARGETCROSS="--target=all-cross"
  ANDROID_ALL_TARGETWIN="--target=all-cross-win"

  # Some patches may need to be applied to the Mono sources before building for Android.
  runPython patch_mono.py

  # Build the runtime for all supported Android ABIs.
  runPython android.py $MONO_BUILDS_ANDROID_FLAGS configure $ANDROID_ALL_TARGET
  runPython android.py $MONO_BUILDS_ANDROID_FLAGS make $ANDROID_ALL_TARGET

  # Build the AOT cross-compilers targeting all supported Android ABIs.
  runPython android.py $MONO_BUILDS_ANDROID_FLAGS configure $ANDROID_ALL_TARGETCROSS
  runPython android.py $MONO_BUILDS_ANDROID_FLAGS make $ANDROID_ALL_TARGETCROSS

  # Build the AOT cross-compilers for Windows targeting all supported Android ABIs.
  ##HS  runPython android.py $MONO_BUILDS_ANDROID_FLAGS configure $ANDROID_ALL_TARGETWIN $MONO_BUILDS_CROSS_COMPIL_FLAG
  ##HS  runPython android.py $MONO_BUILDS_ANDROID_FLAGS make $ANDROID_ALL_TARGETWIN $MONO_BUILDS_CROSS_COMPIL_FLAG
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

answer=$defaultYN
label="Mono for WebAssembly"
if [ -r "$MONO_BUILDS_PREFIX_WEBASM/mono-installs/wasm-runtime-release/bin/mono-gdb.py" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  echo_info "Debug version of mono for WebAssembly are bypassed (too long, but can be done if necessary, script must be completed if so)"

  # Some patches may need to be applied to the Emscripten SDK before building Mono.
  runPython patch_emscripten.py

  # Build the runtime for WebAssembly.
  runPython wasm.py $MONO_BUILDS_WEBASM_FLAGS configure --target=runtime
  runPython wasm.py $MONO_BUILDS_WEBASM_FLAGS make --target=runtime

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

answer=0
label="Base Class library and Reference Assemblies"
if [ -r "$MONO_BUILDS_PREFIX_BCL/mono-installs/" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the Desktop BCL.
  runPython bcl.py $MONO_BUILDS_BCL_FLAGS make --product=desktop

  # Build the Desktop BCL for Windows.
  runPython bcl.py $MONO_BUILDS_BCL_FLAGS make --product=desktop-win32

  # Build the Android BCL.
  runPython bcl.py $MONO_BUILDS_BCL_FLAGS make --product=android

  # Build the WebAssembly BCL.
  runPython bcl.py $MONO_BUILDS_BCL_FLAGS make --product=wasm

  # install the reference assemblies
  runPython reference_assemblies.py $MONO_BUILDS_BCL_FLAGS install

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
