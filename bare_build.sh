#!/usr/bin/bash

# This script is intended to run on Linux or OSX. Cygwin might work.

export GODOT_DIR="$(dirname $DIR)/_godot"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"

export EMSCRIPTEN_ROOT=/usr/lib/emscripten

export ANDROID_HOME=/opt/android-sdk
export ANDROID_NDK_ROOT=/opt/android-ndk

cd "$GODOT_DIR"

# git does not allow empty dirs, so create those
mkdir -p platform/android/java/libs/armeabi
mkdir -p platform/android/java/libs/x86

# remove this stuff, will be created anew
rm -rf $TEMPLATES_DIR
rm -rf $EDITOR_DIR
mkdir -p $TEMPLATES_DIR
mkdir -p $EDITOR_DIR

# Build templates

# Windows 32 Release and Debug
scons -j4 p=windows target=release tools=no bits=32
strip bin/godot.windows.opt.32.exe
cp bin/godot.windows.opt.32.exe $TEMPLATES_DIR/windows_32_release.exe
upx $TEMPLATES_DIR/windows_32_release.exe
scons -j4 p=windows target=release_debug tools=no bits=32
cp bin/godot.windows.opt.debug.32.exe $TEMPLATES_DIR/windows_32_debug.exe
strip bin/godot.windows.opt.debug.32.exe
upx $TEMPLATES_DIR/windows_32_debug.exe

# Windows 64 Release and Debug (UPX does not support it yet)
scons -j4 p=windows target=release tools=no bits=64
cp bin/godot.windows.opt.64.exe $TEMPLATES_DIR/windows_64_release.exe
x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_release.exe
scons -j4 p=windows target=release_debug tools=no bits=64
cp bin/godot.windows.opt.debug.64.exe $TEMPLATES_DIR/windows_64_debug.exe
x86_64-w64-mingw32-strip $TEMPLATES_DIR/windows_64_debug.exe

# Linux 64 Release and Debug
scons -j4 p=x11 target=release tools=no bits=64
cp bin/godot.x11.opt.64 $TEMPLATES_DIR/linux_x11_64_release
upx $TEMPLATES_DIR/linux_x11_64_release
scons -j4 p=x11 target=release_debug tools=no bits=64
cp bin/godot.x11.opt.debug.64 $TEMPLATES_DIR/linux_x11_64_debug
upx $TEMPLATES_DIR/linux_x11_64_debug

# Linux 32 Release and Debug
scons -j4 p=x11 target=release tools=no bits=32
cp bin/godot.x11.opt.32 $TEMPLATES_DIR/linux_x11_32_release
upx $TEMPLATES_DIR/linux_x11_32_release
scons -j4 p=x11 target=release_debug tools=no bits=32
cp bin/godot.x11.opt.debug.32 $TEMPLATES_DIR/linux_x11_32_debug
upx $TEMPLATES_DIR/linux_x11_32_debug

# Server for 32 and 64 bits (always in debug)
scons -j4 p=server target=release_debug tools=no bits=64
cp bin/godot_server.server.opt.debug.64 $TEMPLATES_DIR/linux_server_64
upx $TEMPLATES_DIR/linux_server_64
scons -j4 p=server target=release_debug tools=no bits=32
cp bin/godot_server.server.opt.debug.32 $TEMPLATES_DIR/linux_server_32
upx $TEMPLATES_DIR/linux_server_32

#Android
scons -j4 platform=android target=release android_arch=armv7
scons -j4 platform=android target=release android_arch=arm64v8
scons -j4 platform=android target=release android_arch=x86
scons -j4 platform=android target=release_debug android_arch=armv7
scons -j4 platform=android target=release_debug android_arch=arm64v8
scons -j4 platform=android target=release_debug android_arch=x86
cd "platform/android/java"
./gradlew build
cd "../../.."

# Javascript
scons -j4 p=javascript target=release
cp bin/godot.javascript.opt.html godot.html
cp bin/godot.javascript.opt.js godot.js
cp tools/html_fs/filesystem.js .
zip javascript_release.zip godot.html godot.js filesystem.js
mv javascript_release.zip $TEMPLATES_DIR/

scons -j4 p=javascript target=release_debug
cp bin/godot.javascript.opt.debug.html godot.html
cp bin/godot.javascript.opt.debug.js godot.js
cp tools/html_fs/filesystem.js .
zip javascript_debug.zip godot.html godot.js filesystem.js
mv javascript_debug.zip $TEMPLATES_DIR/

# BUILD ON MAC

# TODO

# Build editor

scons -j4 p=server target=release_debug bits=64
cp bin/godot_server.server.opt.tools.64 $EDITOR_DIR/linux_server.64
upx $EDITOR_DIR/linux_server.64

scons -j4 p=x11 target=release_debug tools=yes bits=64
cp bin/godot.x11.opt.tools.64 $EDITOR_DIR/godot_x11.64
upx $EDITOR_DIR/godot_x11.64 # may fails on some linux distros

scons -j4 p=x11 target=release_debug tools=yes bits=32
cp bin/godot.x11.opt.tools.32 $EDITOR_DIR/godot_x11.32

scons -j4 p=windows target=release_debug tools=yes bits=64
cp bin/godot.windows.opt.tools.64.exe $EDITOR_DIR/godot_win64.exe
x86_64-w64-mingw32-strip $EDITOR_DIR/godot_win64.exe
upx $EDITOR_DIR/godot_win64.exe

scons -j4 p=windows target=release_debug tools=yes bits=32
cp bin/godot.windows.opt.tools.32.exe $EDITOR_DIR/godot_win32.exe
x86_64-w64-mingw32-strip $EDITOR_DIR/godot_win32.exe
upx $EDITOR_DIR/godot_win64.exe

# TODO
# mac stuff

# Update classes.xml (used to generate doc)

# cp doc/base/classes.xml .
$TEMPLATES_DIR/linux_server.64 -doctool $GODOT_DIR/doc/classes.xml
