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
export isQuiet=0
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
#  if set to 1, Run './script/test.sh' file after initialisation instead of running normal process."
export runTest=0
#  if set to 1, dependency setup will be forced
export isDependencyForced=0

# ------------
# CHANGING BUILDS SETTINGS
#
# these values are default values and can be changed BY ASKING TO USER
# if isQuiet=0, some of them will be asked to user
# ------------

# Desktop platforms
export buildLinuxEditor=1      # normal32:OK normal64:OK mono64:OK mono32:unavailable
export buildLinuxTemplates=1   # normal32:OK normal64:OK mono64:OK mono32:unavailable
export buildWindowsEditor=1    # normal32:OK normal64:OK mono:BUG cross build
export buildWindowsTemplates=1 # normal32:OK normal64:OK mono:BUG cross build
export buildMacosEditor=0      #TODO:TEST no mono & TEST Mono
export buildMacosTemplates=0   #TODO:TEST no mono & TEST Mono

# Mobile/Web/Other platforms
export buildAndroid=1      # normal32:OK normal64:OK mono:OK
export buildWeb=1          # normal32:OK normal64:OK mono:unavailable (DEACTIVATED)
export buildServer=1       # normal32:OK normal64:OK mono:unavailable (DEACTIVATED)
export buildUWPTemplates=0 #TODO:TEST no mono & TEST Mono
export buildIos=0          #TODO
export buildDoc=0          #TODO

# Build 32 bits version if possible
# NOTE: it Will be build BEFORE the 64 bits version
export build32Bits=1

# Build with mono if possible
export buildWithMono=1

# Deploy
export deploy=1 #TODO: update code after each sucessfull build process added

# backup existing binaries
export backupBinaries=1

# ------------
# BUILD OPTIONS
#
# these values can be changed to customize the build process
# ------------

# Web/Javascript option
# By default, the JavaScript singleton will be built into the engine. Since eval() calls can be a security concern.
export buildWithJavascriptSingleton=1

# EMSCRIPTEN version to update on dependencies:
# NOTE: if latest is chosen, an new update will nearly be dowload each time
# export emscriptenVersion='latest'
export emscriptenVersion='1.38.47'

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
  echo " -h |--help  : Show this help and exit."
  echo " -p |--printenv  : Print the environment settings and exit."
  echo " -q |--quiet : Stop asking for user input (automatic or batch mode)."
  echo " -t |--test : Run './script/test.sh' file after initialisation instead of running normal process."
  echo " -g |--gitrepoindex : Index of the git repo to use for build (0 for default in '_godot' folder, 1 for official godot.., see list in variables.sh), overwrite the setting set in files."
  echo " --dependencies : Force dependency setup will be forced, overwrite the setting set in files."
  echo " --nomono : Force build without mono, overwrite the setting set in files."
  echo " --mono : Force build with mono, overwrite the setting set in files."
  echo " --32b : Force build with 32 bits versions, overwrite the setting set in files."
  echo " --no32b : Force build without32 bits versions, overwrite the setting set in files."
  echo " --backup : Force to backup existng binaries."
  echo " --nobackup : Force not to backup existng binaries."
  echo " --x11editoronly : Build only 64 bits editor for Linux."
  echo " --windowseditoronly : Build only 64 bits editor for Windows."
  echo "Default options are set to:"
  echo " ask for user confirmation (add -q option to disable)."
  echo " use Source code stored in the '../_godot' folder (that must be a symlink to the version you want to compile)."
  echo " build only Linux and Windows 32 and 64 bits editors WITH Mono."
  echo " build only Linux, Windows 32 and 64 bits templates WITH Mono (if available)."
  echo " build only Android, Web and server 32 and 64 bits templates WITH Mono (if available)."
  echo " copy binaries and templates to './artifact' folder."
  echo " copy templates to the recommanded template folder associated to the built godot version."
  echo " optimisations: binary size but not linking."
  echo "Notes:"
  echo " Settings at the start of this file can be changed to custom build process."
  echo " Some less important variables can also be edited in ./utilities/variables.sh file."
  exit 0
}

function printEnv() {
  echo ""
  echo "Script parameters:"
  echo ""
  echo "isQuiet=$isQuiet"
  echo "stopOnFail=$stopOnFail"
  echo "isBinSizeOptimised=$isBinSizeOptimised"
  echo "isLinkingOptimised=$isLinkingOptimised"
  echo "defaultYN=$defaultYN"
  echo "importantYN=$importantYN"
  echo "gitRepoIndex=$gitRepoIndex"
  echo "runTest=$runTest"
  echo "isDependencyForced=$isDependencyForced"
  echo "buildLinuxEditor=$buildLinuxEditor"
  echo "buildLinuxTemplates=$buildLinuxTemplates"
  echo "buildWindowsEditor=$buildWindowsEditor"
  echo "buildWindowsTemplates=$buildWindowsTemplates"
  echo "buildMacosEditor=$buildMacosEditor"
  echo "buildMacosTemplates=$buildMacosTemplates"
  echo "buildAndroid=$buildAndroid"
  echo "buildWeb=$buildWeb"
  echo "buildServer=$buildServer"
  echo "buildUWPTemplates=$buildUWPTemplates"
  echo "buildIos=$buildIos"
  echo "buildDoc=$buildDoc"
  echo "build32Bits=$build32Bits"
  echo "buildWithMono=$buildWithMono"
  echo "deploy=$deploy"
  echo "backupBinaries=$backupBinaries"
  echo "buildWithJavascriptSingleton=$buildWithJavascriptSingleton"
  echo "emscriptenVersion=$emscriptenVersion"
  exit 0
}
# ------------
# COMMAND LINE OPTIONS
# Must be done before other init
# ------------

while [ -n "$1" ]; do
  #echo_info "parameter=$1"
  case "$1" in
    -h | --help)
      usage
      ;;
    -p | --printenv)
      printEnv
      ;;
    -q | --quiet)
      export isQuiet=1
      ;;
    -t | --test)
      export runTest=1
      ;;
    -g | --gitrepoindex)
      export gitRepoIndex=$2
      shift
      ;;
    --dependencies)
      export isDependencyForced=1
      ;;
    --nomono)
      export buildWithMono=0
      ;;
    --mono)
      export buildWithMono=1
      ;;
    --32b)
      export build32Bits=1
      ;;
    --no32b)
      export build32Bits=0
      ;;
    --backup)
      export backupBinaries=1
      ;;
    --nobackup)
      export backupBinaries=0
      ;;
    --x11editoronly)
      export isQuiet=1
      export buildLinuxEditor=1
      export buildLinuxTemplates=0
      export buildWindowsEditor=0
      export buildWindowsTemplates=0
      export buildMacosEditor=0
      export buildMacosTemplates=0
      export buildAndroid=0
      export buildWeb=0
      export buildServer=0
      export buildUWPTemplates=0
      export buildIos=0
      export buildDoc=0
      export build32Bits=0
      ;;
    --windowseditoronly)
      export isQuiet=1
      export buildLinuxEditor=0
      export buildLinuxTemplates=0
      export buildWindowsEditor=1
      export buildWindowsTemplates=0
      export buildMacosEditor=0
      export buildMacosTemplates=0
      export buildAndroid=0
      export buildWeb=0
      export buildServer=0
      export buildUWPTemplates=0
      export buildIos=0
      export buildDoc=0
      export build32Bits=0
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

# ------------
# START
# ------------

# ASK USER
if [ $isQuiet -eq 0 ]; then
  yesNoS "Do you want to build Linux Editor"
  if [ $result -eq 1 ]; then export buildLinuxEditor=1; else export buildLinuxEditor=0; fi
  yesNoS "Do you want to build Linux Templates"
  if [ $result -eq 1 ]; then export buildLinuxTemplates=1; else export buildLinuxTemplates=0; fi
  yesNoS "Do you want to build Windows Editor"
  if [ $result -eq 1 ]; then export buildWindowsEditor=1; else export buildWindowsEditor=0; fi
  yesNoS "Do you want to build Windows Templates"
  if [ $result -eq 1 ]; then export buildWindowsTemplates=1; else export buildWindowsTemplates=0; fi
  yesNoS "Do you want to build Mac Os Editor"
  if [ $result -eq 1 ]; then export buildMacosEditor=1; else export buildMacosEditor=0; fi
  yesNoS "Do you want to build Mac Os Templates"
  if [ $result -eq 1 ]; then export buildMacosTemplates=1; else export buildMacosTemplates=0; fi
  yesNoS "Do you want to build Android Templates"
  if [ $result -eq 1 ]; then export buildAndroid=1; else export buildAndroid=0; fi
  yesNoS "Do you want to build Web Templates"
  if [ $result -eq 1 ]; then export buildWeb=1; else export buildWeb=0; fi
  yesNoS "Do you want to build Server binaries"
  if [ $result -eq 1 ]; then export buildServer=1; else export buildServer=0; fi
  yesNoS "Do you want to build UWP Templates"
  if [ $result -eq 1 ]; then export buildUWPTemplates=1; else export buildUWPTemplates=0; fi
  yesNoS "Do you want to build Ios Templates"
  if [ $result -eq 1 ]; then export buildIos=1; else export buildIos=0; fi
  yesNoS "Do you want to build Doc"
  if [ $result -eq 1 ]; then export buildDoc=1; else export buildDoc=0; fi
  yesNoS "Do you want to build 32 Bits versions (64 bits version will always be built)"
  if [ $result -eq 1 ]; then export build32Bits=1; else export build32Bits=0; fi
  yesNoS "Do you want to build with Mono"
  if [ $result -eq 1 ]; then export buildWithMono=1; else export buildWithMono=0; fi
  yesNoS "Do you want to deploy binaries"
  if [ $result -eq 1 ]; then export deploy=1; else export deploy=0; fi
  yesNoS "Do you want to backup existing binaries"
  if [ $result -eq 1 ]; then export backupBinaries=1; else export backupBinaries=0; fi
fi

# init logs
initLog $logFailFile
initLog $logSuccessFile

# store build settings
initLog $buildSettingsStoreFile

mkdir -p "$EDITOR_DIR" "$TEMPLATES_DIR"

echo_header "GODOT ENGINE BUILD SCRIPT"
echo_info "${blueOnWhite}Source folder: $GODOT_DIR"

yesNoS "${orangeOnBlack}Do you want to Install or update dependencies" $isDependencyForced
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

# running test file
if [ $runTest -eq 1 ]; then
  echo_warning "Running test script and exit"
  "$SCRIPTS_DIR/test.sh"
  exit
fi

# build Desktop Editor & Templates
#-----
# backup
if [ $backupBinaries -eq 1 ]; then
  # we backup in different folders mono and no mono versions
  isBinMono=$(ls $GODOT_DIR/bin/BUILD_* 2> /dev/null | grep -Fi 'mono' | wc -l)
  if [ $isBinMono -lt 0 ]; then
    bakFolder="$GODOT_DIR/bin_mono_$deployDate"
  else
    bakFolder="$GODOT_DIR/bin_$deployDate"
  fi
  mkdir -p "$bakFolder"
  cp -aR $GODOT_DIR/bin/* "$bakFolder/"
  rm -Rf $GODOT_DIR/bin/*
  # create a git ignore in backup folder to ignore all files
  echo "*" > "$bakFolder/.gitignore"

  echo_info "backup binaries to $bakFolder"
fi

# Linux
if [ $buildLinuxEditor -eq 1 ] || [ $buildLinuxTemplates -eq 1 ]; then "$SCRIPTS_DIR/linux.sh"; fi
# Windows
if [ $buildWindowsEditor -eq 1 ] || [ $buildWindowsTemplates -eq 1 ]; then "$SCRIPTS_DIR/windows.sh"; fi
# MacOS
if [ $buildMacosEditor -eq 1 ] || [ $buildMacosTemplates -eq 1 ]; then "$SCRIPTS_DIR/macos.sh"; fi

# build Other Templates
#-----
# Android
[ $buildAndroid -eq 1 ] && "$SCRIPTS_DIR/android.sh"
# Web
[ $buildWeb -eq 1 ] && "$SCRIPTS_DIR/web.sh"
# Server
[ $buildServer -eq 1 ] && "$SCRIPTS_DIR/server.sh"
# UWP
if [ $buildUWPTemplates -eq 1 ]; then "$SCRIPTS_DIR/uwp.sh"; fi
# IOS
[ $buildIos -eq 1 ] && "$SCRIPTS_DIR/ios.sh"

# Doc
[ $buildDoc -eq 1 ] && "$SCRIPTS_DIR/doc.sh"

# Deploy
[ $deploy -eq 1 ] && "$SCRIPTS_DIR/deploy.sh"

echo_header "All Operations finished."
