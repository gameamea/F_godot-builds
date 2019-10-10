#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

if [ $build32Bits -eq 1 ]; then
  # Build 32 bits editor
  # -----
  echo_header "Building 32 bits editor for Linux…"
  scons platform=x11 bits=32 tools=yes target=release_debug $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.tools.32"
  echo_success "Finished building 32 bits editor for Linux."
fi

# Build 64 bits editor
# -----
echo_header "Building 64 bits editor for Linux…"
scons platform=x11 bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS
# Remove symbols and sections from files
strip "$GODOT_DIR/bin/godot.x11.opt.tools.64"
echo_success "Finished building 64 bits editor for Linux."

echo_info "Linux binaries usually won’t run on distributions that are older than the distribution they were built on. If you wish to distribute binaries that work on most distributions, you should build them on an old distribution such as Ubuntu 16.04. You can use a virtual machine or a container to set up a suitable build environment."

if [ $build32Bits -eq 1 ]; then
  # Build 32 bits export templates
  # --------------
  echo_header "Building 32 bits debug export template for Linux…"
  scons platform=x11 bits=32 tools=no target=release_debug $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.debug.32"
  echo_success "Finished building 32 bits debug export templates for Linux."

  echo_header "Building 32 bits release export template for Linux…"
  scons platform=x11 bits=32 tools=no target=release $SCONS_FLAGS
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.32"
  echo_success "Finished building 32 bits release export templates for Linux."
fi

# Build 64 bits export templates
# --------------
echo_header "Building 64 bits debug export template for Linux…"
scons platform=x11 bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS
# Remove symbols and sections from files
strip "$GODOT_DIR/bin/godot.x11.opt.debug.64"
echo_success "Finished building 64 bits debug export templates for Linux."

echo_header "Building 64 bits release export template for Linux…"
scons platform=x11 bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS
# Remove symbols and sections from files
strip "$GODOT_DIR/bin/godot.x11.opt.64"
echo_success "Finished building 64 bits release export templates for Linux."
