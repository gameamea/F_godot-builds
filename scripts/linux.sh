#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
echo_info "NOTE: Linux binaries usually won’t run on distributions that are older than the distribution they were built on. If you wish to distribute binaries that work on most distributions, you should build them on an old distribution such as Ubuntu 16.04. You can use a virtual machine or a container to set up a suitable build environment."

if [ $buildLinuxEditor -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    # Build 32 bits editor
    # -----
    label="Building 32 bits editor for Linux"
    echo_header "Running $label"
    cmdScons platform=x11 bits=32 tools=yes target=release_debug $SCONS_FLAGS
    # Remove symbols and sections from files
    # line just for easier comparison with windows.h
    strip "$GODOT_DIR/bin/godot.x11.opt.tools.32"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
  fi

  # Build 64 bits editor
  # -----
  label="Building 64 bits editor for Linux"
  echo_header "Running $label"
  cmdScons platform=x11 bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  # line just for easier comparison with windows.h
  strip "$GODOT_DIR/bin/godot.x11.opt.tools.64"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

if [ $buildLinuxTemplates -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    # Build 32 bits export templates
    # --------------
    label="Building 32 bits debug export template for Linux"
    echo_header "Running $label"
    cmdScons platform=x11 bits=32 tools=no target=release_debug $SCONS_FLAGS
    # Remove symbols and sections from files
    strip "$GODOT_DIR/bin/godot.x11.opt.debug.32"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

    label="Building 32 bits release export template for Linux"
    echo_header "Running $label"
    cmdScons platform=x11 bits=32 tools=no target=release $SCONS_FLAGS
    # Remove symbols and sections from files
    strip "$GODOT_DIR/bin/godot.x11.opt.32"
    if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
  fi

  # Build 64 bits export templates
  # --------------
  label="Building 64 bits debug export template for Linux"
  echo_header "Running $label"
  cmdScons platform=x11 bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.debug.64"
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="Building 64 bits release export template for Linux"
  echo_header "Running $label"
  cmdScons platform=x11 bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.64"
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
