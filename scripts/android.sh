#!/bin/bash

#------
# This script compiles Godot for Android.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# Build Godot templates for Android
label="1/7 Building ARMv7 release export template for Android"
echo_header "Running $label"
cmdScons platform=android target=release android_arch=armv7 $LTO_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="2/7 Building ARMv8 release export template for Android"
echo_header "Running $label"
cmdScons platform=android target=release android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="3/7 Building x86 release export template for Android"
echo_header "Running $label"
cmdScons platform=android target=release android_arch=x86 $LTO_FLAG $SCONS_FLAGS

if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="4/7 Building ARMv7 debug export template for Android"
echo_header "Running $label"
cmdScons platform=android target=release_debug android_arch=armv7 $LTO_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="5/7 Building ARMv8 debug export template for Android"
echo_header "Running $label"
cmdScons platform=android target=release_debug android_arch=arm64v8 $LTO_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="6/7 Building x86 debug export template for Android"
echo_header "Running $label"
cmdScons platform=android target=release_debug android_arch=x86 $LTO_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

# Package export templates into APKs
label="7/7 Packaging Android export templates into APKs"
echo_header "Running $label"
cd "$GODOT_DIR/platform/android/java"
# remove build content, if not, build will produce no apk
rm -Rf "build/"
./gradlew build
cd "../../.."
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
