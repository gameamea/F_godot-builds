#!/bin/bash

#------
# This script compiles Godot for Android.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# The paths to the Android SDK and NDK, only overridden if the user
# does not already have these variables set
export ANDROID_HOME="${ANDROID_HOME:-"$TOOLS_DIR/android"}"
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-"$TOOLS_DIR/android/ndk-bundle"}"

# Build Godot templates for Android
echo_header "1/7 Building ARMv7 release export template for Android…"
cmdScons platform=android target=release android_arch=armv7 $LTO_FLAG $SCONS_FLAGS
echo_header "2/7 Building ARMv8 release export template for Android…"
cmdScons platform=android target=release android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS
echo_header "3/7 Building x86 release export template for Android…"
cmdScons platform=android target=release android_arch=x86 $LTO_FLAG $SCONS_FLAGS
echo_success "Finished building release export templates for Android."

echo_header "4/7 Building ARMv7 debug export template for Android…"
cmdScons platform=android target=release_debug android_arch=armv7 $LTO_FLAG $SCONS_FLAGS
echo_header "5/7 Building ARMv8 debug export template for Android…"
cmdScons platform=android target=release_debug android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS
echo_header "6/7 Building x86 debug export template for Android…"
cmdScons platform=android target=release_debug android_arch=x86 $LTO_FLAG $SCONS_FLAGS
echo_success "Finished building debug export templates for Android."

# Package export templates into APKs
echo_header "7/7 Packaging Android export templates into APKs…"
cd "$GODOT_DIR/platform/android/java"
# remove build content, if not, build will produce no apk
rm -Rf "build/"
./gradlew build
cd "../../.."
echo_success "Finished Packaging Android export templates."
