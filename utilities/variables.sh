#!/usr/bin/env bash

#------
# Helper varialbles
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/
#------

# ------------
# SETTINGS
#
# these values can be changed to customize the build process
# ------------

#
# git repo to pull from
# GODOT original
# GODOT_ORIGIN="https://github.com/godotengine/godot.git"
#GODOT_BRANCH="master"
# Frug version : 3.2 with editor auto formatter
GODOT_ORIGIN="https://github.com/frugs/godot.git"
GODOT_BRANCH="gdscript_auto_formatter"

# Android tools path
# If these 2 variables are not set, the tools will be downloaded inside the folder set in TOOLS_DIR
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_NDK_ROOT="/opt/android-ndk"

# uncomment only if MINGW is not in path
#export MINGW64_PREFIX="/path/to/x86_64-w64-mingw32-gcc"
#export MINGW32_PREFIX="/path/to/i686-w64-mingw32-gcc"

# Specify the number of CPU threads to use as the first command line argument
# If not set, defaults to 1.5 times the number of CPU threads
#export THREADS="${1:-"$(($(nproc) * 3 / 2))"}"
# change to use all threads
export THREADS=$(nproc)

# The directory where the Godot Git repository will be cloned
#export GODOT_DIR="/tmp/godot"
export GODOT_DIR="$(dirname $DIR)/_godot"

# The directory where build artifacts will be copied
# EDITOR_DIR and TEMPLATES_DIR are used by platform-specific scripts
export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor"
#export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"
export GDVERSION=$(getGDVersion "$GODOT_DIR")
export TEMPLATES_DIR="$HOME/.local/share/godot/templates/$GDVERSION"

# SCons flags to use in all build commands
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"

# Link optimisation flag (64 bits only).
# is set to yes LINKING PROCESS TAKES MUCH MORE TIME
export LTO_FLAG='use_lto=yes'

# ------------
# variables
#
# usually these values should not be changed
# ------------
# Common directories used in the script
export SCRIPTS_DIR="$DIR/scripts"

# The directory where resource files are located
export RESOURCES_DIR="$DIR/resources"

# The directory where SDKs and tools like InnoSetup are located
export TOOLS_DIR="$DIR/tools"

# Set the environment variables used in build naming

# Commit date (not the system date!)
export BUILD_DATE="$(git show -s --format=%cd --date=short)"
# Short (9-character) commit hash
export BUILD_COMMIT="$(git rev-parse --short=9 HEAD)"
# The final version string
export BUILD_VERSION="$BUILD_DATE.$BUILD_COMMIT"

# Path to the Xcode DMG image
export XCODE_DMG="$DIR/Xcode_7.3.1.dmg"

# The path to the OSXCross installation
export OSXCROSS_ROOT="$TOOLS_DIR/osxcross"

# The paths to the Android SDK and NDK, only overridden if the user
# does not already have these variables set
export ANDROID_HOME="${ANDROID_HOME:-"$TOOLS_DIR/android"}"
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-"$TOOLS_DIR/android/ndk-bundle"}"

# The path to the Inno Setup compiler (ISCC.exe)
export ISCC="$TOOLS_DIR/innosetup/ISCC.exe"

# used by some functions as return result
export result=1

# some colors
export resetColor="\e[0m"
export blackOnRed="\e[30;41m"
export blackOnGreen="\e[30;42m"
export blackOnOrange="\e[30;43m"
export blackOnBlue="\e[30;44m"
export redOnBlack="\e[31;40m"
export greenOnBlack="\e[32;40m"
export orangeOnBlack="\e[33;40m"
export blueOnBlack="\e[34;40m"
export redOnWhite="\e[31;107m"
export greenOnWhite="\e[32;107m"
export orangeOnWhite="\e[33;107m"
export blueOnWhite="\e[34;107m"
