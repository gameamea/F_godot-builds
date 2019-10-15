#!/bin/bash

#------
# This script compiles Godot for macOS using OSXCross.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# Specify the macOS SDK version as cmdScons defaults to darwin14 and use Xcode Clang flags
export SCONS_FLAGS="$SCONS_FLAGS osxcross_sdk=darwin15 CCFLAGS=-D__MACPORTS__"

if [ $buildMacosEditor -eq 1 ]; then
  # Build 64 bits editor
  # -----
  label="Building 64-bit editor for macOS"
  echo_header "Running $label"
  cmdScons platform=osx bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  cmdUpxStrip "$GODOT_DIR/bin/godot.osx.opt.tools.64"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

if [ $buildMacosTemplates -eq 1 ]; then
  # Build 64 bits export templates
  # --------------
  label="Building 64-bit release export template for macOS"
  echo_header "Running $label"
  cmdScons platform=osx bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  cmdUpxStrip "$GODOT_DIR/bin/godot.osx.opt.debug.64"
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="Building 64-bit debug export template for macOS"
  echo_header "Running $label"
  cmdScons platform=osx bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  cmdUpxStrip "$GODOT_DIR/bin/godot.osx.opt.64"
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
