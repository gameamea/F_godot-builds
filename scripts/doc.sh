#!/bin/bash

#------
# This script create docs for Godot for Linux.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal - for the base version
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal - for the updated version
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

echo_warning "MUST BE FIXED"

# Update classes.xml (used to generate doc)

# cp doc/base/classes.xml .
$TEMPLATES_DIR/linux_server.64 -doctool $GODOT_DIR/doc/classes.xml
