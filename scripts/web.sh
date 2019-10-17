#!/bin/bash

#------
# This script compiles Godot for Web.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

if [ "$buildWithJavascriptSingleton" -eq 0 ]; then
  SINGLETON_FLAG='javascript_eval=no'
else
  SINGLETON_FLAG=''
fi

if [ "$buildWithMono" -eq 1 ]; then
  echo_info "Mono version of Web templates are not available."
  exit 0 # if 1, built process will be stopped
fi

# Build Godot templates for Web (Javascript)
label="Building debug export template for Web"
echo_header "Running $label"
cmdScons platform=javascript target=release_debug tools=no $SINGLETON_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

label="Building release export template for Web"
echo_header "Running $label"
cmdScons platform=javascript target=release tools=no $SINGLETON_FLAG $SCONS_FLAGS
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
