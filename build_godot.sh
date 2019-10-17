#!/bin/bash
#
# This script compiles and packages Godot for various platforms.
# Using This script for build is preferable
#------
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal - for the base version
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal - for the updated version
# See `LICENSE.md` included in the source distribution for details.
#------

set -euo pipefail

# ------------
# BUILDS SETTINGS
#
# these values can be changed to choose what to do in the build process
# ------------

# if set to 1, no question will be ask and default value will be used
export isQuiet=1
# if set to 1, process will be stopped when something fails
export stopOnFail=0
# if set to 1, binaries size will be optimised
export optimisationOn=0
# default answer to yesNo questions
export defaultYN=1
# default answer to yesNo questions for important elements
export importantYN=0

# set to 1 for enabling functionnalities
export buildLinuxEditor=1      # normal32:OK normal64:OK mono64:OK mono32:unavailable
export buildLinuxTemplates=1   # normal32:OK normal64:OK mono64:OK mono32:unavailable
export buildWindowsEditor=0    # normal32:OK normal64:OK mono:BUG cross build
export buildWindowsTemplates=0 # normal32:OK normal64:OK mono:BUG cross build
export buildMacosEditor=0      #TODO:TEST no mono & TEST Mono
export buildMacosTemplates=0   #TODO:TEST no mono & TEST Mono
export buildUWPEditor=0        #TODO:TEST no mono & TEST Mono
export buildUWPTemplates=0     #TODO:TEST no mono & TEST Mono

# Mobile/Web/Other platforms
export buildServer=0  # normal32:OK normal64:OK mono:unavailable
export buildAndroid=0 # normal32:OK normal64:OK mono:BUG JS (Cannot create service of type PayloadSerializer )
export buildWeb=0     # normal32:OK normal64:OK mono:unavailable
export buildIos=0     #TODO
export buildDoc=0     #TODO

# Deploy
export deploy=1 #TODO: update code after each sucessfull build process added

# ------------
# BUILD OPTIONS
#
# these values can be changed to change the build process
# ------------
# Build 32 bits version if possible
export build32Bits=0

# Build with mono if possible
export buildWithMono=1

# Web/Javascript option
# By default, the JavaScript singleton will be built into the engine. Since eval() calls can be a security concern.
export buildWithJavascriptSingleton=1

# EMSCRIPTEN version to update on dependencies:
# note: if latest is chosen, an new update will nearly be dowload each time
# export emscriptenVersion='latest'
export emscriptenVersion='1.38.47'

# ------------
# UMOVABLE VARIABLES
# ------------
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

# Deploy
export deploy=1 #TODO: update code after each sucessfull build process added

# log file name
export deployLogOK="$DIR/deploy_OK_$(date +%Y-%m-%d).log"
export deployLogHS="$DIR/deploy_HS_$(date +%Y-%m-%d).log"

# ------------
# START
# ------------
# init logs
initLog $deployLogHS
initLog $deployLogOK

mkdir -p "$EDITOR_DIR" "$TEMPLATES_DIR"

echo_header "${greenOnWhite}GODOT ENGINE BUILD SCRIPT"
echo_info "${blueOnWhite}Source folder: $GODOT_DIR"

cd "$GODOT_DIR"

yesNoS "${orangeOnBlack}Do you want to Install or update dependencies" $importantYN
if [ $result -eq 1 ]; then
  # Install or update dependencies
  "$UTILITIES_DIR/install_dependencies.sh"
fi

# Delete the existing Godot Git repository then clone a fresh copy
yesNoS "${orangeOnBlack}Do you want to remove existing source code and Get an update from git Repo " $importantYN
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

# exeemple of a quick build for testing purpose
if false; then
  scons platform=android target=release android_arch=armv7
  scons platform=android target=release android_arch=arm64v8
  cd platform/android/java
  rm -Rf "$GODOT_DIR/platform/android/java/build/"
  ./gradlew build
  exit
fi

# build Desktop Editor & Templates
#-----

# Linux
if [ $buildLinuxEditor -eq 1 ] || [ $buildLinuxTemplates -eq 1 ]; then "$SCRIPTS_DIR/linux.sh"; fi
# Windows
if [ $buildWindowsEditor -eq 1 ] || [ $buildWindowsTemplates -eq 1 ]; then "$SCRIPTS_DIR/windows.sh"; fi
# MacOS
if [ $buildMacosEditor -eq 1 ] || [ $buildMacosTemplates -eq 1 ]; then "$SCRIPTS_DIR/macos.sh"; fi
# UWP
if [ $buildUWPEditor -eq 1 ] || [ $buildUWPTemplates -eq 1 ]; then "$SCRIPTS_DIR/uwp.sh"; fi

# build Other Templates
#-----
# Server
[ $buildServer -eq 1 ] && "$SCRIPTS_DIR/server.sh"
# Android
[ $buildAndroid -eq 1 ] && "$SCRIPTS_DIR/android.sh"
# Web
[ $buildWeb -eq 1 ] && "$SCRIPTS_DIR/web.sh"
# IOS
[ $buildIos -eq 1 ] && "$SCRIPTS_DIR/ios.sh"

# Doc
[ $buildDoc -eq 1 ] && "$SCRIPTS_DIR/doc.sh"

# Deploy
[ $deploy -eq 1 ] && "$SCRIPTS_DIR/deploy.sh"

echo_header "${blueOnWhite}All Operations finished.${resetColor}"
