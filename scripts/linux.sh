#!/bin/bash

#------
# This script compiles Godot for Linux.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal - for the base version
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal - for the updated version
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
MONO_OPTIONS=""

echo_info "NOTE: Linux binaries usually won’t run on distributions that are older than the distribution they were built on. If you wish to distribute binaries that work on most distributions, you should build them on an old distribution such as Ubuntu 16.04. You can use a virtual machine or a container to set up a suitable build environment."

if [ $build32Bits -eq 1 ] && [ "$buildWithMono" -eq 1 ]; then
  echo_warning "Building 32 bits editor for Linux is bypassed due to missing 32bit version of mono"
  echo_warning "Building 32 bits debug export templates for Linux are bypassed due to missing debug version of mono (too long, but can be done if necessary)"
else
  # Build 32 bits editor
  # -----
  if [ $buildLinuxEditor -eq 1 ]; then
    if [ $build32Bits -eq 1 ]; then
      if [ "$buildWithMono" -eq 1 ]; then
        [ ! -z $MONO_PREFIX_LINUX ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_LINUX/mono-installs/desktop-linux-i686-release"
        label="Generate the glue for 32 bits editor for Linux"
        echo_header "Running $label"
        # Build temporary binary
        cmdScons p=x11 bits=32 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
        # Generate the glue
        "$GODOT_DIR/bin/godot.x11.tools.32${MONO_EXT}" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
        rm "$GODOT_DIR/bin/godot.x11.tools.32${MONO_EXT}"
      fi
      # Build the editor
      label="Building 32 bits editor${MONO_EXT} for Linux"
      echo_header "Running $label"
      resultFile="$GODOT_DIR/bin/godot.x11.tools.32${MONO_EXT}"
      rm -f $resultFile
      cmdScons p=x11 bits=32 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
      # Remove symbols and sections from files
      cmdUpxStrip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi

  # Build 32 bits export templates
  # --------------
  if [ $buildLinuxTemplates -eq 1 ]; then
    if [ $build32Bits -eq 1 ]; then

      label="Building 32 bits debug export template${MONO_EXT} for Linux"
      echo_header "Running $label"
      [ ! -z $MONO_PREFIX_LINUX ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_LINUX/mono-installs/desktop-linux-i686-debug"
      resultFile="$GODOT_DIR/bin/godot.x11.opt.debug.32${MONO_EXT}"
      rm -f $resultFile
      cmdScons p=x11 bits=32 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
      # Remove symbols and sections from files
      cmdUpxStrip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

      label="Building 32 bits release export template${MONO_EXT} for Linux"
      echo_header "Running $label"
      [ ! -z $MONO_PREFIX_LINUX ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_LINUX/mono-installs/desktop-linux-i686-release"
      resultFile="$GODOT_DIR/bin/godot.x11.opt.32${MONO_EXT}"
      rm -f $resultFile
      cmdScons p=x11 bits=32 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
      # Remove symbols and sections from files
      cmdUpxStrip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi
fi
MONO_OPTIONS=""

# Build 64 bits editor
# -----
if [ $buildLinuxEditor -eq 1 ]; then
  if [ "$buildWithMono" -eq 1 ]; then
    [ ! -z $MONO_PREFIX_LINUX ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_LINUX/mono-installs/desktop-linux-x86_64-release"
    label="Generate the glue for 64 bits editor for Linux"
    echo_header "Running $label"
    # Build temporary binary
    cmdScons p=x11 bits=64 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
    # Generate the glue
    "$GODOT_DIR/bin/godot.x11.tools.64${MONO_EXT}" --generate-mono-glue "$GODOT_DIR/modules/mono/glue" $MONO_OPTIONS
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    rm "$GODOT_DIR/bin/godot.x11.tools.64${MONO_EXT}"
  fi

  # Build the editor
  label="Building 64 bits editor${MONO_EXT} for Linux"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.x11.opt.tools.64${MONO_EXT}"
  rm -f $resultFile
  cmdScons p=x11 bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  # Remove symbols and sections from files
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build 64 bits export templates
# --------------
if [ $buildLinuxTemplates -eq 1 ]; then
  if [ "$buildWithMono" -eq 1 ]; then
    echo_warning "Building 64 bits debug export templates for Linux are bypassed due to missing debug version of mono (too long, but can be done if necessary)"
  else
    label="Building 64 bits debug export template${MONO_EXT} for Linux"
    echo_header "Running $label"
    [ ! -z $MONO_PREFIX_LINUX ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_LINUX/mono-installs/desktop-linux-x86_64-debug"
    resultFile="$GODOT_DIR/bin/godot.x11.opt.debug.64${MONO_EXT}"
    rm -f $resultFile
    cmdScons p=x11 bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
    # Remove symbols and sections from files
    cmdUpxStrip $resultFile
    if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
  fi

  label="Building 64 bits release export template${MONO_EXT} for Linux"
  echo_header "Running $label"
  [ ! -z $MONO_PREFIX_LINUX ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_LINUX/mono-installs/desktop-linux-x86_64-release"
  resultFile="$GODOT_DIR/bin/godot.x11.opt.64${MONO_EXT}"
  rm -f $resultFile
  cmdScons p=x11 bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  # Remove symbols and sections from files
  cmdUpxStrip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
