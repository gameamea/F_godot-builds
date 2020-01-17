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
export isQuiet=0

# default answer to yesNo questions
export defaultYN=1

result=0

# The directory where utility scripts are located
export UTILITIES_DIR="${UTILITIES_DIR:-"."}"
export TOOLS_DIR="${TOOLS_DIR:-"../tools"}"

# The path to The mono sources for build
export MONO_SOURCE_ROOT="${MONO_SOURCE_ROOT:-"/mnt/R/Apps_Sources/mono"}"

# The path to the mono dependencies
export TOOLS_MONO_DIR="${TOOLS_MONO_DIR:-"$TOOLS_DIR/mono"}"

# The path to the mono build script
export TOOLS_MONO_BUILD="${TOOLS_MONO_BUILD:-"$TOOLS_DIR/godot-mono-builds"}"

export CROSS_COMPIL_FLAG="--mxe-prefix=/usr"

export MONO_PREFIX_LINUX="$TOOLS_MONO_DIR/linux"
export MONO_PREFIX_WINDOWS="$TOOLS_MONO_DIR/windows"
export MONO_PREFIX_MACOS="$TOOLS_MONO_DIR/macos"
export MONO_PREFIX_ANDROID="$TOOLS_MONO_DIR/android"
export MONO_PREFIX_WEBASM="$TOOLS_MONO_DIR/webasm"
export LINUX_FLAGS="--install-dir=$MONO_PREFIX_LINUX/mono-installs --configure-dir=$MONO_PREFIX_LINUX/mono-config"
export MAC_FLAGS="--install-dir=$MONO_PREFIX_MACOS/mono-installs --configure-dir=$MONO_PREFIX_MACOS/mono-config"
export WINDOWS_FLAGS="--install-dir=$MONO_PREFIX_WINDOWS/mono-installs --configure-dir=$MONO_PREFIX_WINDOWS/mono-config"
export ANDROID_FLAGS="--install-dir=$MONO_PREFIX_ANDROID/mono-installs --configure-dir=$MONO_PREFIX_ANDROID/mono-config"
export WEBASM_FLAGS="--install-dir=$MONO_PREFIX_WEBASM/mono-installs --configure-dir=$MONO_PREFIX_WEBASM/mono-config"

#export LINUX_FLAGS=""
#PATH=$PREFIX/bin:$PATH

mkdir -p $TOOLS_MONO_DIR

cd $TOOLS_MONO_BUILD

answer=$defaultYN

#TODO: replace all the TODO_CHANGE_FILENAME_HERE by final filenames once compiled

label="Mono for Linux"
if [ -r "$MONO_PREFIX_LINUX/bin/mono/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=0
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtimes for 32-bit and 64-bit Linux.
  ./desktop.py $LINUX_FLAGS linux configure --target=i686 --target=x86_64
  ./desktop.py $LINUX_FLAGS linux make --target=i686 --target=x86_64
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Mono for Windows"
if [ -r "$MONO_PREFIX_LINUX/bin/mono/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=1
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtimes for 32-bit and 64-bit Windows.
  ./desktop.py linux configure --target=i686 --target=x86_64 $WINDOWS_FLAGS $CROSS_COMPIL_FLAG
  ./desktop.py linux make --target=i686 --target=x86_64 $WINDOWS_FLAGS $CROSS_COMPIL_FLAG
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Mono for MacOS"
if [ -r "$MONO_PREFIX_MACOS/bin/mono/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=1
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtime for 64-bit macOS.
  ./desktop.py osx configure --target=x86_64 $MACOS_FLAGS
  ./desktop.py osx make --target=x86_64 $MACOS_FLAGS
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Mono for Android"
if [ -r "$MONO_PREFIX_ANDROID/mono-installs/android-x86_64-release" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=0
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtime for all supported Android ABIs.
  ./android.py configure --target=all-runtime $ANDROID_FLAGS
  ./android.py make --target=all-runtime $ANDROID_FLAGS

  # Build the AOT cross-compilers targeting all supported Android ABIs.
  ./android.py configure --target=all-cross $ANDROID_FLAGS
  ./android.py make --target=all-cross $ANDROID_FLAGS

  # Build the AOT cross-compilers for Windows targeting all supported Android ABIs.
  ./android.py configure --target=all-cross-win $ANDROID_FLAGS $CROSS_COMPIL_FLAG
  ./android.py make --target=all-cross-win $ANDROID_FLAGS $CROSS_COMPIL_FLAG

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Mono for WebAssembly"
if [ -r "$WEBASM_FLAGS/mono-installs/TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=0
fi
yesNoS "Do you want to build $label" $answer
if [ $result -eq 1 ]; then
  echo_header "Building $label"
  # Build the runtime for WebAssembly.
  ./wasm.py configure --target=runtime $WEBASM_FLAGS
  ./wasm.py make --target=runtime $WEBASM_FLAGS

  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Base Class library and Reference Assemblies"
if [ -r "TODO_CHANGE_FILENAME_HERE" ]; then
  echo_info "$label has already been built. Building it again will take unnecessary time..."
  answer=0
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
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
