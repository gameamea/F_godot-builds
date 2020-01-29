#!/usr/bin/bash

# This script is intended to bypass full build process and make a faster test.
#------
# Test build script for Godot.
# It's a one piece and simplified script used for testing purpose.
# Using main compilation script is better.
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# This script is licensed under CC0 1.0 Universal:
#------

testNumber=5

case "$testNumber" in
  1)

    # 32 bits editor for linux with mono build test
    # generate glue
    scons platform=x11 bits=32 tools=yes target=release_debug mono_glue=no progress=no debug_symbols=no -j4 module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-i686-release

    # build editor
    /mnt/R/Apps_Sources/GodotEngine/_godot/bin/godot.x11.opt.tools.32.mono --generate-mono-glue /mnt/R/Apps_Sources/GodotEngine/_godot/modules/mono/glue
    ;;

  2)
    # X11 with mono (installed)
    # Build temporary binary
    scons p=x11 -j4 tools=yes module_mono_enabled=yes mono_glue=no
    # Generate glue sources
    bin/godot.x11.tools.64.mono --generate-mono-glue modules/mono/glue

    ### Build binaries normally
    # Editor
    scons p=x11 -j4 target=release_debug tools=yes module_mono_enabled=yes
    # Export templates
    scons p=x11 -j4 target=release_debug tools=no module_mono_enabled=yes
    scons p=x11 -j4 target=release tools=no module_mono_enabled=yes
    ;;

  3)
    # X11 with mono compiled (OK)
    # Build temporary binary (OK)
    scons p=x11 -j4 tools=yes module_mono_enabled=yes mono_glue=no mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-x86_64-release

    # Generate glue sources
    bin/godot.x11.tools.64.mono --generate-mono-glue modules/mono/glue mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-x86_64-release

    ### Build binaries normally
    # Editor
    scons p=x11 -j4 target=release_debug tools=yes module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-x86_64-release
    # Export templates
    #scons p=x11 -j4 target=release_debug tools=no module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-x86_64-release
    #scons p=x11 -j4 target=release tools=no module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-x86_64-release
    ;;

  4)
    # X11 32 bits with mono compiled
    # Build temporary binary
    scons p=x11 bits=32 -j4 tools=yes module_mono_enabled=yes mono_glue=no mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-i686-release

    # Generate glue sources
    bin/godot.x11.tools.32.mono --generate-mono-glue modules/mono/glue mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-i686-release

    ### Build binaries normally
    # Editor
    scons p=x11 bits=32 -j4 target=release_debug tools=yes module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-i686-release
    # Export templates
    #scons p=x11 bits=32 -j4 target=release_debug tools=no module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-i686-release
    #scons p=x11 bits=32 -j4 target=release tools=no module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-i686-release
    ;;
    5)
    # HS
    scons p=windows bits=64 tools=yes mono_glue=no debug_symbols=no -j4 module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/windows/mono-installs/desktop-windows-x86_64-release
    # OK
    scons p=x11     bits=64 tools=yes mono_glue=no debug_symbols=no -j4 module_mono_enabled=yes mono_prefix=/mnt/R/Apps_Sources/GodotEngine/godot-builds/tools/mono/linux/mono-installs/desktop-linux-x86_64-release
esac
