#!/bin/bash

#------
# This script compiles Godot for macOS using OSXCross.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal - for the base version
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal - for the updated version
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# Specify the macOS SDK version as cmdScons defaults to darwin14 and use Xcode Clang flags
export SCONS_FLAGS="$SCONS_FLAGS osxcross_sdk=darwin15 CCFLAGS=-D__MACPORTS__"

# Note : no 32 bits versions on macOS

# Build 64 bits editor
# -----
if [ $buildMacosEditor -eq 1 ]; then
  label="Building 64 bits editor for macOS"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.osx.opt.tools.64"
  rm -f $resultFile
  cmdScons platform=osx bits=64 tools=yes $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
# Build 64 bits export templates
# --------------
if [ $buildMacosTemplates -eq 1 ]; then
  label="Building 64 bits debug export template for macOS"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.osx.opt.debug.64"
  rm -f $resultFile
  cmdScons platform=osx bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="Building 64 bits release  export template for macOS"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.osx.opt.64"
  rm -f $resultFile
  cmdScons platform=osx bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
