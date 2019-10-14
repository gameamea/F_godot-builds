#!/bin/bash

#------
# This script compiles and packages Godot for Windows using MinGW and InnoSetup.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
# line just for easier comparison with linux.h

if [ "$buildWithMono" -eq 1 ]; then
  MONO_FLAG='module_mono_enabled=yes'
  MONO_EXT='.mono'
else
  MONO_FLAG=''
  MONO_EXT=''
fi

if [ $buildWindowsEditor -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    if [ "$buildWithMono" -eq 1 ]; then
      label="Generate the glue for 32 bits editor for Windows"
      echo_header "Running $label"
      if [ $isArchLike -eq 1 ]; then
        echo_info "${orangeOnWhite}32 bit version of mono is not available on this platform. Can not Built${resetColor}"
        result=0
      else
        # Generate the glue
        # -----
        cmdScons platform=windows bits=32 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
        "$GODOT_DIR/bin/godot.windows.tools.32.mono.exe" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
        rm "$GODOT_DIR/bin/godot.windows.tools.32.mono.exe"

        # Build 32 bits editor
        # -----
        label="Building 32-bit editor for Windows"
        echo_header "Running $label"
        cmdScons platform=windows bits=32 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
        # Remove symbols and sections from files
        x86_64-w64-mingw32-strip "$GODOT_DIR/bin/godot.windows.opt.tools.32${MONO_EXT}.exe"
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
      fi
    fi
  fi
  if [ "$buildWithMono" -eq 1 ]; then
    # Generate the glue
    # -----
    label="Generate the glue for 64 bits editor for Windows"
    echo_header "Running $label"
    cmdScons platform=windows bits=64 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
    "$GODOT_DIR/bin/godot.windows.tools.64.mono.exe" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    rm "$GODOT_DIR/bin/godot.windows.tools.64.mono.exe"
  fi

  # Build 64 bits editor
  # -----
  label="Building 64-bit editor for Windows"
  echo_header "Running $label"
  cmdScons platform=windows bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip "$GODOT_DIR/bin/godot.windows.opt.tools.64${MONO_EXT}.exe"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build 32 bits export templates
# --------------
if [ $buildWindowsTemplates -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    label="Building 32-bit debug export template for Windows"
    echo_header "Running $label"
    if [ $isArchLike -eq 1 ]; then
      echo_info "${orangeOnWhite}32 bit version of mono is not available on this platform. Can not Built${resetColor}"
      result=0
    else
      cmdScons platform=windows bits=32 tools=no target=debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
      # Remove symbols and sections from files
      x86_64-w64-mingw32-strip "$GODOT_DIR/bin/godot.windows.opt.debug.32${MONO_EXT}.exe"
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

      label="32-bit release export template for Windows"
      echo_header "Running $label"
      cmdScons platform=windows bits=32 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
      # Remove symbols and sections from files
      x86_64-w64-mingw32-strip "$GODOT_DIR/bin/godot.windows.opt.32${MONO_EXT}.exe"
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi

  # Build 64 bits export templates
  # --------------
  label="64-bit debug export template for Windows"
  echo_header "Running $label"
  cmdScons platform=windows bits=64 tools=no target=debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip "$GODOT_DIR/bin/godot.windows.opt.debug.64${MONO_EXT}.exe"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="64-bit release export template for Windows"
  echo_header "Running $label"
  cmdScons platform=windows bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip "$GODOT_DIR/bin/godot.windows.opt.64${MONO_EXT}.exe"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
