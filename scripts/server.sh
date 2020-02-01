#!/bin/bash

#------
# This script compiles Godot for Linux.
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# Build 32 bits server binaries
# -----
if [ $build32Bits -eq 1 ]; then
  label="Building 32 bits SERVER debug binary"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot_server.x11.debug.32${MONO_EXT}"
  rm -f $resultFile
  cmdScons p=server bits=32 tools=no target=debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="Building 32 bits SERVER release_debug binary"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot_server.x11.opt.debug.32${MONO_EXT}"
  rm -f $resultFile
  cmdScons p=server bits=32 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build 64 bits server binaries
# -----
label="Building 64 bits SERVER debug binary"
echo_header "Running $label"
resultFile="$GODOT_DIR/bin/godot_server.x11.debug.64${MONO_EXT}"
rm -f $resultFile
cmdScons p=server bits=64 tools=no target=debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
cmdUpxStrip $resultFile
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="Building 64 bits SERVER release_debug binarie"
echo_header "Running $label"
resultFile="$GODOT_DIR/bin/godot_server.x11.opt.debug.64${MONO_EXT}"
rm -f $resultFile
cmdScons p=server bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
cmdUpxStrip $resultFile
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
