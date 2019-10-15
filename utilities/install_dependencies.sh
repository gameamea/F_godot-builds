#!/bin/bash

#------
# This script installs dependencies required to compile Godot.
# Only Fedora, Arch like and Ubuntu Like OS are currently supported.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/
#------

set -euo pipefail

mkdir -p "$TOOLS_DIR"

echo_header "Installing dependencies (administrative privileges may be required)"

# Install system packages
# ----------
yesNoS "Do you want to download (or upate) all packages for your OS" 0
if [ $result -eq 1 ]; then
  label="dependencies"
  echo_header "Installing $label"
  if [ $isArchLike -eq 1 ]; then
    ## Arch linux
    sudo pacman -S --force upx scons pkgconf gcc libxcursor libxinerama libxi libxrandr mesa glu alsa-lib pulseaudio yasm
  elif [ $isUbuntuLike -eq 1 ]; then
    ## Debian / Ubuntu
    # TODO: following command must be tested
    sudo apt-get install upx-ucl build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm

    # macOS
    # TODO Add package install

    ## Fedora
    # TODO TEST if present
    # sudo dnf install upx scons pkgconfig libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel mesa-libGL-devel mesa-libGLU-devel alsa-lib-devel pulseaudio-libs-devel libudev-devel yasm

    ## Mageia
    # TODO TEST if present
    # urpmi scons upx task-c++-devel pkgconfig "pkgconfig(alsa)" "pkgconfig(glu)" "pkgconfig(libpulse)" "pkgconfig(udev)" "pkgconfig(x11)" "pkgconfig(xcursor)" "pkgconfig(xinerama)" "pkgconfig(xi)" "pkgconfig(xrandr)" yasm

    ## Solus
    # TODO TEST if present
    # sudo eopkg install -c upx system.devel scons libxcursor-devel libxinerama-devel libxi-devel libxrandr-devel mesalib-devel libglu alsa-lib pulseaudio pulseaudio-devel yasm

    ## Gentoo
    # TODO TEST if present
    # emerge -an upx dev-util/scons x11-libs/libX11 x11-libs/libXcursor x11-libs/libXinerama x11-libs/libXi media-libs/mesa media-libs/glu media-libs/alsa-lib media-sound/pulseaudio dev-lang/yasm

    ## openSUSE
    # TODO TEST if present
    # sudo zypper install upx scons pkgconfig libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel Mesa-libGL-devel alsa-devel libpulse-devel libudev-devel libGLU1 yasm

    if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
    if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
  fi
  if [ $buildWindowsEditor -eq 1 ] || [ $buildWindowsTemplates -eq 1 ]; then
    label="Windows Cross compiler"
    echo_header "Installing $label"
    if [ $isArchLike -eq 1 ]; then
      ## Arch linux
      yay -S --force mingw-w64-crt mingw-w64-gcc

      sudo pacman -S --force wine
    elif [ $isUbuntuLike -eq 1 ]; then
      ## Debian / Ubuntu
      # TODO: following command must be tested
      sudo apt install mingw-w64-crt mingw-w64
      sudo apt install wine

      ## macOS
      # TODO TEST if present
      # brew install mingw-w64
      # brew install wine

      ## Fedora
      # TODO TEST if present
      # dnf install mingw64-gcc-c++ mingw64-winpthreads-static mingw32-gcc-c++ mingw32-winpthreads-static
      # dnf install wine

      ## Mageia
      # TODO Add package install

      ## Solus
      # TODO Add package install

      ## Gentoo
      # TODO Add package install

      ## openSUSE
      # TODO TEST if present
      # urpmi mingw64-gcc-c++ mingw64-winpthreads-static mingw32-gcc-c++ mingw32-winpthreads-static
      # urpmi wine

    fi
    if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
    if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
  fi
fi

# Install Mono
# ----------
if [ $buildWithMono -eq 1 ]; then
  label="Mono"
  yesNoS "Do you want to setup $label" 0
  if [ $result -eq 1 ]; then
    # import necessary certificates for NuGet to perform HTTPS requests
    mozroots --import --sync
    if [ $isArchLike -eq 1 ]; then
      sudo pacman -S --force mono
    elif [ $isUbuntuLike -eq 1 ]; then
      # TODO: following command must be tested
      sudo apt install mono
    fi
    # macOS
    # TODO Add package install

    # Fedora
    # TODO Add package install

    ## Mageia
    # TODO Add package install

    ## Solus
    # TODO Add package install

    ## Gentoo
    # TODO Add package install

    ## openSUSE
    # TODO Add package install

  fi
  # TODO: test build with mono missing to check for dependencies
fi

# Install InnoSetup
# ----------
if [ $buildWindowsEditor -eq 1 ] || [ $buildWindowsTemplates -eq 1 ]; then
  label="InnoSetup"
  yesNoS "Do you want to install $label" 0
  if [ $result -eq 1 ]; then
    if [ ! -d "$TOOLS_DIR/innosetup" ]; then
      # Install InnoSetup
      echo_header "Downloading $label"
      #TODO create a download url
      # curl -o "$TOOLS_DIR/innosetup.zip" "https://archive.hugo.pro/.public/godot-builds/innosetup-5.5.9-unicode.zip"
      cp "/home/laurent/Téléchargements/Windows/InnoSetup.zip" "$TOOLS_DIR/innosetup.zip"
      unzip -q "$TOOLS_DIR/innosetup.zip" -d "$TOOLS_DIR"
      rm "$TOOLS_DIR/innosetup.zip"
      if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
      if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
    else
      echo_info "$label is already installed."
    fi
  fi
fi

# Install Android SDK
# ----------
if [ $buildAndroid -eq 1 ]; then
  label="Android SDK"
  yesNoS "Do you want to install $label" 0
  if [ $result -eq 1 ]; then
    if [ "$ANDROID_HOME" ] && [ ! -d "$TOOLS_DIR/android" ]; then
      echo_header "Downloading $label"
      # Download and extract the SDK
      curl -o "$TOOLS_DIR/android.zip" "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
      # The SDK tools must be located in `$TOOLS_DIR/android/tools` as
      # other directories will exist within `$TOOLS_DIR/android`
      mkdir "$TOOLS_DIR/android"
      unzip -q "$TOOLS_DIR/android.zip" -d "$TOOLS_DIR/android"
      rm "$TOOLS_DIR/android.zip"
      if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
      if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
    elif [ "$ANDROID_HOME" ]; then
      echo_info "$label is already installed system-wide".
    else
      echo_info "$label is already installed using this script."
    fi
  fi

  label="Mono for Android"
  yesNoS "Do you want to build $label" 0
  if [ $result -eq 1 ]; then
    "$TOOLS_DIR/godot-mono-builds/build_mono"
    if [ $? -eq 0 ] && [ -d "$TOOLS_DIR/mono/mono-installs/android-x86-release" ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
    if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
  fi
fi

# Install OSXCross
# If the user provides an Xcode DMG image (which includes darling-dmg) and cctools-port
# ----------
if [ $buildMacosEditor -eq 1 ] || [ $buildMacosTemplates -eq 1 ]; then
  label="OSXCross"
  yesNoS "Do you want to install $label" 0
  if [ $result -eq 1 ]; then
    # Display a warning message if no Xcode DMG is found
    if [ ! -f "$XCODE_DMG" ]; then
      echo -e "\e[1;33mNOTE:\e[0m Couldn't find a Xcode 7.3.1 DMG image.\nIf you want to build for macOS and iOS, download it from here (requires a free Apple Developer ID):\n\e[1mhttps://developer.apple.com/download/more/\e[0m\n"
    else
      if [ ! -d "$TOOLS_DIR/osxcross" ]; then
        # OSXCross (for macOS builds)
        echo_header "Installing $label"
        curl -o "$TOOLS_DIR/osxcross.zip" "https://codeload.github.com/tpoechtrager/osxcross/zip/master"
        unzip -q "$TOOLS_DIR/osxcross.zip" -d "$TOOLS_DIR"
        mv "$TOOLS_DIR/osxcross-master" "$TOOLS_DIR/osxcross"
        cd "$TOOLS_DIR/osxcross"
        tools/gen_sdk_package_darling_dmg.sh "$XCODE_DMG"
        mv "MacOSX10.11.sdk.tar.xz" "$TOOLS_DIR/osxcross/tarballs"
        UNATTENDED=1 ./build.sh
        if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
        if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
      else
        echo_info "$label is already installed."
      fi
    fi
  fi
fi
if [ $buildIos -eq 1 ]; then
  label="cctools-port"
  yesNoS "Do you want to install $label" 0
  if [ $result -eq 1 ]; then
    if [ ! -f "$XCODE_DMG" ]; then
      echo -e "\e[1;33mNOTE:\e[0m Couldn't find a Xcode 7.3.1 DMG image.\nIf you want to build for macOS and iOS, download it from here (requires a free Apple Developer ID):\n\e[1mhttps://developer.apple.com/download/more/\e[0m\n"
    else
      if [ ! -d "$TOOLS_DIR/cctools-port" ]; then
        # cctools-port (for iOS builds)
        echo_header "Installing $label"
        curl -o "$TOOLS_DIR/cctools-port.zip" "https://codeload.github.com/tpoechtrager/cctools-port/zip/master"
        unzip -q "$TOOLS_DIR/cctools-port.zip" -d "$TOOLS_DIR"
        mv "$TOOLS_DIR/cctools-port-master" "$TOOLS_DIR/cctools-port"
        if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
        if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
      else
        echo_info "$label is already installed."
      fi
    fi
  fi
fi

# Install emscripten
# ----------
if [ $buildWeb -eq 1 ]; then
  label="Emscripten ${emscriptenVersion}"
  yesNoS "Do you want to install $label" 0
  if [ $result -eq 1 ]; then
    if [ ! -d "$TOOLS_DIR/emscripten" ]; then
      mkdir -p "$TOOLS_DIR/emscripten"
    fi
    cd "$TOOLS_DIR/emscripten"

    if [ ! -f "emsdk/emsdk_env.sh" ]; then
      echo_header "Installing $label"
      git clone https://github.com/emscripten-core/emsdk.git
    else
      echo_header "Updating $label"
    fi

    cd emsdk
    git pull

    # NOTE :
    # specify which backend you want to use, either fastcomp or upstream
    # (without specifying the backend, the current default is used)

    # Download and install the SDK tools.
    #./emsdk install ${emscriptenVersion}-fastcomp
    ./emsdk install ${emscriptenVersion}-upstream

    # Set up the compiler configuration to point to the "$version" SDK.
    #./emsdk activate ${emscriptenVersion}-fastcomp
    ./emsdk activate ${emscriptenVersion}-upstream

    # Activate PATH and other environment variables in the current terminal
    #source ./emsdk_env.sh
    source ./emsdk_env.sh --build=Release
    if [ $? -eq 0 ]; then result=1; else result=0; fi # line just for easier comparison with windows.h
    if [ $result -eq 1 ]; then echo_success "$label installed successfully"; else echo_warning "$label installed with error"; fi
  fi
fi
