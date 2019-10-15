#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# Build SERVER release_debug export template (No release version for server)
if [ $build32Bits -eq 1 ]; then
  label="Building 32 bits SERVER release export template"
  echo_header "Running $label"
  cmdScons platform=server bits=32 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  cmdUpxStrip $TEMPLATES_DIR/linux_server_32
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Building 64 bits SERVER release export template"
echo_header "Running $label"
cmdScons platform=server bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
cmdUpxStrip $TEMPLATES_DIR/linux_server_64
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
