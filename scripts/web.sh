#!/bin/bash

#------
# This script compiles Godot for Web.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
MONO_OPTIONS=""

# the resulting file will be placed in the bin subdirectory in a zip file called javascript.zip
# godot.javascript.opt.zip for release
# godot.javascript.opt.debug.zip for debug
# rename the release template as webassembly_release.zip
# rename the debug template as webassembly_debug.zip

if [ "$buildWithJavascriptSingleton" -eq 0 ]; then
  SINGLETON_FLAG='javascript_eval=no'
else
  SINGLETON_FLAG=''
fi

# Build Godot export templates for Web (Javascript)
if [ "$buildWithMono" -eq 1 ]; then
  echo_warning "Building debug export templates for Web are bypassed due to missing debug version of mono for android (too long, but can be done if necessary)"
else
  label="Building debug export template for Web"
  echo_header "Running $label"
  [ ! -z $MONO_PREFIX_WEBASM ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WEBASM/mono-installs/wasm-runtime-debug"
  cmdScons platform=javascript target=release_debug tools=no $SINGLETON_FLAG $SCONS_FLAGS $MONO_OPTIONS
  #Install file: "bin/godot.javascript.opt.debug.wasm" as "bin/.javascript_zip/godot.wasm"
  #Creating 'bin/godot.javascript.opt.debug.wrapped.js'
  #Install file: "bin/godot.javascript.opt.debug.wrapped.js" as "bin/.javascript_zip/godot.js"
  #zip(["bin/godot.javascript.opt.debug.zip"], ["bin/.javascript_zip/godot.js", "bin/.javascript_zip/godot.wasm", "bin/.javascript_zip/godot.html"])
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

label="Building release export template for Web"
[ ! -z $MONO_PREFIX_WEBASM ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WEBASM/mono-installs/wasm-runtime-release"
echo_header "Running $label"
cmdScons platform=javascript target=release tools=no $SINGLETON_FLAG $SCONS_FLAGS $MONO_OPTIONS
#Install file: "bin/godot.javascript.opt.wasm" as "bin/.javascript_zip/godot.wasm"
#Creating 'bin/godot.javascript.opt.wrapped.js'
#Install file: "bin/godot.javascript.opt.wrapped.js" as "bin/.javascript_zip/godot.js"
#zip(["bin/godot.javascript.opt.zip"], ["bin/.javascript_zip/godot.js", "bin/.javascript_zip/godot.wasm", "bin/.javascript_zip/godot.html"])
if [ $? -eq 0 ]; then result=1; else result=0; fi
if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
