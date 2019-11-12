#!/bin/bash

#------
# This script copy generated files at specifics places and runs some packaging tools.
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# create version file in the template dir
touch "$TEMPLATES_DIR/version.txt"
echo ${GDVERSION}${MONO_EXT} > "$TEMPLATES_DIR/version.txt"

# update version in innosetup config file
sed -i "s/#define MyAppVersion.*/#define MyAppVersion \"$GDVERSION\"/g" "$RESOURCES_DIR/windows/godot.iss"

## --------
## LINUX
## --------
label="Linux 32 bit Editor"
echo_header "Deploying $label"
### Copy Linux 32 bit editor binary
cpcheck "$GODOT_DIR/bin/godot.x11.opt.tools.32${MONO_EXT}" "$EDITOR_DIR/godot_32${MONO_EXT}"
if [ $buildWithMono -eq 1 ]; then
  ### Copy Mono Linux Editor Data Folder
  ### check if GodotSharp is identical with 32 ou 64 bit built
  cpcheck "$GODOT_DIR/bin/GodotSharp" "$EDITOR_DIR" -r
  # change name to match godot standard
  [ -r "$EDITOR_DIR/godot_32${MONO_EXT}" ] && mv "$EDITOR_DIR/godot_32${MONO_EXT}" "$EDITOR_DIR/godot_32-mono"
fi
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
### Copy Linux 32 bit export templates
label="Linux 32 bit templates"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.debug.32${MONO_EXT}" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.32${MONO_EXT}" "$TEMPLATES_DIR"
if [ $buildWithMono -eq 1 ]; then
  ### Copy Mono Linux Templates Data Folder
  cpcheck "$GODOT_DIR/bin/data.mono.x11.32.release_debug" "$TEMPLATES_DIR" -r
  cpcheck "$GODOT_DIR/bin/data.mono.x11.32.release" "$TEMPLATES_DIR" -r
fi
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

### Copy Linux 64 bit editor binary
label="Linux 64 bit Editor"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.tools.64${MONO_EXT}" "$EDITOR_DIR/godot${MONO_EXT}"
if [ $buildWithMono -eq 1 ]; then
  ### Copy Mono Linux Editor Data Folder
  ### check if GodotSharp is identical with 32 ou 64 bit built
  cpcheck "$GODOT_DIR/bin/GodotSharp" "$EDITOR_DIR" -r
  # change name to match godot standard
  [ -r "$EDITOR_DIR/godot${MONO_EXT}" ] && mv "$EDITOR_DIR/godot${MONO_EXT}" "$EDITOR_DIR/godot-mono"
fi
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
### Copy Linux 64 bit export templates
label="Linux 64 bit templates"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.debug.64${MONO_EXT}" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.x11.opt.64${MONO_EXT}" "$TEMPLATES_DIR"
if [ $buildWithMono -eq 1 ]; then
  ### Copy Mono Linux Templates Data Folder
  cpcheck "$GODOT_DIR/bin/data.mono.x11.64.release_debug" "$TEMPLATES_DIR" -r
  cpcheck "$GODOT_DIR/bin/data.mono.x11.64.release" "$TEMPLATES_DIR" -r
fi
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

## --------
## Windows
## --------
### Copy Windows 32 bit editor binary
label="Windows 32 bit Editor & packaging"
echo_header "Deploying $label"
mkdir -p "$EDITOR_DIR/x86/Godot"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.tools.32${MONO_EXT}.exe" "$EDITOR_DIR/x86/Godot/godot.exe"
if [ $result -eq 1 ]; then
  if [ $buildWithMono -eq 1 ]; then
    ### Copy Mono Windows Editor Data Folder
    ### check if GodotSharp is identical with 32 ou 64 bit built
    cpcheck "$GODOT_DIR/bin/GodotSharp" "$EDITOR_DIR/x86/Godot/" -r
  fi
  ### Create Windows 32-bit ZIP archives
  ### TODO Add mono options for mono and mono data folder copy
  cd "$EDITOR_DIR/x86"
  zip -r9 "Godot-Windows-x86.zip" "Godot"
  ### Prepare Windows installer generation
  echo_header "Generating Windows installers…"
  cd "$EDITOR_DIR"
  cp "$RESOURCES_DIR/windows/godot.iss" "."
  ### Generate Windows 32-bit installer
  cpcheck "$EDITOR_DIR/x86/Godot/godot.exe" "."
  wine "$ISCC" "godot.iss" /DApp32Bit
  ### Copy installers to the artifacts path
  cpcheck "$EDITOR_DIR/Output/godot-windows-installer-x86.exe" "$EDITOR_DIR/Godot-Windows-x86.exe"
  if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
fi
### Remove temporary directories
rm -Rf "$EDITOR_DIR/x86"
rm -Rf "$EDITOR_DIR/Output"

### Copy Windows 32 bit export templates
label="Windows 32 bit templates"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.debug.32${MONO_EXT}.exe" "$TEMPLATES_DIR/windows_32_debug${MONO_EXT}.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.32${MONO_EXT}.exe" "$TEMPLATES_DIR/windows_32_release${MONO_EXT}.exe"
if [ $buildWithMono -eq 1 ]; then
  ### Copy Mono Windows Templates Data Folder
  cpcheck "$GODOT_DIR/bin/data.mono.windows.32.release_debug" "$TEMPLATES_DIR" -r
  cpcheck "$GODOT_DIR/bin/data.mono.windows.32.release" "$TEMPLATES_DIR" -r
fi
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

### Copy Windows 64 bit editor binary
label="Windows 64 bit Editor & packaging"
echo_header "Deploying $label"
mkdir -p "$EDITOR_DIR/x86_64/Godot"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.tools.64${MONO_EXT}.exe" "$EDITOR_DIR/x86_64/Godot/godot.exe"
if [ $result -eq 1 ]; then
  if [ $buildWithMono -eq 1 ]; then
    ### Copy Mono Windows Editor Data Folder
    ### check if GodotSharp is identical with 32 ou 64 bit built
    cpcheck "$GODOT_DIR/bin/GodotSharp" "$EDITOR_DIR/x86_64/Godot/" -r
  fi
  ### Create Windows 64-bit ZIP archives
  ### TODO Add mono options for mono and mono data folder copy
  cd "$EDITOR_DIR/x86_64"
  zip -r9 "Godot-Windows-x86_64.zip" "Godot"
  ### Prepare Windows installer generation
  echo_header "Generating Windows installers…"
  cd "$EDITOR_DIR"
  cp "$RESOURCES_DIR/windows/godot.iss" "."
  ### Generate Windows 64-bit installer
  cpcheck "$EDITOR_DIR/x86_64/Godot/godot.exe" "."
  wine "$ISCC" "godot.iss"
  ### Copy installers to the artifacts path
  cpcheck "$EDITOR_DIR/Output/godot-windows-installer-x86_64.exe" "$EDITOR_DIR/Godot-Windows-x86_64.exe"
  if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
fi
### Remove temporary directories
rm -Rf "$EDITOR_DIR/x86_64"
rm -Rf "$EDITOR_DIR/Output"

### Copy Windows 64 bit export templates
label="Windows 64 bit templates"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.debug.64${MONO_EXT}.exe" "$TEMPLATES_DIR/windows_64_debug${MONO_EXT}.exe"
cpcheck "$GODOT_DIR/bin/godot.windows.opt.64${MONO_EXT}.exe" "$TEMPLATES_DIR/windows_64_release${MONO_EXT}.exe"
if [ $buildWithMono -eq 1 ]; then
  ### Copy Mono Windows Templates Data Folder
  cpcheck "$GODOT_DIR/bin/data.mono.windows.64.release_debug" "$TEMPLATES_DIR" -r
  cpcheck "$GODOT_DIR/bin/data.mono.windows.64.release" "$TEMPLATES_DIR" -r
fi
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

## --------
## MacOs
## --------
### Copy MacOs 64 bit editor binary
label="MacOs 64 bit Editor"
echo_header "Deploying $label"
### TODO Add mono options for mono and mono data folder copy
cp -r "$GODOT_DIR/misc/dist/osx_tools.app" "$GODOT_DIR/bin/Godot.app"
mkdir -p "$GODOT_DIR/bin/Godot.app/Contents/MacOS"
cpcheck "$GODOT_DIR/bin/godot.osx.opt.tools.64" "$GODOT_DIR/bin/Godot.app/Contents/MacOS/Godot"
if [ $result -eq 1 ]; then
  cd "$GODOT_DIR/bin"
  zip -r9 "Godot-macOS-x86_64.zip" "Godot.app"
  cd "$GODOT_DIR"
  ### Move the generated ZIP archive to the editor artifacts directory
  cpcheck "$GODOT_DIR/bin/Godot-macOS-x86_64.zip" "$EDITOR_DIR"
  if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
fi
### Copy MacOs 64 bit export templates
label="MacOs 64 bit templates"
echo_header "Deploying $label"
### TODO Add mono options for mono and mono data folder copy
cpcheck "$GODOT_DIR/bin/godot.osx.opt.debug.64" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/godot.osx.opt.64" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

## --------
## Other templates
## --------

### Copy Android export templates
label="Android templates"
echo_header "Deploying $label"
### TODO Add mono options for mono and mono data folder copy
cpcheck "$GODOT_DIR/bin/android_debug.apk" "$TEMPLATES_DIR"
cpcheck "$GODOT_DIR/bin/android_release.apk" "$TEMPLATES_DIR"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

### Copy Web export templates
label="Web templates"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot.javascript.opt.debug.zip" "$TEMPLATES_DIR/webassembly_debug.zip"
cpcheck "$GODOT_DIR/bin/godot.javascript.opt.zip" "$TEMPLATES_DIR/webassembly_release.zip"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi

### Copy Server export templates
label="Server templates"
echo_header "Deploying $label"
cpcheck "$GODOT_DIR/bin/godot_server.x11.opt.debug.32" "$TEMPLATES_DIR/linux_server_32"
cpcheck "$GODOT_DIR/bin/godot_server.x11.opt.debug.64" "$TEMPLATES_DIR/linux_server_64"
if [ $result -eq 1 ]; then echo_success "$label deployed successfully"; else echo_warning "$label not found"; fi
