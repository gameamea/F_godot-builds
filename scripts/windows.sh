#!/bin/bash

#------
# This script compiles and packages Godot for Windows using MinGW and InnoSetup.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
# line just for easier comparison with linux.h

if [ $buildWindowsEditor -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    # Build 32 bits editor
    # -----
    label="32-bit editor for Windows"
    echo_header "Running $label"
    cmdScons platform=windows bits=32 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS
    # Remove symbols and sections from files
    strip "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe"
    mkdir -p "$EDITOR_DIR/x86/Godot"
    cpcheck "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe" "$EDITOR_DIR/x86/Godot/godot.exe"
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
  fi

  # Build 64 bits editor
  # -----
  label="64-bit editor for Windows"
  echo_header "Running $label"
  cmdScons platform=windows bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe"
  mkdir -p "$EDITOR_DIR/x86_64/Godot"
  cpcheck "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" "$EDITOR_DIR/x86_64/Godot/godot.exe"
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

if [ $buildWindowsTemplates -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    # Build 32 bits export templates
    # --------------
    label="32-bit debug export template for Windows"
    echo_header "Running $label"
    cmdScons platform=windows bits=32 tools=no target=release_debug $SCONS_FLAGS
    # Remove symbols and sections from files
    strip "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

    label="32-bit release export template for Windows"
    echo_header "Running $label"
    cmdScons platform=windows bits=32 tools=no target=release $SCONS_FLAGS
    # Remove symbols and sections from files
    strip "$GODOT_DIR/bin/godot.windows.opt.32.exe"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
  fi

  # Build 64 bits export templates
  # --------------
  label="64-bit debug export template for Windows"
  echo_header "Running $label"
  cmdScons platform=windows bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="64-bit release export template for Windows"
  echo_header "Running $label"
  cmdScons platform=windows bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.windows.opt.64.exe"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
