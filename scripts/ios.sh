#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

typeOpt=$1
bitsOpt=$2
monoOpt=$3
if [ -z $typeOpt ]; then typeOpt="editor"; fi
if [ -z $bitsOpt ]; then bitsOpt=64; fi

echo_error "NOT IMPLEMENTED"