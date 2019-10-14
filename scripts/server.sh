#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

echo_warning "TO FINISH"

scons -j4 p=server target=release_debug tools=no bits=64
cp bin/godot_server.server.opt.debug.64 $TEMPLATES_DIR/linux_server_64
upx $TEMPLATES_DIR/linux_server_64
scons -j4 p=server target=release_debug tools=no bits=32
cp bin/godot_server.server.opt.debug.32 $TEMPLATES_DIR/linux_server_32
upx $TEMPLATES_DIR/linux_server_32
