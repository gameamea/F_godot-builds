#!/bin/bash

#------
# This script compiles Godot for Windows using MinGW.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal - for the base version
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal - for the updated version
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

MONO_OPTIONS=""
export WINEARCH=win32
export WINEPREFIX="$HOME/.wine32"

echo_warning "actually cross compiling for windows does not work: issue with linking. No solution found"
# ERROR ON LINKING
#/usr/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../x86_64-w64-mingw32/bin/ld: cannot find -lmono-2.0-sgen
#collect2: error: ld returned 1 exit status
#scons: *** [bin/godot.windows.tools.64.mono.exe] Error 1

# no solution by testing static linking with GodotSharp workarround -> link is OK but editor with mono crash due to bad mono version
# see https://github.com/godotengine/godot/issues/34825

# no solution by testing dynamic linking with copying missing files (when building mono) -> no link is possible
# see https://github.com/godotengine/godot/issues/31793

if true && [ $build32Bits -eq 1 ] && [ "$buildWithMono" -eq 1 ]; then
  # ERROR ON LINKING
  # bin/godot.x11.tools.32.mono: error while loading shared libraries: libmonosgen-2.0.so.1: cannot open shared object file: No such file or directory
  echo_warning "Building 32 bits editor for Windows is bypassed due to missing 32bit version of mono"
  echo_warning "Building 32 bits debug export templates for Windows are bypassed due to missing debug version of mono (too long, but can be done if necessary)"
else
  # Build 32 bits editor
  # -----
  if [ $buildWindowsEditor -eq 1 ]; then
    if [ $build32Bits -eq 1 ]; then
      if [ "$buildWithMono" -eq 1 ]; then
        [ ! -z $MONO_PREFIX_WINDOWS ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WINDOWS/mono-installs/desktop-windows-i686-release"
        label="Generate the glue for 32 bits editor for Windows"
        echo_header "Running $label"

        # Build temporary binary
        cmdScons p=windows bits=32 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS

        # Generate the glue
        fixForMonoRestore 32
        "$GODOT_DIR/bin/godot.windows.tools.32${MONO_EXT}.exe" --generate-mono-glue "$GODOT_DIR/modules/mono/glue" $MONO_OPTIONS
        if [ $? -eq 0 ]; then result=1; else result=0; fi
        if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
        rm "$GODOT_DIR/bin/godot.windows.tools.32${MONO_EXT}.exe"
      fi
      # Build the editor
      label="Building 32 bits editor${MONO_EXT} for Windows"
      echo_header "Running $label"

      resultFile="$GODOT_DIR/bin/godot.windows.tools.32${MONO_EXT}.exe"
      rm -f $resultFile
      cmdScons p=windows bits=32 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
      # Remove symbols and sections from files
      x86_64-w64-mingw32-strip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi

  # Build 32 bits export templates
  # --------------
  if [ $buildWindowsTemplates -eq 1 ]; then
    if [ $build32Bits -eq 1 ]; then
      label="Building 32 bits debug export template${MONO_EXT} for Windows"
      echo_header "Running $label"

      [ ! -z $MONO_PREFIX_WINDOWS ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WINDOWS/mono-installs/desktop-windows-i686-debug"
      resultFile="$GODOT_DIR/bin/godot.windows.opt.debug.32${MONO_EXT}.exe"
      rm -f $resultFile
      cmdScons p=windows bits=32 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
      # Remove symbols and sections from files
      x86_64-w64-mingw32-strip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi

      label="Building 32 bits release export template${MONO_EXT} for Windows"
      echo_header "Running $label"

      [ ! -z $MONO_PREFIX_WINDOWS ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WINDOWS/mono-installs/desktop-windows-i686-release"
      resultFile="$GODOT_DIR/bin/godot.windows.opt.32${MONO_EXT}.exe"
      rm -f $resultFile
      cmdScons p=windows bits=32 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
      # Remove symbols and sections from files
      x86_64-w64-mingw32-strip $resultFile
      if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
      if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    fi
  fi
fi

MONO_OPTIONS=""
export WINEARCH=win64
export WINEPREFIX="$HOME/.wine"
# Build 64 bits editor
# -----
if [ $buildWindowsEditor -eq 1 ]; then
  if [ "$buildWithMono" -eq 1 ]; then
    [ ! -z $MONO_PREFIX_WINDOWS ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WINDOWS/mono-installs/desktop-windows-x86_64-release"
    label="Generate the glue for 64 bits editor for Windows"
    echo_header "Running $label"

    # Build temporary binary
    cmdScons p=windows bits=64 tools=yes mono_glue=no $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS

    # Generate the glue
    fixForMonoRestore 64
    "$GODOT_DIR/bin/godot.windows.tools.64${MONO_EXT}.exe" --generate-mono-glue "$GODOT_DIR/modules/mono/glue" $MONO_OPTIONS
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
    rm "$GODOT_DIR/bin/godot.windows.tools.64${MONO_EXT}.exe"
  fi

  # Build the editor
  label="Building 64 bits editor${MONO_EXT} for Windows"
  echo_header "Running $label"

  resultFile="$GODOT_DIR/bin/godot.windows.opt.tools.64${MONO_EXT}.exe"
  rm -f $resultFile
  cmdScons p=windows bits=64 tools=yes target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi

# Build 64 bits export templates
# --------------
if [ $buildWindowsTemplates -eq 1 ]; then
  if [ "$buildWithMono" -eq 1 ]; then
    echo_warning "Building 64 bits debug export templates for Windows are bypassed due to missing debug version of mono (too long, but can be done if necessary)"
  else
    label="Building 64 bits debug export template${MONO_EXT} for Windows"
    echo_header "Running $label"

    [ ! -z $MONO_PREFIX_WINDOWS ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WINDOWS/mono-installs/desktop-windows-x86_64-debug"
    resultFile="$GODOT_DIR/bin/godot.windows.opt.debug.64${MONO_EXT}.exe"
    rm -f $resultFile
    cmdScons p=windows bits=64 tools=no target=release_debug $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
    # Remove symbols and sections from files
    x86_64-w64-mingw32-strip $resultFile
    if [ $? -eq 0 ]; then result=1; else result=0; fi
    if [ $result -easierq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
  fi

  label="Building 64 bits release export template${MONO_EXT} for Windows"
  echo_header "Running $label"

  [ ! -z $MONO_PREFIX_WINDOWS ] && MONO_OPTIONS="$MONO_FLAG $MONO_PREFIX_WINDOWS/mono-installs/desktop-windows-x86_64-release"
  resultFile="$GODOT_DIR/bin/godot.windows.opt.64${MONO_EXT}.exe"
  rm -f $resultFile
  cmdScons p=windows bits=64 tools=no target=release $LTO_FLAG $SCONS_FLAGS $MONO_OPTIONS
  # Remove symbols and sections from files
  x86_64-w64-mingw32-strip $resultFile
  if [ $? -eq 0 ]; then result=1; else result=0; fi
  if [ $result -eq 1 ]; then echo_success "$label built successfully"; else echo_warning "$label built with error"; fi
fi
