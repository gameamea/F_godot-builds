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

check="mono_static=yes"
if [ $(echo $MONO_FLAG | grep -iF $check | wc -l) -gt 0 ]; then
  echo_warning "Linking Mono statically is not currently supported on Android. It has been disabled."
  MONO_FLAG=$(echo $MONO_FLAG | sed "s/$check/mono_static=no/g")
fi

# Build Godot debug templates for Android
if [ "$buildWithMono" -eq 1 ]; then
  echo_warning "1-4/9 Building debug export templates for Android are bypassed due to missing debug version of mono for android (too long, but can be done if necessary)"
else
  label="1/9 Building x86_64 debug export template for Android"
  echo_header "Running $label"
  [ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-x86_64-debug"
  cmdScons platform=android android_arch=x86_64 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="2/9 Building x86 debug export template for Android"
  echo_header "Running $label"
  [ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-x86-debug"
  cmdScons platform=android android_arch=x86 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="3/9 Building ARMv7 debug export template for Android"
  echo_header "Running $label"
  [ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-armeabi-v7a-debug"
  cmdScons platform=android android_arch=armv7 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="4/9 Building ARMv8 debug export template for Android"
  echo_header "Running $label"
  [ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-arm64-v8a-debug"
  cmdScons platform=android android_arch=arm64v8 target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build Godot release templates for Android
label="5/9 Building x86_64 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-x86_64-release"
cmdScons platform=android android_arch=x86_64 target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="6/9 Building x86 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-x86-release"
cmdScons platform=android android_arch=x86 target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="7/9 Building ARMv7 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-armeabi-v7a-release"
cmdScons platform=android android_arch=armv7 target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="8/9 Building ARMv8 release export template for Android"
echo_header "Running $label"
[ ! -z $MONO_PREFIX_ANDROID ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_ANDROID/mono-installs/android-arm64-v8a-release"
cmdScons platform=android android_arch=arm64v8 target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

# Package export templates into APKs
label="9/9 Packaging Android export templates into APKs"
echo_header "Running $label"
cd "$GODOT_DIR/platform/android/java"
# remove build content, if not, build will produce no apk
rm -Rf "$GODOT_DIR/platform/android/java/build/"
./gradlew build
cd "../../.."

#NOTE: file are generated in /platform/android/java/app/build/outputs/apk/ folder in not directly in bin (WTF ?)
cpcheck "$GODOT_DIR/platform/android/java/app/build/outputs/apk/debug/android_debug.apk" "$GODOT_DIR/bin"
cpcheck "$GODOT_DIR/platform/android/java/app/build/outputs/apk/release/android_release.apk" "$GODOT_DIR/bin"

if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
