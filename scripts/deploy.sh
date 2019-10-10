#!/bin/bash

#------
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

echo_header "Deploy Files"

# create version file in the template dir
touch "$TEMPLATES_DIR/version.txt"
echo $GDVERSION >> "$TEMPLATES_DIR/version.txt"

label="Linux Editor"
# --------
# Copy the X11 editor binary
cpcheck "$GODOT_DIR/bin/godot.x11.opt.tools.64" "$EDITOR_DIR/godot"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.tools.32" "$EDITOR_DIR/godot_32"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Linux templates"
# --------
# Copy export templates
cpcheck "$GODOT_DIR/bin/godot.x11.opt.debug.64" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.64" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.debug.32" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.32" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Windows templates"
# --------
# Copy export templates
cpcheck "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe" "$TEMPLATES_DIR/windows_64_debug.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe" "$TEMPLATES_DIR/windows_32_debug.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.64.exe" "$TEMPLATES_DIR/windows_64_release.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.32.exe" "$TEMPLATES_DIR/windows_32_release.exe"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Android templates"
# --------
# Copy export templates
cpcheck "$GODOT_DIR/bin/android_debug.apk" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/android_release.apk" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
