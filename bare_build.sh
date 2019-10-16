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
#export GODOT_DIR="$(dirname $DIR)/godot_(Frugs_auto_formatter)"
#export GODOT_DIR="$(dirname $DIR)/godot_(Official)"
export GODOT_DIR="$(dirname $DIR)/_godot"

export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"

export EMSCRIPTEN_ROOT=/usr/lib/emscripten

export ANDROID_HOME=/opt/android-sdk
export ANDROID_NDK_ROOT=/opt/android-ndk

export THREADS=$(nproc)
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"

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

printf "\n***********\nGODOT BARE BUILD\n***********\n"
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

yesNoS "Building Linux 32 Editor" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=x11 target=release_debug tools=yes bits=32
  cp bin/godot.x11.opt.tools.32 $EDITOR_DIR/godot_x11.32
  cmdUpxStrip $EDITOR_DIR/godot_x11.32 # may fails on some linux distros
fi
yesNoS "Building Linux 32 Release and Debug Template" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=x11 target=release_debug tools=no bits=32
  cp bin/godot.x11.opt.debug.32 $TEMPLATES_DIR/linux_x11_32_debug
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_32_debug

  cmdScons $SCONS_FLAGS p=x11 target=release tools=no bits=32
  cp bin/godot.x11.opt.32 $TEMPLATES_DIR/linux_x11_32_release
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_32_release
fi

yesNoS "Building Linux 64 Editor" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=x11 target=release_debug tools=yes bits=64
  cp bin/godot.x11.opt.tools.64 $EDITOR_DIR/godot_x11.64
  cmdUpxStrip $EDITOR_DIR/godot_x11.64 # may fails on some linux distros
fi
yesNoS "Building Linux 64 Release and Debug Template" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=x11 target=release_debug tools=no bits=64
  cp bin/godot.x11.opt.debug.64 $TEMPLATES_DIR/linux_x11_64_debug
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_64_debug

  cmdScons $SCONS_FLAGS p=x11 target=release tools=no bits=64
  cp bin/godot.x11.opt.64 $TEMPLATES_DIR/linux_x11_64_release
  cmdUpxStrip $TEMPLATES_DIR/linux_x11_64_release
fi

yesNoS "Building Windows 32 Editor" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=windows target=release_debug tools=yes bits=32
  cp bin/godot.windows.opt.tools.32.exe $EDITOR_DIR/godot_win32.exe
  x86_64-w64-mingw32-strip $EDITOR_DIR/godot_win32.exe
  cmdUpxStrip $EDITOR_DIR/godot_win32.exe
fi
yesNoS "Building Windows 32 Release and Debug Template" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=windows target=release_debug tools=no bits=32
  cp bin/godot.windows.opt.debug.32.exe $TEMPLATES_DIR/windows_32_debug.exe
  strip bin/godot.windows.opt.debug.32.exe
  cmdUpxStrip $TEMPLATES_DIR/windows_32_debug.exe

  cmdScons $SCONS_FLAGS p=windows target=release tools=no bits=32
  strip bin/godot.windows.opt.32.exe
  cp bin/godot.windows.opt.32.exe $TEMPLATES_DIR/windows_32_release.exe
  cmdUpxStrip $TEMPLATES_DIR/windows_32_release.exe
fi

yesNoS "Building Windows 64 Editor" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=windows target=release_debug tools=yes bits=64
  cp bin/godot.windows.opt.tools.64.exe $EDITOR_DIR/godot_win64.exe
  x86_64-w64-mingw32-strip $EDITOR_DIR/godot_win64.exe
  cmdUpxStrip $EDITOR_DIR/godot_win64.exe
fi
yesNoS "Building Windows 64 Release and Debug Template" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=windows target=release_debug tools=no bits=64
  cp bin/godot.windows.opt.debug.64.exe $TEMPLATES_DIR/windows_64_debug.exe
  x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_debug.exe

  cmdScons $SCONS_FLAGS p=windows target=release tools=no bits=64
  cp bin/godot.windows.opt.64.exe $TEMPLATES_DIR/windows_64_release.exe
  x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_release.exe
fi

yesNoS "Building Linux Server for 32 and 64 bits" $defaultYN #TEST OK
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=server target=release_debug tools=no bits=32
  cp bin/godot_server.x11.opt.debug.32 $TEMPLATES_DIR/linux_server_32
  cmdUpxStrip $TEMPLATES_DIR/linux_server_32

  cmdScons $SCONS_FLAGS p=server target=release_debug tools=no bits=64
  cp bin/godot_server.x11.opt.debug.64 $TEMPLATES_DIR/linux_server_64
  cmdUpxStrip $TEMPLATES_DIR/linux_server_64
fi

yesNoS "Building Android Template" $defaultYN # ÉCHEC - Pb compil gradlew build
#Cannot create service of type PayloadSerializer using ToolingBuildSessionScopeServices.createPayloadSerializer() as there is a problem with parameter #2 of type PayloadClassLoaderFactory.
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS platform=android target=release_debug android_arch=x86_64
  cmdScons $SCONS_FLAGS platform=android target=release_debug android_arch=x86
  cmdScons $SCONS_FLAGS platform=android target=release_debug android_arch=armv7
  cmdScons $SCONS_FLAGS platform=android target=release_debug android_arch=arm64v8

  cmdScons $SCONS_FLAGS platform=android target=release android_arch=x86_64
  cmdScons $SCONS_FLAGS platform=android target=release android_arch=x86
  cmdScons $SCONS_FLAGS platform=android target=release android_arch=armv7
  cmdScons $SCONS_FLAGS platform=android target=release android_arch=arm64v8
  cd "platform/android/java"
  ./gradlew build
  cd "../../.."
fi

yesNoS "Building Javascript Template" $defaultYN #TEST OK -
if [ $result -eq 1 ]; then
  cmdScons $SCONS_FLAGS p=javascript target=release
  cp javascript_release.zip $TEMPLATES_DIR/

  cmdScons $SCONS_FLAGS p=javascript target=release_debug
  cp javascript_debug.zip $TEMPLATES_DIR/
fi

yesNoS "Building Doc" $defaultYN # ÉCHEC - fichier manquant
if [ $result -eq 1 ]; then
  # Update classes.xml (used to generate doc)

  # cp doc/base/classes.xml .
  $TEMPLATES_DIR/linux_server.64 -doctool $GODOT_DIR/doc/classes.xml
fi
