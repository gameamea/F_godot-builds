#!/usr/bin/env bash

#------
# Helper functions
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/
#------

# #
# # Output an underlined line in standard output
echo_header() {
  echo -e "\n-------\n${blackOnOrange}$1${resetColor}\n-------\n"
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
  [ $stopOnFail -eq 1 ] && exit 1
}
export -f echo_warning

# #
# # Output a error message
echo_error() {
  echo -e "\n${redOnBlack}$1${resetColor}\n"
  [ $stopOnFail -eq 1 ] && exit 1
}
export -f echo_error

# #
# # Use cp command, but checks if source exists and deletes target before
function cpcheck() {
  if [ -r $1 ]; then
    cp --remove-destination $*
    result=1
  else
    result=0
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
