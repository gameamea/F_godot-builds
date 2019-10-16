#!/usr/bin/bash

# This script is intended to run on Linux or OSX. Cygwin might work.

# if set to 1, no question will be ask and default value will be used
export isQuiet=1
# if set to 1, process will be stopped when something fails
export stopOnFail=1
# if set to 1, binaries size will be optimised
export optimisationOn=1
# default answer to yesNo questions
export defaultYN=1

export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# various godot versions
export GODOT_DIR="$(dirname $DIR)/godot_(Frugs_auto_formatter)"
export GODOT_DIR="$(dirname $DIR)/godot_(Official)"
export GODOT_DIR="$(dirname $DIR)/_godot"

export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor.mono"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates.mono"

export EMSCRIPTEN_ROOT=/usr/lib/emscripten

export ANDROID_HOME=/opt/android-sdk
export ANDROID_NDK_ROOT=/opt/android-ndk

export THREADS=$(nproc)
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS module_mono_enabled=yes"

export TOOLS_DIR="${TOOLS_DIR:-"$DIR/tools"}"
export TOOLS_MONO_DIR="${TOOLS_MONO_DIR:-"$TOOLS_DIR/mono"}"
export MONO_PREFIX_LINUX="$TOOLS_MONO_DIR/linux"
export MONO_PREFIX_WINDOWS="$TOOLS_MONO_DIR/windows"
export MONO_PREFIX_ANDROID="$TOOLS_MONO_DIR/android/mono-installs"

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

# TODO BUILD ON MAC

echo "NOT AVAILABLE:Building MONO Linux 32 Editor & templates"

yesNoS "Building MONO Linux 64 Editor" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  # Build temporary binary
  cmdScons $SCONS_FLAGS p=x11 tools=yes bits=64 mono_glue=no copy_mono_root=yes mono_prefix=$MONO_PREFIX_LINUX
  # Generate glue sources
  bin\godot.x11.tools.32.mono --generate-mono-glue modules/mono/mono-installs/glue
  # Build binaries normally
  cmdScons $SCONS_FLAGS p=x11 target=release_debug tools=yes bits=64 mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot.x11.opt.tools.64.mono $EDITOR_DIR/godot_x11.64.mono
  cmdUpxStrip $EDITOR_DIR/godot_x11.64.mono # may fails on some linux distros
  # MONO DATA Folder: GodotSharp
fi
yesNoS "Building MONO Linux 64 Release and Debug Template" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=x11 target=debug tools=no bits=64 mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot.x11.opt.debug.64.mono $TEMPLATES_DIR/linux_x11_64_debug.mono
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_64_debug.mono
  # MONO DATA Folder: data.mono.x11.64.debug

  cmdScons $SCONS_FLAGS p=x11 target=release tools=no bits=64 mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot.x11.opt.64.mono $TEMPLATES_DIR/linux_x11_64_release.mono
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_64_release.mono
  # MONO DATA Folder: data.mono.x11.64.release
fi

yesNoS "Building MONO Linux Server for 32 and 64 bits" $defaultYN # ECHEC: erreur de build
# AssertionError:
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=server target=release_debug tools=no bits=32 mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot_server.x11.opt.debug.32 $TEMPLATES_DIR/linux_server_32
  cmdUpxStrip $TEMPLATES_DIR/linux_server_32

  cmdScons $SCONS_FLAGS p=server target=release_debug tools=no bits=64 mono_prefix=$MONO_PREFIX_LINUX
  cp bin/godot_server.x11.opt.debug.64 $TEMPLATES_DIR/linux_server_64
  cmdUpxStrip $TEMPLATES_DIR/linux_server_64
fi

echo "NOT AVAILABLE:Building MONO Windows 32 Editor & templates"

yesNoS "Building MONO Windows 64 Editor" $defaultYN # ECHEC : erreur de build
# RuntimeError: Could not find mono library in: /mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/lib:
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=windows target=release_debug tools=yes bits=64 copy_mono_root=yes mono_prefix=$MONO_PREFIX_WINDOWS
  cp bin/godot.windows.opt.tools.64.mono.exe $EDITOR_DIR/godot_win64.mono.exe
  x86_64-w64-mingw32-strip $EDITOR_DIR/godot_win64.mono.mono.exe
  cmdUpxStrip $EDITOR_DIR/godot_win64.mono.exe
fi
yesNoS "Building MONO Windows 64 Release and Debug Template" 1
# ECHEC : erreur de build
# RuntimeError: Could not find mono library in: /mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/lib:
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=windows target=release_debug tools=no bits=64 mono_prefix=$MONO_PREFIX_WINDOWS
  cp bin/godot.windows.opt.debug.64.mono.exe $TEMPLATES_DIR/windows_64_debug.mono.exe
  x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_debug.mono.exe

  cmdScons $SCONS_FLAGS p=windows target=release tools=no bits=64
  cp bin/godot.windows.opt.64.mono.exe $TEMPLATES_DIR/windows_64_release.mono.exe
  x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_release.mono.exe
fi

# TODO BUILD ON MAC

yesNoS "Building MONO Android Template" $defaultYN # ÉCHEC - Pb compil gradlew build
#Cannot create service of type PayloadSerializer using ToolingBuildSessionScopeServices.createPayloadSerializer() as there is a problem with parameter #2 of type PayloadClassLoaderFactory.
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS platform=android target=debug android_arch=x86_64 mono_prefix=$MONO_PREFIX_ANDROID/android-x86_64-release
  cmdScons $SCONS_FLAGS platform=android target=debug android_arch=x86 mono_prefix=$MONO_PREFIX_ANDROID/android-x86-release
  cmdScons $SCONS_FLAGS platform=android target=debug android_arch=armv7 mono_prefix=$MONO_PREFIX_ANDROID/android-armeabi-v7a-debug
  cmdScons $SCONS_FLAGS platform=android target=debug android_arch=arm64v8 mono_prefix=$MONO_PREFIX_ANDROID/android-arm64-v8a-debug

  cmdScons $SCONS_FLAGS platform=android target=release android_arch=x86_64 mono_prefix=$MONO_PREFIX_ANDROID/android-x86_64-debug
  cmdScons $SCONS_FLAGS platform=android target=release android_arch=x86 mono_prefix=$MONO_PREFIX_ANDROID/android-x86-debug
  cmdScons $SCONS_FLAGS platform=android target=release android_arch=armv7 mono_prefix=$MONO_PREFIX_ANDROID/android-armeabi-v7a-release
  cmdScons $SCONS_FLAGS platform=android target=release android_arch=arm64v8 mono_prefix=$MONO_PREFIX_ANDROID/android-arm64-v8a-release
  cd "platform/android/java"
  ./gradlew build
  cd "../../.."
fi
