#!/usr/bin/bash

# This script is intended to bypass full build process and make a faster test.
#------
# Test build script for Godot.
# It's a one piece and simplified script used for testing purpose.
# Using main compilation script is better.
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# This script is licensed under CC0 1.0 Universal:
#------
# web release build test
#cmdScons platform=javascript target=release tools=no $SCONS_FLAGS

scons p=x11 tools=yes module_mono_enabled=yes mono_glue=no
exit
cmdScons platform=x11 bits=64 tools=yes mono_glue=no -j4 module_mono_enabled=yes
# mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux
#  mono_static=yes copy_mono_root=yes progress=no debug_symbols=no target=release_debug
exit
#
# android release build test with mono
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS=" module_mono_enabled=yes $MONO_PREFIX_ANDROID/mono-installs/android-arm64-v8a-release"
cmdScons platform=android android_arch=arm64v8 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
#
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="module_mono_enabled=yes $MONO_PREFIX_ANDROID/mono-installs/android-armeabi-v7a-release"
cmdScons platform=android android_arch=armv7 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS

#scons platform=android target=release android_arch=armv7
#scons platform=android target=release android_arch=arm64v8

# remove build content, if not, build will produce no apk
rm -Rf "$GODOT_DIR/platform/android/java/build/"

cd "$GODOT_DIR/platform/android/java"
./gradlew build

#NOTE: file are generated in /platform/android/java/app/build/outputs/apk/ folder in not directly in bin
cp -a "$GODOT_DIR/platform/android/java/app/build/outputs/apk/debug/android_debug.apk" "$GODOT_DIR/bin"
cp -a "$GODOT_DIR/platform/android/java/app/build/outputs/apk/release/android_release.apk" "$GODOT_DIR/bin"
