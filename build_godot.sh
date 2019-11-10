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

#set -euo
set -e

# ------------
# FIX BUILDS SETTINGS
#
# these values are default values and can be changed to choose what to do in the build process
# ------------

# if set to 1, no question will be ask and default value will be used
export isQuiet=1
# if set to 1, process will be stopped when something fails
export stopOnFail=0
# if set to 1, binaries size will be optimised
export isBinSizeOptimised=1
# if set to 1, linking will be optimised. NOTE: Process is very long
export isLinkingOptimised=0
# default answer to yesNo questions
export defaultYN=0
# default answer to yesNo questions for important elements
export importantYN=0
# index of the git repo to use for build (see list in variables.sh). set to 0 to use official godot
export gitRepoIndex=0

# ------------
# CHANGING BUILDS SETTINGS
#
# these values are default values and can be changed BY ASKING TO USER
# if isQuiet=0, some of them will be asked to user
# ------------

# Desktop platforms
export buildLinuxEditor=1      # normal32:OK normal64:OK mono64:OK mono32:unavailable
export buildLinuxTemplates=1   # normal32:OK normal64:OK mono64:OK mono32:unavailable
export buildWindowsEditor=0    # normal32:OK normal64:OK mono:BUG cross build
export buildWindowsTemplates=0 # normal32:OK normal64:OK mono:BUG cross build
export buildMacosEditor=0      #TODO:TEST no mono & TEST Mono
export buildMacosTemplates=0   #TODO:TEST no mono & TEST Mono
export buildUWPTemplates=0     #TODO:TEST no mono & TEST Mono

# Mobile/Web/Other platforms
export buildServer=0  # normal32:OK normal64:OK mono:unavailable
export buildAndroid=0 # normal32:OK normal64:OK mono:BUG JS (Cannot create service of type PayloadSerializer )
export buildWeb=0     # normal32:OK normal64:OK mono:unavailable
export buildIos=0     #TODO
export buildDoc=0     #TODO

# Build 32 bits version if possible
export build32Bits=0

# Build with mono if possible
export buildWithMono=1

# Deploy
export deploy=1 #TODO: update code after each sucessfull build process added

# ------------
# BUILD OPTIONS
#
# these values can be changed to customize the build process
# ------------

# Web/Javascript option
# By default, the JavaScript singleton will be built into the engine. Since eval() calls can be a security concern.
export buildWithJavascriptSingleton=1

# EMSCRIPTEN version to update on dependencies:
# note: if latest is chosen, an new update will nearly be dowload each time
# export emscriptenVersion='latest'
export emscriptenVersion='1.38.47'

# read command line options
while [ -n "$1" ]; do
  #echo_info "parameter=$1"
  case "$1" in
    -h | --help)
      usage
      ;;
    -q | --quiet)
      isQuiet=1
      ;;
    -g | --gitrepoindex)
      export gitRepoIndex=$2
      shift
      ;;
    --)
      # The double dash makes them parameters
      shift
      break
      ;;
    *) folder=$1 ;;
  esac
  shift
done

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

# log file name
export deployLogOK="$DIR/deploy_OK_$(date +%Y-%m-%d).log"
export deployLogHS="$DIR/deploy_HS_$(date +%Y-%m-%d).log"

# ------------
# UMOVABLE FUNCTIONS
# ------------

# print script usage and help
function usage() {
  echo ""
  echo "Usage:"
  echo "$(basename $0) [folder]"
  echo "Result:"
  echo " Build godot engine editor and templates from local source with several options."
  echo "Command line options:"
  echo " -h |--help  : Show this help."
  echo " -q |--quiet : Stop asking for user input (automatic or batch mode)."
  echo " -g |--gitrepoindex : Index of the git repo to use for build (see list in variables.sh)."
  echo "Notes:"
  echo " Settings at the start of this file can be changed to custom build process."
  echo " Some less important variables can also be edited in ./utilities/variables.sh  file."
  exit 0
}

# ------------
# START
# ------------

# ASK USER
if [ $isQuiet -eq 0 ]; then
  yesNoS "Do you want to build Linux Editor"
  if [ $result -eq 1 ]; then export buildLinuxEditor=1; fi
  yesNoS "Do you want to build Linux Templates"
  if [ $result -eq 1 ]; then export buildLinuxTemplates=1; fi
  yesNoS "Do you want to build Windows Editor"
  if [ $result -eq 1 ]; then export buildWindowsEditor=1; fi
  yesNoS "Do you want to build Windows Templates"
  if [ $result -eq 1 ]; then export buildWindowsTemplates=1; fi
  yesNoS "Do you want to build Mac Os Editor"
  if [ $result -eq 1 ]; then export buildMacosEditor=1; fi
  yesNoS "Do you want to build Mac Os Templates"
  if [ $result -eq 1 ]; then export buildMacosTemplates=1; fi
  yesNoS "Do you want to build UWP Templates"
  if [ $result -eq 1 ]; then export buildUWPTemplates=1; fi
  yesNoS "Do you want to build Server binaries"
  if [ $result -eq 1 ]; then export buildServer=1; fi
  yesNoS "Do you want to build Android Templates"
  if [ $result -eq 1 ]; then export buildAndroid=1; fi
  yesNoS "Do you want to build Web Templates"
  if [ $result -eq 1 ]; then export buildWeb=1; fi
  yesNoS "Do you want to build Ios Templates"
  if [ $result -eq 1 ]; then export buildIos=1; fi
  yesNoS "Do you want to build Doc"
  if [ $result -eq 1 ]; then export buildDoc=1; fi
  yesNoS "Do you want to build 32 Bits versions (64 bits version will always be built)"
  if [ $result -eq 1 ]; then export build32Bits=1; fi
  yesNoS "Do you want to build with Mono"
  if [ $result -eq 1 ]; then export buildWithMono=1; fi
  yesNoS "Do you want to deploy binaries"
  if [ $result -eq 1 ]; then export deploy=1; fi
fi

# init logs
initLog $deployLogHS
initLog $deployLogOK

mkdir -p "$EDITOR_DIR" "$TEMPLATES_DIR"

echo_header "GODOT ENGINE BUILD SCRIPT"
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

# exemple of a quick build for testing purpose
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

# build Other Templates
#-----
# UWP
if [ $buildUWPTemplates -eq 1 ]; then "$SCRIPTS_DIR/uwp.sh"; fi
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
