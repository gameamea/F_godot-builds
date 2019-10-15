#!/bin/bash
#
# This script compiles and packages Godot for various platforms.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# ------------
# BUILDS SETTINGS
#
# these values can be changed to choose what to do in the build process
# ------------

# if set to 1, no question will be ask and default value will be used
export isQuiet=0
# if set to 1, process will be stopped when something fails
export stopOnFail=1
# if set to 1, binaries size will be optimised
export optimisationOn=1
# default answer to yesNo questions
export defaultYN=0

# set to 1 for enabling functionnalities
export buildLinuxEditor=1      #OK noMono32 noMono64
export buildLinuxTemplates=1   #OK noMono32 noMono64
export buildWindowsEditor=1    #OK noMono32 noMono64
export buildWindowsTemplates=1 #OK noMono32 noMono64
export buildMacosEditor=0      #TODO:TEST no mono & TEST Mono
export buildMacosTemplates=0   #TODO:TEST no mono & TEST Mono
export buildServer=0           #TODO:TEST no mono & TEST Mono

# Mobile/Web platforms
export buildAndroid=1 #OK noMono
export buildWeb=1     #OK noMono
export buildIos=0     #TODO

# Deploy
export deploy=0 #TODO: update code after each sucessfull build process added

# Build options

# Also build 32 bits version if possible
export build32Bits=1
# Mono
export buildWithMono=1 #TODO
# Javascript
# By default, the JavaScript singleton will be built into the engine. Since eval() calls can be a security concern.
export buildWithJavascriptSingleton=1

# EMSCRIPTEN version to update:
# note: if latest is chosen, an new update will nearly be dowload each time
# export emscriptenVersion='latest'
export emscriptenVersion='1.38.47'

# `DIR` contains the directory where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any location
# NOTE: can not be moved in variables.sh
export DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The directory where utility scripts are located
export UTILITIES_DIR="$DIR/utilities"

# add some functions
source "$UTILITIES_DIR/functions.sh"

# init variables and settings
source "$UTILITIES_DIR/variables.sh"

mkdir -p "$EDITOR_DIR" "$TEMPLATES_DIR"

echo_header "${greenOnWhite}GODOT ENGINE BUILD SCRIPT"

cd "$GODOT_DIR"

yesNoS "${orangeOnBlack}Do you want to Install or update dependencies" $defaultYN
if [ $result -eq 1 ]; then
  # Install or update dependencies
  "$UTILITIES_DIR/install_dependencies.sh"
fi

# Delete the existing Godot Git repository then clone a fresh copy
yesNoS "${orangeOnBlack}Do you want to remove existing source code and Get an update from git Repo " $defaultYN
if [ $result -eq 1 ]; then
  rm -rf "$GODOT_DIR"
  echo_header "Cloning Godot Git repository from $GODOT_ORIGIN"
  git clone --depth=1 "$GODOT_ORIGIN" "$GODOT_DIR"
else
  yesNoS "Do you want to pull from origin (branch: $GODOT_BRANCH)?" $defaultYN
  if [ $result -eq 1 ]; then
    git fetch origin
    git checkout $GODOT_BRANCH
    git pull origin
  fi
fi

# build Desktop Editor & Templates
#-----

# Linux
[ $buildLinuxEditor -eq 1 ] && "$SCRIPTS_DIR/linux.sh"
# Windows
[ $buildWindowsEditor -eq 1 ] && "$SCRIPTS_DIR/windows.sh"
# MacOS
[ $buildMacosEditor -eq 1 ] && "$SCRIPTS_DIR/macos.sh"
# Server
[ $buildMacosEditor -eq 1 ] && "$SCRIPTS_DIR/server.sh"

# build Other Templates
#-----
# Android
[ $buildAndroid -eq 1 ] && "$SCRIPTS_DIR/android.sh"
# Web
[ $buildWeb -eq 1 ] && "$SCRIPTS_DIR/web.sh"
# IOS
[ $buildIos -eq 1 ] && "$SCRIPTS_DIR/ios.sh"
# UWM
[ $buildIos -eq 1 ] && "$SCRIPTS_DIR/uwp.sh"

# Deploy
[ $deploy -eq 1 ] && "$SCRIPTS_DIR/deploy.sh"

# Doc
[ $deploy -eq 1 ] && "$SCRIPTS_DIR/doc.sh"

echo_header "${blueOnWhite}All Operations finished.${resetColor}"
