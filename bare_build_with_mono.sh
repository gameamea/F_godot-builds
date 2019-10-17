#!/usr/bin/bash

# This script is intended to run on Linux or OSX. Cygwin might work.
#------
# Bare build script for Godot with Mono.
# It's a one piece and simplified version of main build script used for testing purpose.
# Using main compilation script is better
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# This script is licensed under CC0 1.0 Universal:
#------

# if set to 1, no question will be ask and default value will be used
export isQuiet=0
# if set to 1, binaries size will be optimised
export optimisationOn=0
# default answer to yesNo questions
export defaultYN=1

# Specify the number of CPU threads to use as the first command line argument
# If not set, defaults to 1.5 times the number of CPU threads
#export THREADS="${1:-"$(($(nproc) * 3 / 2))"}"
# change to use all threads
export THREADS=$(nproc)

# SCons flags to use in all build commands
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"

# Link optimisation flag (64 bits only).
if [ "x$optimisationOn" = "x1"]; then
  # LINKING PROCESS TAKES MUCH MORE TIME
  export LTO_FLAG='use_lto=yes'
else
  export LTO_FLAG=''
fi

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# various godot versions
#export GODOT_DIR="$(dirname $DIR)/godot_(Frugs_auto_formatter)"
#export GODOT_DIR="$(dirname $DIR)/godot_(Official)"
export GODOT_DIR="$(dirname $DIR)/_godot"

export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor.mono"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates.mono"
export TOOLS_DIR="${TOOLS_DIR:-"$DIR/tools"}"


export TOOLS_MONO_DIR="${TOOLS_MONO_DIR:-"$TOOLS_DIR/mono"}"
export MONO_PREFIX_LINUX="$TOOLS_MONO_DIR/linux"
export MONO_PREFIX_WINDOWS="$TOOLS_MONO_DIR/windows"
export MONO_PREFIX_ANDROID="$TOOLS_MONO_DIR/android/mono-installs"

export EMSCRIPTEN_ROOT="/usr/lib/emscripten"

export ANDROID_HOME="/opt/android-sdk"
export ANDROID_NDK_ROOT="/opt/android-ndk"

if [ ! -r $GODOT_DIR ]; then
  printf "\n$GODOT_DIR is not readable. Operation Aborted\n"
  exit 1
fi

function cmdScons() {
  printf "\n***********\nRunning:scons $*\n***********\n"
  scons $*
}

function cmdUpxStrip() {
  if [ $optimisationOn -eq 0 ]; then
    echo "optimisation deactivated"
  else
    strip $*
    upx $*
  fi
}

function yesNoS() {
  if [ "x$isQuiet" = "x1" ]; then
    result=$2
    printf "\n$1\n"
  else
    if [ "$1" = "" ]; then message="Confirm "; else message=$1; fi
    message="$message (Y/N)"
    if [ ! "x$resetColor" = "x" ]; then message="$greenOnBlack$message$resetColor"; fi
    printf "$message"
    read -p '? ' userInput # -p is used to avoid default message
    if [ "$userInput" = "Y" ] || [ "$userInput" = "y" ] || [ "$userInput" = "O" ] || [ "$userInput" = "o" ]; then
      result=1
    else
      result=0
    fi
  fi
}

printf "\n***********\nGODOT MONO BARE BUILD\n***********\n"
printf "\nSource folder: $GODOT_DIR\n"

cd "$GODOT_DIR"

# git does not allow empty dirs, so create those
mkdir -p platform/android/java/libs/armeabi
mkdir -p platform/android/java/libs/x86

# remove this stuff, a new will be created
rm -Rf platform/android/java/build
#rm -rf $TEMPLATES_DIR
#rm -rf $EDITOR_DIR
mkdir -p $TEMPLATES_DIR
mkdir -p $EDITOR_DIR

echo "EDITOR_DIR=$EDITOR_DIR"
echo "TEMPLATES_DIR=$TEMPLATES_DIR"
echo ""

# TODO: BUILD ON MAC

echo "NOT AVAILABLE:Building MONO Linux 32 bits Editor"
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
echo "NOT AVAILABLE:Building MONO Linux 32 bits templates"
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison

yesNoS "Building MONO Linux 64 Editor" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  # Build temporary binary
  cmdScons platform=x11 tools=yes target=release_debug bits=64 mono_glue=no copy_mono_root=yes $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_LINUX
  # Generate glue sources
  bin\godot.x11.opt.tools.32.mono --generate-mono-glue modules/mono/mono-installs/glue
  # Build binaries normally
  cmdScons platform=x11 tools=yes target=release_debug bits=64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot.x11.opt.tools.64.mono $EDITOR_DIR/godot_x11.64.mono
  cmdUpxStrip $EDITOR_DIR/godot_x11.64.mono # may fails on some linux distros
  # MONO DATA Folder: GodotSharp
fi
yesNoS "Building MONO Linux 64 Release and Debug Template" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons platform=x11 target=release_debug tools=no bits=64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot.x11.opt.debug.64.mono $TEMPLATES_DIR/linux_x11_64_debug.mono
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_64_debug.mono
  # MONO DATA Folder: data.mono.x11.64.debug

  cmdScons platform=x11 target=release tools=no bits=64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot.x11.opt.64.mono $TEMPLATES_DIR/linux_x11_64_release.mono
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_64_release.mono
  # MONO DATA Folder: data.mono.x11.64.release
fi

echo "NOT AVAILABLE:Building MONO Windows 32 bits Editor"
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
echo "NOT AVAILABLE:Building MONO Windows 32 bits templates"
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison

yesNoS "Building MONO Windows 64 Editor" $defaultYN # ECHEC : erreur de build
# RuntimeError: Could not find mono library in: /mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/lib:
if [ $result -eq 1 ]; then
  cmdScons platform=windows tools=yes target=release_debug bits=64 copy_mono_root=yes $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_WINDOWS
  cp bin/godot.windows.opt.tools.64.mono.exe $EDITOR_DIR/godot_win64.mono.exe
  x86_64-w64-mingw32-strip $EDITOR_DIR/godot_win64.mono.mono.exe
  cmdUpxStrip $EDITOR_DIR/godot_win64.mono.exe
fi
yesNoS "Building MONO Windows 64 Release and Debug Template" $defaultYN
# ECHEC : erreur de build
# RuntimeError: Could not find mono library in: /mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/lib:
if [ $result -eq 1 ]; then
  cmdScons platform=windows target=release_debug tools=no bits=64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_WINDOWS
  cp bin/godot.windows.opt.debug.64.mono.exe $TEMPLATES_DIR/windows_64_debug.mono.exe
  x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_debug.mono.exe

  cmdScons platform=windows target=release tools=no bits=64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_WINDOWS
  cp bin/godot.windows.opt.64.mono.exe $TEMPLATES_DIR/windows_64_release.mono.exe
  x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_release.mono.exe
fi

yesNoS "Building MONO Linux Server for 32 and 64 bits" $defaultYN # ECHEC: erreur de build
# AssertionError:
if [ $result -eq 1 ]; then
  cmdScons platform=server target=release_debug tools=no bits=32 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot_server.x11.opt.debug.32 $TEMPLATES_DIR/linux_server_32
  cmdUpxStrip $TEMPLATES_DIR/linux_server_32

  cmdScons platform=server target=release_debug tools=no bits=64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot_server.x11.opt.debug.64 $TEMPLATES_DIR/linux_server_64
  cmdUpxStrip $TEMPLATES_DIR/linux_server_64
fi

yesNoS "Building MONO Android Template" $defaultYN # ÉCHEC - Pb compil gradlew build
#Cannot create service of type PayloadSerializer using ToolingBuildSessionScopeServices.createPayloadSerializer() as there is a problem with parameter #2 of type PayloadClassLoaderFactory.
if [ $result -eq 1 ]; then
  cmdScons platform=android target=release_debug android_arch=x86_64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-x86_64-release
  cmdScons platform=android target=release_debug android_arch=x86 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-x86-release
  cmdScons platform=android target=release_debug android_arch=armv7 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-armeabi-v7a-debug
  cmdScons platform=android target=release_debug android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-arm64-v8a-debug

  cmdScons platform=android target=release android_arch=x86_64 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-x86_64-debug
  cmdScons platform=android target=release android_arch=x86 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-x86-debug
  cmdScons platform=android target=release android_arch=armv7 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-armeabi-v7a-release
  cmdScons platform=android target=release android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS mono_prefix=$MONO_PREFIX_ANDROID/android-arm64-v8a-release
  cd "platform/android/java"
  ./gradlew build
  cd "../../.."
fi

echo "NOT AVAILABLE:Building MONO Javascript templates"
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison

echo "NOT AVAILABLE:Building MONO Doc"
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
# line just for easier comparison
