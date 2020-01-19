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

# if set to 1, no question will be ask and default value will be used
export isQuiet="${isQuiet:-0}"

# default answer to yesNo questions
export defaultYN=1

# default answer to yesNo questions if already built
export alreadyDoneYN=1

result=0

# ------------
# UMOVABLE VARIABLES
# ------------

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

# print script usage and help
function usage() {
  echo ""
  echo "Usage:"
  echo "$(basename $0)"
  echo "Result:"
  echo " Build mono for goto."
  echo "Command line options:"
  echo " -h |--help  : Show this help and exit."
  echo " -q |--quiet : Stop asking for user input (automatic or batch mode)."
  echo "Notes:"
  echo " Settings at the start of this file can be changed to custom build process."
  exit 0
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
  ./desktop.py $MONO_BUILDS_LINUX_FLAGS linux configure --target=i686 --target=x86_64
  ./desktop.py $MONO_BUILDS_LINUX_FLAGS linux make --target=i686 --target=x86_64
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_info "$label built with error"; fi
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
  ./desktop.py $MONO_BUILDS_WINDOWS_FLAGS $MONO_BUILDS_CROSS_COMPIL_FLAG windows configure --target=i686 --target=x86_64
  ./desktop.py $MONO_BUILDS_WINDOWS_FLAGS $MONO_BUILDS_CROSS_COMPIL_FLAG windows make --target=i686 --target=x86_64
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_info "$label built with error"; fi
fi

answer=$defaultYN
label="Mono for MacOS"
if [ -r "$MONO_BUILDS_PREFIX_MACOS/mono-installs/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtime for 64-bit macOS.
  ./desktop.py $MONO_BUILDS_MACOS_FLAGS osx configure --target=x86_64
  ./desktop.py $MONO_BUILDS_MACOS_FLAGS osx make --target=x86_64
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_info "$label built with error"; fi
fi

answer=$defaultYN
label="Mono for Android"
if [ -r "$MONO_BUILDS_PREFIX_ANDROID/mono-installs/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  #Some patches may need to be applied to the Mono sources before building for Android.
  ./patch_mono.py

  # Build the runtime for all supported Android ABIs.
  ./android.py $MONO_BUILDS_ANDROID_FLAGS configure --target=all-runtime
  ./android.py $MONO_BUILDS_ANDROID_FLAGS make --target=all-runtime

  # Build the AOT cross-compilers targeting all supported Android ABIs.
  ./android.py $MONO_BUILDS_ANDROID_FLAGS configure --target=all-cross
  ./android.py $MONO_BUILDS_ANDROID_FLAGS make --target=all-cross

  # Build the AOT cross-compilers for Windows targeting all supported Android ABIs.
  ./android.py $MONO_BUILDS_ANDROID_FLAGS $MONO_BUILDS_CROSS_COMPIL_FLAG configure --target=all-cross-win
  ./android.py $MONO_BUILDS_ANDROID_FLAGS $MONO_BUILDS_CROSS_COMPIL_FLAG make --target=all-cross-win

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_info "$label built with error"; fi
fi

answer=$defaultYN
label="Mono for WebAssembly"
if [ -r "$MONO_BUILDS_WEBASM_FLAGS/mono-installswasm-runtime-release/bin/mono-gdb.py" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtime for WebAssembly.
  ./wasm.py $MONO_BUILDS_WEBASM_FLAGS configure --target=runtime
  ./wasm.py $MONO_BUILDS_WEBASM_FLAGS make --target=runtime

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_info "$label built with error"; fi
fi

answer=$defaultYN
label="Base Class library and Reference Assemblies"
if [ -r "TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=$alreadyDoneYN
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the Desktop BCL.
  ./bcl.py make --product=desktop

  # Build the Android BCL.
  ./bcl.py make --product=android

  # Build the WebAssembly BCL.
  ./bcl.py make --product=wasm

  # install the reference assemblies
  ./reference_assemblies.py install

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_info "$label built with error"; fi
fi
