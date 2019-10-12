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
echo $GDVERSION > "$TEMPLATES_DIR/version.txt"

# update version in innosetup config file
sed -i "s/#define MyAppVersion.*/#define MyAppVersion \"$GDVERSION\"/g" "$RESOURCES_DIR/windows/godot.iss"

label="Linux 32 bit Editor"
# --------
# Copy Linux 32 bit editor binary
cpcheck "$GODOT_DIR/bin/godot.x11.opt.tools.32" "$EDITOR_DIR/godot_32"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Linux 64 bit Editor"
# --------
# Copy Linux 64 bit editor binary
cpcheck "$GODOT_DIR/bin/godot.x11.opt.tools.64" "$EDITOR_DIR/godot_32"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Linux 32 bit templates"
# --------
# Copy Linux 32 bit export templates
cpcheck "$GODOT_DIR/bin/godot.x11.opt.debug.32" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.32" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Linux 64 bit templates"
# --------
# Copy Linux 64 bit export templates
cpcheck "$GODOT_DIR/bin/godot.x11.opt.debug.64" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.64" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Windows 32 bit Editor & packaging"
# --------
# Create Windows 32-bit ZIP archives
cd "$EDITOR_DIR/x86"
zip -r9 "Godot-Windows-x86.zip" "Godot"

# Prepare Windows installer generation
echo_header "Generating Windows installers…"
cd "$EDITOR_DIR"
cp "$RESOURCES_DIR/windows/godot.iss" "."

# Generate Windows 32-bit installer
cpcheck "$EDITOR_DIR/x86/Godot/godot.exe" "."
wine "$ISCC" "godot.iss" /DApp32Bit

# Copy installers to the artifacts path
cpcheck "$EDITOR_DIR/Output/godot-windows-installer-x86.exe" "$EDITOR_DIR/Godot-Windows-x86.exe"

# Remove temporary directories
rmdir "$EDITOR_DIR/x86"
rmdir "$EDITOR_DIR/Output"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Windows 64 bit Editor & packaging"
# --------
# Create Windows 64-bit ZIP archives
cd "$EDITOR_DIR/x86_64"
zip -r9 "Godot-Windows-x86_64.zip" "Godot"

# Prepare Windows installer generation
echo_header "Generating Windows installers…"
cd "$EDITOR_DIR"
cp "$RESOURCES_DIR/windows/godot.iss" "."

# Generate Windows 64-bit installer
cpcheck "$EDITOR_DIR/x86_64/Godot/godot.exe" "."
wine "$ISCC" "godot.iss"

# Copy installers to the artifacts path
cpcheck "$EDITOR_DIR/Output/godot-windows-installer-x86_64.exe" "$EDITOR_DIR/Godot-Windows-x86_64.exe"

# Remove temporary directories
rmdir "$EDITOR_DIR/x86_64"
rmdir "$EDITOR_DIR/Output"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Windows 32 bit templates"
# --------
# Copy Windows 32 bit export templates
cpcheck "$GODOT_DIR/bin/godot.windows.opt.32.exe" "$TEMPLATES_DIR/windows_32_release.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe" "$TEMPLATES_DIR/windows_32_debug.exe"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Windows 64 bit templates"
# --------
# Copy Windows 64 bit export templates
cpcheck "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe" "$TEMPLATES_DIR/windows_64_debug.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.64.exe" "$TEMPLATES_DIR/windows_64_release.exe"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="MacOs 64 bit Editor"
# --------
# Copy MacOs 64 bit editor binary
cp -r "$GODOT_DIR/misc/dist/osx_tools.app" "$GODOT_DIR/bin/Godot.app"
mkdir -p "$GOODT_DIR/bin/Godot.app/Contents/MacOS"
mv "$GODOT_DIR/bin/godot.osx.opt.tools.64" "$GODOT_DIR/bin/Godot.app/Contents/MacOS/Godot"
cd "$GODOT_DIR/bin"
zip -r9 "Godot-macOS-x86_64.zip" "Godot.app"
cd "$GODOT_DIR"

# Move the generated ZIP archive to the editor artifacts directory
cpcheck "$GODOT_DIR/bin/Godot-macOS-x86_64.zip" "$EDITOR_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="MacOs 64 bit templates"
# --------
# Copy MacOs 64 bit export templates
cpcheck "$GODOT_DIR/bin/godot.osx.opt.64" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.osx.opt.debug.64" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Android templates"
# --------
# Copy Android export templates
cpcheck "$GODOT_DIR/bin/android_debug.apk" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/android_release.apk" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

label="Web templates"
# --------
# Copy Web export templates
cpcheck "$GODOT_DIR/bin/godot.javascript.opt.zip" "$TEMPLATES_DIR/webassembly_release.zip"
cpcheck "$GODOT_DIR/bin/godot.javascript.opt.debug.zip" "$TEMPLATES_DIR/webassembly_debug.zip"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
