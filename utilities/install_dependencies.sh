#!/bin/bash

#------
# This script installs dependencies required to compile Godot.
# Only Fedora, Arch like and Ubuntu Like OS are currently supported.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/
#------

set -euo pipefail

# Path to the Xcode DMG image
export XCODE_DMG="$DIR/Xcode_7.3.1.dmg"

echo_header "Installing dependencies (administrative privileges may be required)…"

# Display a warning message if no Xcode DMG is found
if [ ! -f "$XCODE_DMG" ]; then
  echo -e "\e[1;33mNOTE:\e[0m Couldn't find a Xcode 7.3.1 DMG image.\nIf you want to build for macOS and iOS, download it from here (requires a free Apple Developer ID):\n\e[1mhttps://developer.apple.com/download/more/\e[0m\n"
fi

isArchLike=0
isUbuntuLike=0
isArch=0
isArco=0
isManjaro=0
isMint=0
isPopOs=0
isUbuntu=0

detectOsRelease

# Install system packages
checkInString $DETECTED_OS 'pop!_os'
if [ $result -gt 0 ]; then
  isPopOs=1
  isUbuntuLike=1
fi
checkInString $DETECTED_OS 'ubuntu'
if [ $result -gt 0 ]; then
  isUbuntu=1
  isUbuntuLike=1
fi
checkInString $DETECTED_OS 'mint'
if [ $result -gt 0 ]; then
  isMint=1
  isUbuntuLike=1
fi
checkInString $DETECTED_OS 'arch'
if [ $result -gt 0 ]; then
  isArch=1
  isArchLike=1
fi
checkInString $DETECTED_OS 'manjaro'
if [ $result -gt 0 ]; then
  isManjaro=1
  isArchLike=1
fi
checkInString $DETECTED_OS 'arcolinux'
if [ $result -gt 0 ]; then
  isArco=1
  isArchLike=1
fi

if [ $isArchLike -eq 1 ]; then
  # Arch linux
  sudo pacman -S scons pkgconf gcc libxcursor libxinerama libxi libxrandr mesa glu alsa-lib pulseaudio yasm
elif [ $isUbuntuLike -eq 1 ]; then
  ## Debian / Ubuntu
  sudo apt-get install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm
fi

## Fedora
# TODO TEST if present
# sudo dnf install scons pkgconfig libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel mesa-libGL-devel mesa-libGLU-devel alsa-lib-devel pulseaudio-libs-devel libudev-devel yasm

## FreeBSD
# TODO TEST if present
# sudo pkg install scons pkgconf xorg-libraries libXcursor libXrandr libXi xorgproto libGLU alsa-lib pulseaudio yasm

## Gentoo
# TODO TEST if present
# emerge -an dev-util/scons x11-libs/libX11 x11-libs/libXcursor x11-libs/libXinerama x11-libs/libXi media-libs/mesa media-libs/glu media-libs/alsa-lib media-sound/pulseaudio dev-lang/yasm

## Mageia
# TODO TEST if present
# urpmi scons task-c++-devel pkgconfig "pkgconfig(alsa)" "pkgconfig(glu)" "pkgconfig(libpulse)" "pkgconfig(udev)" "pkgconfig(x11)" "pkgconfig(xcursor)" "pkgconfig(xinerama)" "pkgconfig(xi)" "pkgconfig(xrandr)" yasm

## OpenBSD
# TODO TEST if present
# pkg_add python scons llvm yasm

## openSUSE
# TODO TEST if present
# sudo zypper install scons pkgconfig libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel Mesa-libGL-devel alsa-devel libpulse-devel libudev-devel libGLU1 yasm

## Solus
# TODO TEST if present
# sudo eopkg install -c system.devel scons libxcursor-devel libxinerama-devel libxi-devel libxrandr-devel mesalib-devel libglu alsa-lib pulseaudio pulseaudio-devel yasm

mkdir -p "$TOOLS_DIR"

# Install InnoSetup
if [ $buildWindowsEditor -eq 1 ] || [ $buildWindowsTemplates -eq 1 ]; then
  if [ ! -d "$TOOLS_DIR/innosetup" ]; then
    echo_header "Downloading InnoSetup…"
    curl -o "$TOOLS_DIR/innosetup.zip" "https://archive.hugo.pro/.public/godot-builds/innosetup-5.5.9-unicode.zip"
    unzip -q "$TOOLS_DIR/innosetup.zip" -d "$TOOLS_DIR"
    rm "$TOOLS_DIR/innosetup.zip"
  else
    echo_header "InnoSetup is already installed."
  fi
fi

# Install the Android SDK
if [ $buildAndroid -eq 1 ]; then

  if [ "$ANDROID_HOME" ] && [ ! -d "$TOOLS_DIR/android" ]; then
    echo_header "Downloading Android SDK…"
    # Download and extract the SDK
    curl -o "$TOOLS_DIR/android.zip" "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
    # The SDK tools must be located in `$TOOLS_DIR/android/tools` as
    # other directories will exist within `$TOOLS_DIR/android`
    mkdir "$TOOLS_DIR/android"
    unzip -q "$TOOLS_DIR/android.zip" -d "$TOOLS_DIR/android"
    rm "$TOOLS_DIR/android.zip"
  elif [ "$ANDROID_HOME" ]; then
    echo_header "Android SDK is already installed system-wide".
  else
    echo_header "Android SDK is already installed using this script."
  fi
fi

# If the user provides an Xcode DMG image, install OSXCross
# (which includes darling-dmg) and cctools-port
if [ -f "$XCODE_DMG" ]; then
  if [ $buildMacosEditor -eq 1 ] || [ $buildMacosTemplates -eq 1 ]; then
    if [ ! -d "$TOOLS_DIR/osxcross" ]; then
      # OSXCross (for macOS builds)
      echo_header "Installing OSXCross…"
      curl -o "$TOOLS_DIR/osxcross.zip" "https://codeload.github.com/tpoechtrager/osxcross/zip/master"
      unzip -q "$TOOLS_DIR/osxcross.zip" -d "$TOOLS_DIR"
      mv "$TOOLS_DIR/osxcross-master" "$TOOLS_DIR/osxcross"
      cd "$TOOLS_DIR/osxcross"
      tools/gen_sdk_package_darling_dmg.sh "$XCODE_DMG"
      mv "MacOSX10.11.sdk.tar.xz" "$TOOLS_DIR/osxcross/tarballs"
      UNATTENDED=1 ./build.sh
    else
      echo_header "OSXCross is already installed."
    fi
  fi

  if [ $buildIos -eq 1 ]; then
    if [ ! -d "$TOOLS_DIR/cctools-port" ]; then
      # cctools-port (for iOS builds)
      echo_header "Installing cctools-port…"
      curl -o "$TOOLS_DIR/cctools-port.zip" "https://codeload.github.com/tpoechtrager/cctools-port/zip/master"
      unzip -q "$TOOLS_DIR/cctools-port.zip" -d "$TOOLS_DIR"
      mv "$TOOLS_DIR/cctools-port-master" "$TOOLS_DIR/cctools-port"
    else
      echo_header "cctools-port is already installed."
    fi
  fi
fi
