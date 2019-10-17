#!/usr/bin/env bash

#------
# Helper functions
#
# Copyright © 2019 Laurent Ongaro and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.
#------

# #
# # init a log file by adding an header
function initLog() {
  if [ -z $1 ]; then exit; fi
  rm -f $1
  touch $1
  content="--------------\n"
  content="${content}GODOT BUILD SCRIPT\n"
  content="${content}---------------\n"
  content="${content}Date: $deployDate\n"
  content="${content}GODOT_DIR: $GODOT_DIR\n"
  content="${content}GODOT_BRANCH: $GODOT_BRANCH\n"
  content="${content}GODOT_ORIGIN: $GODOT_ORIGIN\n"
  content="${content}MONO_SOURCE_ROOT: $MONO_SOURCE_ROOT\n"
  content="${content}BUILD_VERSION:$BUILD_VERSION\n"
  content="${content}\n"
  content="${content}buildLinuxEditor: $buildLinuxEditor\n"
  content="${content}buildLinuxTemplates: $buildLinuxTemplates\n"
  content="${content}buildWindowsEditor: $buildWindowsEditor\n"
  content="${content}buildWindowsTemplates: $buildWindowsTemplates\n"
  content="${content}buildMacosEditor: $buildMacosEditor\n"
  content="${content}buildMacosTemplates: $buildMacosTemplates\n"
  content="${content}buildUWPEditor: $buildUWPEditor\n"
  content="${content}buildUWPTemplates: $buildUWPTemplates\n"
  content="${content}buildServer: $buildServer\n"
  content="${content}buildAndroid: $buildAndroid\n"
  content="${content}buildWeb: $buildWeb\n"
  content="${content}buildIos: $buildIos\n"
  content="${content}buildDoc: $buildDoc\n"
  content="${content}\n"
  content="${content}build32Bits: $build32Bits\n"
  content="${content}buildWithMono: $buildWithMono\n"
  content="${content}buildWithJavascriptSingleton: $buildWithJavascriptSingleton\n"
  content="${content}deploy: $deploy\n"
  content="${content}\n"
  content="${content}isQuiet: $isQuiet\n"
  content="${content}stopOnFail: $stopOnFail\n"
  content="${content}optimisationOn: $optimisationOn\n"
  content="${content}---------------\n\n"
  echo -e "$content" >> $1
}
export -f initLog

# #
# # Output an underlined line in standard output
echo_header() {
  echo -e "\n-------\n${blackOnOrange}$1${resetColor}\n-------\n"
  zeDate=$(date +%Y-%m-%d:%H:%I:%S)

  echo "***** $zeDate:: $1 *****" >> $deployLogOK
  echo "***** $zeDate:: $1 *****" >> $deployLogHS
}
export -f echo_header

# #
# # Output a successful message
echo_success() {
  echo -e "\n${greenOnBlack}$1${resetColor}\n"
}
export -f echo_success

# #
# # Output an info message
echo_info() {
  echo -e "\n${blueOnBlack}$1${resetColor}\n"
}
export -f echo_info

# #
# # Output a error message
echo_warning() {
  echo -e "\n${orangeOnBlack}$1${resetColor}\n"
  if [ $stopOnFail -eq 1 ]; then exit 1; fi
}
export -f echo_warning

# #
# # Output a error message
echo_error() {
  echo -e "\n${redOnBlack}$1${resetColor}\n"
  if [ $stopOnFail -eq 1 ]; then exit 1; fi
}
export -f echo_error

# #
# # Use cp command, but checks if source exists and deletes target before
# # add file to app log
function cpcheck() {
  if [ -r $1 ]; then
    echo $1 >> $deployLogOK
    cp --remove-destination $*
    result=1
    echo_info "Copying $1 ...PASSED"
  else
    echo $1 >> $deployLogHS
    result=0
    echo_info "Copying $1 ...FAILED"
  fi
}
export -f cpcheck

# #
# # command for binaries size optimisation using strip and upx
function cmdUpxStrip() {
  if [ $optimisationOn -eq 0 ]; then
    echo_info "optimisation deactivated"
  else
    strip $*
    upx $*
  fi
}
export -f cmdUpxStrip

# #
# # command for building using scons
function cmdScons() {
  printf "\n${blueOnWhite}Running:${blueOnBlack}scons $*${resetColor}\n"
  scons $*
}
export -f cmdScons

#
# # Ask user to continue or quit with an optional message.
# # Usage:
# #  continueYN [message]
# # Result:
# #  Exit program is Y or y is not pressed.
function continueYN() {
  if [ "$1" = "" ]; then message="Press Y continue, Anything else to Quit "; else message=$1; fi
  if [ ! "x$resetColor" = "x" ]; then message="$orangeOnBlack$message$resetColor"; fi
  echo ""
  printf "$message"
  read -p '? ' userInput # -p is used to avoid default message
  if [ ! "$userInput" = "Y" ] && [ ! "$userInput" = "y" ] && [ ! "$userInput" = "O" ] && [ ! "$userInput" = "o" ]; then exit 0; fi
  echo ""
}
export -f continueYN

# Ask user for yes or no with an optional message.
# Usage:
#  YesNoS [message] [default]
# Result:
#  global variable result will contains 1 or 0
# Note:
#  if isQuiet=1 then no question will be ask and default value will be used
function yesNoS() {
  if [ "x$isQuiet" = "x1" ]; then
    result=$2
  else
    if [ "$1" = "" ]; then message="Confirm "; else message=$1; fi
    message="$message (Y/N)"
    if [ ! "x$resetColor" = "x" ]; then message="$greenOnBlack$message$resetColor"; fi
    printf "$message"
    read -p '? ' userInput # -p is used to avoid default message
    if [ "$userInput" = "Y" ] || [ "$userInput" = "y" ] || [ "$userInput" = "O" ] || [ "$userInput" = "o" ]; then
      result=1
    else
      result=0
    fi
  fi
}
export -f yesNoS

#
# # Check if a string is present within a string.
# # Usage:
# #  checkInString [containerString] [searchString]
# # Result:
# #  global variable result will contains 1 or 0
function checkInString() {
  containerString="$1"
  searchString="$2"
  if [ $(echo "$containerString" | grep -i "$searchString" | wc -l) -gt 0 ]; then
    result=1
  else
    result=0
  fi
}
export -f checkInString

#
# # Detect current OS.
# # Usage:
# #  detectOsRelease
# # Result:
# #  global variable DETECTED_OS will contains the current OS name
function detectOsRelease() {
  export DETECTED_OS=$(cat /etc/os-release | grep "^NAME=" | awk -F '=' '{print $2}' | sed 's/"//g' | sed 's/ //g')
}
export -f detectOsRelease

# #
# # Get godot version from setup.py
function getGDVersion() {
  folder=$1
  string='major = '
  ver_major=$(cat "$folder/version.py" | grep -Fi "$string" | sed "s/$string//g")
  string='minor = '
  ver_minor=$(cat "$folder/version.py" | grep -Fi "$string" | sed "s/$string//g")
  string='status = '
  ver_status=$(cat "$folder/version.py" | grep -Fi "$string" | sed "s/$string//g" | sed 's/"//g')
  echo "$ver_major.$ver_minor.$ver_status"
}
export -f getGDVersion
