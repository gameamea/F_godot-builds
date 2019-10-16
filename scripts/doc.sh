#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

echo_warning "TO FINISH"

# Update classes.xml (used to generate doc)

# cp doc/base/classes.xml .
$TEMPLATES_DIR/linux_server.64 -doctool $GODOT_DIR/doc/classes.xml