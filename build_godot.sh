#!/bin/bash
#
# This script compiles and packages Godot for various platforms.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# add some init

export buildWithMono=0 #TODO

# set to 1 for enabling functionnalities
export buildLinuxEditor=1
export buildLinuxTemplates=1
export buildMacosEditor=0
export buildMacosTemplates=0
export buildWindowsEditor=0
export buildWindowsTemplates=0

# Mobile/Web platforms
export buildWeb=0 #TODO
export buildIos=0   #TODO
export buildAndroid=1

# Deploy
export deploy=0 # TODO

#
# git repo to pull from
# GODOT original
GODOT_ORIGIN="https://github.com/godotengine/godot.git"
# My fork
GODOT_ORIGIN="git@github.com:gameamea/F_godot-builds.git"

# used on some fonction return
export result=0

# Variables

# Android tools path
# If these 2 variables are not set, the tools will be downloaded inside the folder set in TOOLS_DIR
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_NDK_ROOT="/opt/android-ndk"

# `DIR` contains the directory where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any
# location
export DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Specify the number of CPU threads to use as the first command line argument
# If not set, defaults to 1.5 times the number of CPU threads
export THREADS="${1:-"$(($(nproc) * 3 / 2))"}"
export THREADS=$(nproc)

# Common directories used in the script
export SCRIPTS_DIR="$DIR/scripts"

# The directory where utility scripts are located
export UTILITIES_DIR="$DIR/utilities"

# The directory where resource files are located
export RESOURCES_DIR="$DIR/resources"

# The directory where SDKs and tools like InnoSetup are located
export TOOLS_DIR="$DIR/tools"

# The directory where build artifacts will be copied
# EDITOR_DIR and TEMPLATES_DIR are used by platform-specific scripts
export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"

# The directory where the Godot Git repository will be cloned
#export GODOT_DIR="/tmp/godot"
export GODOT_DIR="$scriptFolder/_godot"

# add some functions
source "$UTILITIES_DIR/functions.sh"

# Install or update dependencies
"$UTILITIES_DIR/install_dependencies.sh"

mkdir -p "$EDITOR_DIR" "$TEMPLATES_DIR"

# Delete the existing Godot Git repository (it probably is from an old build)
# then clone a fresh copy
yesNo "Do you want to remove existing source code and Get an update from git Repo "
if [ $result -eq 1 ]; then
  rm -rf "$GODOT_DIR"
  echo_header "Cloning Godot Git repository from $GODOT_ORIGIN"
  git clone --depth=1 "$GODOT_ORIGIN" "$GODOT_DIR"
fi
cd "$GODOT_DIR"

# Set the environment variables used in build naming

# Commit date (not the system date!)
export BUILD_DATE
BUILD_DATE="$(git show -s --format=%cd --date=short)"
# Short (9-character) commit hash
export BUILD_COMMIT
BUILD_COMMIT="$(git rev-parse --short=9 HEAD)"
# The final version string
export BUILD_VERSION="$BUILD_DATE.$BUILD_COMMIT"

# SCons flags to use in all build commands
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"

# Run the scripts

# Desktop platforms
if [ $buildLinuxEditor -eq 1 ]; then "$SCRIPTS_DIR/linux.sh" editor; fi
if [ $buildLinuxTemplates -eq 1 ]; then "$SCRIPTS_DIR/linux.sh" templates; fi
if [ $buildMacosEditor -eq 1 ]; then "$SCRIPTS_DIR/macos.sh" editor; fi
if [ $buildMacosTemplates -eq 1 ]; then "$SCRIPTS_DIR/macos.sh" templates; fi
if [ $buildWindowsEditor -eq 1 ]; then "$SCRIPTS_DIR/windows.sh" editor; fi
if [ $buildWindowsTemplates -eq 1 ]; then "$SCRIPTS_DIR/windows.sh" templates; fi

# Mobile/Web platforms
if [ $buildWeb -eq 1 ]; then "$SCRIPTS_DIR/web.sh"; fi
if [ $buildIos -eq 1 ]; then "$SCRIPTS_DIR/ios.sh"; fi
if [ $buildAndroid -eq 1 ]; then "$SCRIPTS_DIR/android.sh"; fi

# Deploy

if [ $deploy -eq 1 ]; then "$SCRIPTS_DIR/deploy.sh"; fi
