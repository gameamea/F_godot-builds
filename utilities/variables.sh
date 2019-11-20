#!/usr/bin/env bash

#------
# Helper variables
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

# ------------
# SETTINGS
#
# these values can be changed to customize the build process
# ------------

# mono extensions
export buildWithMono="${buildWithMono:-0}"
if [ "$buildWithMono" -eq 1 ]; then
  #export MONO_FLAG=" module_mono_enabled=yes"
  export MONO_FLAG=" module_mono_enabled=yes mono_static=yes copy_mono_root=yes"
  export MONO_EXT=".mono"
else
  export MONO_FLAG=""
  export MONO_EXT=""
fi

# Specify the number of CPU threads to use as the first command line argument
# If not set, defaults to 1.5 times the number of CPU threads
#export THREADS="${1:-"$(($(nproc) * 3 / 2))"}"
# change to use all threads
export THREADS=$(nproc)

# SCons flags to use in all build commands
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"

# Link optimisation flag
if [ $isLinkingOptimised -eq 1 ]; then
  # LINKING PROCESS TAKES MUCH MORE TIME
  echo "linking optimisation deactivated"
  export LTO_FLAG="use_lto=yes"
else
  export LTO_FLAG=""
fi

# uncomment only if MINGW is not in path
#export MINGW64_PREFIX="/path/to/x86_64-w64-mingw32-gcc"
#export MINGW32_PREFIX="/path/to/i686-w64-mingw32-gcc"

# `DIR` contains the directory where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any location
export DIR="${DIR:-"/mnt/R/Apps_Sources/GodotEngine/godot-builds"}"

# The directory where the Godot Git repository will be cloned
# and the distant git repo to pull from
# for various godot versions
case $gitRepoIndex in
  0)
    # system dependant/config independant) version (the symlink can be changed on différent PC)
    export GODOT_DIR="$(dirname $DIR)/_godot"
    # GODOT Gameamea version : 3.2 with editor auto formatter (taken from Frug version)
    export GODOT_BRANCH="gdscript_format_updated"
    export GODOT_ORIGIN="https://github.com/gameamea/F_godot.git"
    ;;
  1)
    # GODOT official
    export GODOT_DIR="$(dirname $DIR)/godot_official"
    export GODOT_ORIGIN="https://github.com/godotengine/godot.git"
    export GODOT_BRANCH="master"
    ;;
  2)
    # GODOT Gameamea version : 3.2 with editor auto formatter (taken from Frug version)
    export GODOT_DIR="$(dirname $DIR)/godot_gameamea"
    export GODOT_BRANCH="gdscript_format_updated"
    export GODOT_ORIGIN="https://github.com/gameamea/F_godot.git"
    ;;
  3)
    # GODOT Frug version : 3.2 with editor auto formatter (not up to date)
    export GODOT_DIR="$(dirname $DIR)/godot_frugs"
    export GODOT_ORIGIN="https://github.com/frugs/godot.git"
    export GODOT_BRANCH="gdscript_auto_formatter"
    ;;
esac

# cd here to because some variables need to be computed in these folder
cd "$GODOT_DIR"

# ./bin dir could have been deleted
[ ! -d "$GODOT_DIR/bin" ] && mkdir -p "$GODOT_DIR/bin"

# The directory where build artifacts will be copied
# EDITOR_DIR and TEMPLATES_DIR are used by platform-specific scripts
export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor${MONO_EXT}"
#export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"
export GDVERSION=$(getGDVersion "$GODOT_DIR")
export TEMPLATES_DIR="$HOME/.local/share/godot/templates/${GDVERSION}${MONO_EXT}"

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

# The directory where logs are stored
export LOGS_DIR="$DIR/logs"
mkdir -p $LOGS_DIR
chmod 777 $LOGS_DIR

# The path to the mono dependencies
export TOOLS_MONO_DIR="${TOOLS_MONO_DIR:-"$TOOLS_DIR/mono"}"
# Some folder used by mono prefixes
if [ "$buildWithMono" -eq 1 ]; then
  export MONO_PREFIX_LINUX=" mono_prefix=$TOOLS_MONO_DIR/linux"
  export MONO_PREFIX_WINDOWS=" mono_prefix=$TOOLS_MONO_DIR/windows"
  export MONO_PREFIX_ANDROID=" mono_prefix=$TOOLS_MONO_DIR/android"
else
  export MONO_PREFIX_LINUX=""
  export MONO_PREFIX_WINDOWS=""
  export MONO_PREFIX_ANDROID=""
fi

# The path to The mono sources for build
export MONO_SOURCE_ROOT="/mnt/R/Apps_Sources/mono"

# Set the environment variables used in build naming

# Path to the Xcode DMG image
export XCODE_DMG="$DIR/Xcode_7.3.1.dmg"

# The path to the OSXCross installation
export OSXCROSS_ROOT="$TOOLS_DIR/osxcross"

# The paths to the Android SDK and NDK
# only overridden if the user does not already have these variables set
# If these 2 variables are not set, the tools will be downloaded inside the folder set in TOOLS_DIR
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-"/opt/android-sdk"}"
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-"/opt/android-ndk"}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
[ ! -r "$ANDROID_HOME" ] && export ANDROID_HOME="${ANDROID_HOME:-"$TOOLS_DIR/android"}"

# The path to the Inno Setup compiler (ISCC.exe)
export ISCC="$TOOLS_DIR/innosetup/ISCC.exe"

# The path to emscripten
export EMSCRIPTEN_ROOT="/usr/lib/emscripten"

# Commit date (not the system date!)
export BUILD_DATE="$(git show -s --format=%cd --date=short)"
# Short (9-character) commit hash
export BUILD_COMMIT="$(git rev-parse --short=9 HEAD)"

# The final version string
export BUILD_VERSION="$BUILD_DATE.$BUILD_COMMIT"

# Build log : store the files that were missing on deloy/copy
# the file is stored in the script folder
export deployDate=$(date +%Y-%m-%d)
export logSuccessFile="$LOGS_DIR/${deployDate}_success.log"
export logFailFile="$LOGS_DIR/${deployDate}_fail.log"

# text file to store build settings (in bin folder )
export buildSettingsStoreFile="$GODOT_DIR/bin/BUILD_$BUILD_VERSION${MONO_EXT}.txt"

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

# info about linux system and desktop
export isArchLike=0
export isUbuntuLike=0
export isArch=0
export isArco=0
export isManjaro=0
export isMint=0
export isPopOs=0
export isUbuntu=0

detectOsRelease

checkInString $DETECTED_OS 'pop!_os'
if [ $result -gt 0 ]; then
  export isPopOs=1
  export isUbuntuLike=1
fi
checkInString $DETECTED_OS 'ubuntu'
if [ $result -gt 0 ]; then
  export isUbuntu=1
  export isUbuntuLike=1
fi
checkInString $DETECTED_OS 'mint'
if [ $result -gt 0 ]; then
  export isMint=1
  export isUbuntuLike=1
fi
checkInString $DETECTED_OS 'arch'
if [ $result -gt 0 ]; then
  export isArch=1
  export isArchLike=1
fi
checkInString $DETECTED_OS 'manjaro'
if [ $result -gt 0 ]; then
  export isManjaro=1
  export isArchLike=1
fi
checkInString $DETECTED_OS 'arcolinux'
if [ $result -gt 0 ]; then
  export isArco=1
  export isArchLike=1
fi
