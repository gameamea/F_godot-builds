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

#[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-arm64-v8a-release"
cmdScons platform=android android_arch=arm64v8 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS

#scons platform=android target=release android_arch=armv7
#scons platform=android target=release android_arch=arm64v8
cd platform/android/java
rm -Rf "$GODOT_DIR/platform/android/java/build/"
./gradlew build
