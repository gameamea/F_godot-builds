#!/bin/bash

#------
# This script compiles Godot for Android.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal - for the base version
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal - for the updated version
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
MONO_OPTIONS=""

# Build Godot debug templates for Android
label="1/9 Building x86_64 debug export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-x86_64-debug"
cmdScons platform=android target=release_debug android_arch=x86_64 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="2/9 Building x86 debug export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-x86-debug"
cmdScons platform=android target=release_debug android_arch=x86 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="3/9 Building ARMv7 debug export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-armeabi-v7a-debug"
cmdScons platform=android target=release_debug android_arch=armv7 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="4/9 Building ARMv8 debug export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-arm64-v8a-debug"
cmdScons platform=android target=release_debug android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

# Build Godot release templates for Android
label="5/9 Building x86_64 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-x86_64-release"
cmdScons platform=android target=release android_arch=x86_64 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="6/9 Building x86 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-x86-release"
cmdScons platform=android target=release android_arch=x86 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="7/9 Building ARMv7 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-armeabi-v7a-release"
cmdScons platform=android target=release android_arch=armv7 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="8/9 Building ARMv8 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG mono_prefix=$MONO_PREFIX_ANDROID/android-arm64-v8a-release"
cmdScons platform=android target=release android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

# Package export templates into APKs
label="9/9 Packaging Android export templates into APKs"
echo_header "Running $label"
cd "$GODOT_DIR/platform/android/java"
# remove build content, if not, build will produce no apk
rm -Rf "build/"
./gradlew build
cd "../../.."
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
