#!/bin/bash

#------
# This script compiles and packages Godot for Windows using MinGW and InnoSetup.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail
# line just for easier comparison with linux.h

# Build 32 bits editor
# -----
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
        cmdScons platform=windows bits=32 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
        "$GODOT_DIR/bin/godot.windows.tools.32.mono.exe" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
        rm "$GODOT_DIR/bin/godot.windows.tools.32.mono.exe"
      fi
      # Build the editor
      label="Building 32 bits editor${MONO_EXT} for Windows"
      echo_header "Running $label"
      resultFile="$GODOT_DIR/bin/godot.windows.opt.tools.32${MONO_EXT}.exe"
      rm -f $resultFile
      cmdScons platform=windows bits=32 tools=yes $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
      # Remove symbols and sections from files
      x86_64-w64-mingw32-strip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi
fi
# Build 32 bits export templates
# --------------
if [ $buildWindowsTemplates -eq 1 ]; then
  label="Building 32 bits debug export template${MONO_EXT} for Windows"
  echo_header "Running $label"
  if [ $build32Bits -eq 1 ]; then
    #if [ $isWindows64 -eq 1 ]; then
    #  echo_info "${orangeOnWhite}32 bit version of mono is not available on this platform. Can not Built${resetColor}"
    #  result=0
    #else
    resultFile="$GODOT_DIR/bin/godot.windows.opt.debug.32${MONO_EXT}.exe"
    rm -f $resultFile
    cmdScons platform=windows bits=32 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
    # Remove symbols and sections from files
    x86_64-w64-mingw32-strip $resultFile
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

    label="32 bits release export template${MONO_EXT} for Windows"
    echo_header "Running $label"
    resultFile="$GODOT_DIR/bin/godot.windows.opt.32${MONO_EXT}.exe"
    rm -f $resultFile
    cmdScons platform=windows bits=32 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
    # Remove symbols and sections from files
    x86_64-w64-mingw32-strip $resultFile
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    #fi
  fi
fi

# Build 64 bits editor
# -----
if [ $buildWindowsEditor -eq 1 ]; then
  if [ "$buildWithMono" -eq 1 ]; then
    # Generate the glue
    label="Generate the glue for 64 bits editor for Windows"
    echo_header "Running $label"
    cmdScons platform=windows bits=64 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
    "$GODOT_DIR/bin/godot.windows.tools.64.mono.exe" --generate-mono-glue "$GODOT_DIR/modules/mono/glue"
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    rm "$GODOT_DIR/bin/godot.windows.tools.64.mono.exe"
  fi

  # Build the editor
  label="Building 64 bits editor${MONO_EXT} for Windows"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.windows.opt.tools.64${MONO_EXT}.exe"
  rm -f $resultFile
  cmdScons platform=windows bits=64 tools=yes $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build 64 bits export templates
# --------------
if [ $buildWindowsTemplates -eq 1 ]; then
  label="Building 64 bits debug export template${MONO_EXT} for Windows"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.windows.opt.debug.64${MONO_EXT}.exe"
  rm -f $resultFile
  cmdScons platform=windows bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

  label="Building 64 bits release export template${MONO_EXT} for Windows"
  echo_header "Running $label"
  resultFile="$GODOT_DIR/bin/godot.windows.opt.64${MONO_EXT}.exe"
  rm -f $resultFile
  cmdScons platform=windows bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_FLAG
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
