#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
echo_info "NOTE: Linux binaries usually won’t run on distributions that are older than the distribution they were built on. If you wish to distribute binaries that work on most distributions, you should build them on an old distribution such as Ubuntu 16.04. You can use a virtual machine or a container to set up a suitable build environment."

if [ "$buildWithMono" -eq 1 ]; then
  MONO_FLAG='module_mono_enabled=yes'
  MONO_EXT='.mono'
else
  MONO_FLAG=''
  MONO_EXT=''
fi

if [ $buildLinuxEditor -eq 1 ]; then
  if [ $build32Bits -eq 1 ]; then
    if [ "$buildWithMono" -eq 1 ]; then
      label="Generate the glue for 32 bits editor for Linux"
      echo_header "Running $label"
      if [ $isArchLike -eq 1 ]; then
        echo_info "${orangeOnWhite}32 bit version of mono is not available on this platform. Can not Built${resetColor}"
        result=0
      else
        # Generate the glue
        # -----
        cmdScons platform=x11 bits=32 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
        "$GODOT_DIR/bin/godot.x11.tools.32.mono" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
        rm "$GODOT_DIR/bin/godot.x11.tools.32.mono"

        # Build 32 bits editor
        # -----
        label="Building 32 bits editor for Linux"
        echo_header "Running $label"
        cmdScons platform=x11 bits=32 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
        # Remove symbols and sections from files
        strip "$GODOT_DIR/bin/godot.x11.opt.tools.32${MONO_EXT}"
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
      fi
    fi
  fi
  if [ "$buildWithMono" -eq 1 ]; then
    # Generate the glue
    # -----
    label="Generate the glue for 64 bits editor for Linux"
    echo_header "Running $label"
    cmdScons platform=x11 bits=64 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
    "$GODOT_DIR/bin/godot.x11.tools.64.mono" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    rm "$GODOT_DIR/bin/godot.x11.tools.64.mono"
  fi

  # Build 64 bits editor
  # -----
  label="Building 64 bits editor for Linux"
  echo_header "Running $label"
  cmdScons platform=x11 bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.tools.64${MONO_EXT}"
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build 32 bits export templates
# --------------
if [ $buildLinuxTemplates -eq 1 ]; then
  if [ $build32Bits -eq 1 ] && [ "$buildWithMono" -eq 1 ]; then
    label="Building 32 bits debug export template for Linux"
    echo_header "Running $label"
    if [ $isArchLike -eq 1 ]; then
      echo_info "${orangeOnWhite}32 bit version of mono is not available on this platform. Can not Built${resetColor}"
      result=0
    else
      cmdScons platform=x11 bits=32 tools=no target=debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
      # Remove symbols and sections from files
      strip "$GODOT_DIR/bin/godot.x11.opt.debug.32${MONO_EXT}"
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

      label="Building 32 bits release export template for Linux"
      echo_header "Running $label"
      cmdScons platform=x11 bits=32 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
      # Remove symbols and sections from files
      strip "$GODOT_DIR/bin/godot.x11.opt.32${MONO_EXT}"
      if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi

  # Build 64 bits export templates
  # --------------
  label="Building 64 bits debug export template for Linux"
  echo_header "Running $label"
  cmdScons platform=x11 bits=64 tools=no target=debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.debug.64${MONO_EXT}"
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="Building 64 bits release export template for Linux"
  echo_header "Running $label"
  cmdScons platform=x11 bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  strip "$GODOT_DIR/bin/godot.x11.opt.64${MONO_EXT}"
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
