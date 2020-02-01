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

# mono extension
export buildWithMono="${buildWithMono:-0}"
if [ "$buildWithMono" -eq 1 ]; then
  #export MONO_FLAG=" module_mono_enabled=yes"
  export MONO_FLAG_P1=" module_mono_enabled=yes"
  if [ $isMonoStatic -eq 0 ]; then
    # first option: dynamic linking (shared mono)
    # "Linking Mono statically generates an error. Option is removed in code."
    # "Copying Mono generates an error. Option is removed in code."
    export MONO_FLAG_P2=""
  else
    # second option: static linking:
    # "Linking using a shared mono mono won't work for build a for windows on Linux."
    export MONO_FLAG_P2=" mono_static=yes copy_mono_root=yes"
  fi
  export MONO_FLAG=" $MONO_FLAG_P1 $MONO_FLAG_P2"
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
#export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"
export SCONS_FLAGS="debug_symbols=no -j$THREADS"

# Link optimisation flag
if [ "x$isLinkingOptimised" = "x1" ]; then
  # LINKING PROCESS TAKES MUCH MORE TIME
  echo "linking optimisation deactivated"
  export LTO_FLAG="use_lto=yes"
else
  export LTO_FLAG=""
fi

# uncomment only if MINGW is not in path
#export MINGW64_PREFIX="/path/to/x86_64-w64-mingw32-gcc"
#export MINGW32_PREFIX="/path/to/i686-w64-mingw32-gcc"

# `DIR` contains Folder where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any location
export DIR="${DIR:-"/mnt/R/Apps_Sources/GodotEngine/godot-builds"}"

# Folder where the Godot Git repository will be cloned
# and the distant git repo to pull from
# for various godot versions
case $gitRepoIndex in
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
  *)
    # system dependant/config independant) version (the symlink can be changed on différent PC)
    export GODOT_DIR="$(dirname $DIR)/_godot"
    # GODOT Gameamea version : 3.2 with editor auto formatter (taken from Frug version)
    export GODOT_BRANCH="gdscript_format_updated"
    export GODOT_ORIGIN="https://github.com/gameamea/F_godot.git"
    ;;
esac

# cd here to because some variables need to be computed in these folder
cd "$GODOT_DIR"

# ./bin dir could have been deleted
[ ! -d "$GODOT_DIR/bin" ] && mkdir -p "$GODOT_DIR/bin"

# Folder where build artifacts will be copied
# EDITOR_DIR and TEMPLATES_DIR are used by platform-specific scripts
export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor${MONO_EXT}"
#export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"
export GDVERSION=$(getGDVersion "$GODOT_DIR")
export TEMPLATES_DIR="$HOME/.local/share/godot/templates/${GDVERSION}${MONO_EXT}"

# ------------
# variables used by build_godot.sh
#
# usually these values should not be changed
# ------------
# Path to building scripts
export SCRIPTS_DIR="$DIR/scripts"

# Path to resource files
export RESOURCES_DIR="$DIR/resources"

# Path to SDKs and tools like InnoSetup
export TOOLS_DIR="$DIR/tools"

# Folder for log files
export LOGS_DIR="$DIR/logs"
mkdir -p $LOGS_DIR
chmod 777 $LOGS_DIR

# Path to mono dependencies
export TOOLS_MONO_DIR="${TOOLS_MONO_DIR:-"$TOOLS_DIR/mono"}"

# Path to mono build scripts
export TOOLS_MONO_BUILDS="$TOOLS_DIR/godot-mono-builds"

export MONO_BUILDS_CROSS_COMPIL_FLAG="--mxe-prefix=/usr"

# Folders used by mono prefixes when building MONO
export MONO_BUILDS_PREFIX_LINUX="$TOOLS_MONO_DIR/linux"
export MONO_BUILDS_PREFIX_WINDOWS="$TOOLS_MONO_DIR/windows"
export MONO_BUILDS_PREFIX_MACOS="$TOOLS_MONO_DIR/macosx"
export MONO_BUILDS_PREFIX_ANDROID="$TOOLS_MONO_DIR/android"
export MONO_BUILDS_PREFIX_WEBASM="$TOOLS_MONO_DIR/webasm"
export MONO_BUILDS_PREFIX_BCL="$TOOLS_MONO_DIR/bcl"
export MONO_BUILDS_LINUX_FLAGS="--install-dir=$MONO_BUILDS_PREFIX_LINUX/mono-installs --configure-dir=$MONO_BUILDS_PREFIX_LINUX/mono-config"
export MONO_BUILDS_WINDOWS_FLAGS="--install-dir=$MONO_BUILDS_PREFIX_WINDOWS/mono-installs --configure-dir=$MONO_BUILDS_PREFIX_WINDOWS/mono-config"
export MONO_BUILDS_MACOS_FLAGS="--install-dir=$MONO_BUILDS_PREFIX_MACOS/mono-installs --configure-dir=$MONO_BUILDS_PREFIX_MACOS/mono-config"
export MONO_BUILDS_ANDROID_FLAGS="--install-dir=$MONO_BUILDS_PREFIX_ANDROID/mono-installs --configure-dir=$MONO_BUILDS_PREFIX_ANDROID/mono-config"
export MONO_BUILDS_WEBASM_FLAGS="--install-dir=$MONO_BUILDS_PREFIX_WEBASM/mono-installs --configure-dir=$MONO_BUILDS_PREFIX_WEBASM/mono-config"
export MONO_BUILDS_BCL_FLAGS="--install-dir=$MONO_BUILDS_PREFIX_BCL/mono-installs --configure-dir=$MONO_BUILDS_PREFIX_BCL/mono-config"

# Folders used by mono prefixes when building GODOT
if [ "$buildWithMono" -eq 1 ]; then
  export MONO_PREFIX_LINUX=" mono_prefix=$MONO_BUILDS_PREFIX_LINUX"
  export MONO_PREFIX_WINDOWS=" mono_prefix=$MONO_BUILDS_PREFIX_WINDOWS"
  export MONO_PREFIX_MACOSX=" mono_prefix=$MONO_BUILDS_PREFIX_MACOS"
  export MONO_PREFIX_ANDROID=" mono_prefix=$MONO_BUILDS_PREFIX_ANDROID"
  export MONO_PREFIX_WEBASM=" mono_prefix=$MONO_BUILDS_PREFIX_WEBASM"
  export MONO_PREFIX_BCL=" mono_prefix=$MONO_BUILDS_BCL_FLAGS"
else
  export MONO_PREFIX_LINUX=""
  export MONO_PREFIX_WINDOWS=""
  export MONO_PREFIX_MACOSX=""
  export MONO_PREFIX_ANDROID=""
  export MONO_PREFIX_WEBASM=""
  export MONO_PREFIX_BCL=""
fi

# Path to mono sources
export MONO_SOURCE_ROOT="${MONO_SOURCE_ROOT:-"/mnt/R/Apps_Sources/mono"}"

# Set the environment variables used in build naming

# Path to the Xcode DMG image
export XCODE_DMG="$DIR/Xcode_7.3.1.dmg"

# Path to the OSXCross installation
export OSXCROSS_ROOT="$TOOLS_DIR/osxcross"

# Paths to the Android SDK and NDK
# only overridden if the user does not already have these variables set
# If these 2 variables are not set, the tools will be downloaded inside the folder set in TOOLS_DIR
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-"/opt/android-sdk"}"
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-"/opt/android-ndk"}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
[ ! -r "$ANDROID_HOME" ] && export ANDROID_HOME="${ANDROID_HOME:-"$TOOLS_DIR/android"}"

# Path to the Inno Setup compiler (ISCC.exe)
export ISCC="$TOOLS_DIR/innosetup/ISCC.exe"

# Path to emscripten
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
export isUbuntu=0

detectOsRelease

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
