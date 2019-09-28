#!/usr/bin/env bash

#------
# Helper functions
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/
#------

export result=1

# #
# # Output an underlined line in standard output
echo_header() {
  echo -e "\e[1;4m$1\e[0m"
}
export -f echo_header

# #
# # Output a successful build step
echo_success() {
  echo -e "\e[1;4;32m$1\e[0m"
}
export -f echo_success

#
# # Ask user to continue or quit with an optional message.
# # Usage:
# #  continueYN [message]
# # Result:
# #  Exit program is Y or y is not pressed.
function continueYN() {
  if [ "$1" = "" ]; then message="Press Y continue, Anything else to Quit "; else message=$1; fi
  echo ""
  read -p "$message" userInput
  if [ ! "$userInput" = "Y" ] && [ ! "$userInput" = "y" ] && [ ! "$userInput" = "O" ] && [ ! "$userInput" = "o" ]; then exit 0; fi
  echo ""
}
export -f continueYN

#
# # Ask user for yes or no with an optional message.
# # Usage:
# #  YesNo [message]
# # Result:
# #  global variable result will contains 1 or 0
function yesNo() {
  if [ "$1" = "" ]; then message="Confirm "; else message=$1; fi
  read -p "$message (Y/N) ?" userInput
  if [ "$userInput" = "Y" ] || [ "$userInput" = "y" ] || [ "$userInput" = "O" ] || [ "$userInput" = "o" ]; then
    result=1
  else
    result=0
  fi
}
export -f yesNo

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
export DETECTED_OS=''
function detectOsRelease() {
  DETECTED_OS=$(cat /etc/os-release | grep "^NAME=" | awk -F '=' '{print $2}' | sed 's/"//g' | sed 's/ //g')
}
export -f detectOsRelease
