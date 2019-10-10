#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

if [ "$buildWithJavascriptSingleton" -eq 1 ]; then
  SINGLETON_FLAG=''
else
  SINGLETON_FLAG='javascript_eval=no'
fi

# Build Godot templates for Web (Javascript)
echo_header "Building release export template for Web…"
scons platform=javascript target=release tools=no $LTO_FLAG $SINGLETON_FLAG $SCONS_FLAGS
echo_success "Finished building release export templates for Web…."

echo_header "Building debug export template for Web…"
scons platform=javascript target=release_debug tools=no $LTO_FLAG $SINGLETON_FLAG $SCONS_FLAGS
echo_success "Finished building debug export templates for Web…."
