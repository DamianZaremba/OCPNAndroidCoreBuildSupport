#!/usr/bin/env bash
#
# This script sets up Android Studio with the relevant SDKs
#
set -xe
source "$(dirname $0)/config.sh"

# Dependencies
case $(uname -s) in
    Linux)
      sudo apt-get install -y wget default-jdk
    ;;
    Darwin)
      brew install openjdk@17 wget gtk+3
    ;;
esac

# Command line tools
if [ ! -d "${ANDROID_SDK_ROOT}/cmdline-tools" ];
then
  mkdir -p "${ANDROID_SDK_ROOT}"
  case $(uname -s) in
      Linux)
        wget -cO /tmp/commandlinetools-linux-${CMD_TOOLS_RELEASE}.zip https://dl.google.com/android/repository/commandlinetools-linux-${CMD_TOOLS_RELEASE}.zip
        unzip -od "${ANDROID_SDK_ROOT}" "/tmp/commandlinetools-linux-${CMD_TOOLS_RELEASE}.zip"
      ;;
      Darwin)
        wget -cO /tmp/commandlinetools-mac-${CMD_TOOLS_RELEASE}.zip https://dl.google.com/android/repository/commandlinetools-mac-${CMD_TOOLS_RELEASE}.zip
        unzip -od "${ANDROID_SDK_ROOT}" "/tmp/commandlinetools-mac-${CMD_TOOLS_RELEASE}.zip"
      ;;
  esac
fi

## If the cmdline-tools plugin was installed via the UI it can end up in a sub dir,
## try and find it to support both our install and an existing development environment
if [ -x "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" ];
then
  ANDROID_SDK_MANAGER="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT}"
else
  ANDROID_SDK_MANAGER="${ANDROID_SDK_ROOT}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT}"
fi
echo "Using SDK Manager @ $ANDROID_SDK_MANAGER"

# Accept licenses
yes | $ANDROID_SDK_MANAGER --sdk_root="${ANDROID_SDK_ROOT}" --licenses

# NDK
if [ ! -d "${ANDROID_SDK_ROOT}/ndk/${PLUGIN_NDK_RELEASE}" ];
then
  echo "Installing NDK plugin @ ${PLUGIN_NDK_RELEASE}"
  $ANDROID_SDK_MANAGER --sdk_root="${ANDROID_SDK_ROOT}" --install "ndk;${PLUGIN_NDK_RELEASE}"
fi

# SDK
if [ ! -d "${ANDROID_SDK_ROOT}/platforms/android-${TARGET_ANDROID_API}" ];
then
  echo "Installing SDK for ${TARGET_ANDROID_API}"
  $ANDROID_SDK_MANAGER --sdk_root="${ANDROID_SDK_ROOT}" --install "platforms;android-${TARGET_ANDROID_API}"
fi

# Symlinks
if [ ! -x "${ANDROID_NDK_TOOLCHAIN}/bin/arm-linux-androideabi-ranlib" ];
then
  ln -sf "${ANDROID_NDK_TOOLCHAIN}/bin/llvm-ranlib" "${ANDROID_NDK_TOOLCHAIN}/bin/arm-linux-androideabi-ranlib"
fi
if [ ! -x "${ANDROID_NDK_TOOLCHAIN}/bin/aarch64-linux-androideabi-ranlib" ];
then
  ln -sf "${ANDROID_NDK_TOOLCHAIN}/bin/llvm-ranlib" "${ANDROID_NDK_TOOLCHAIN}/bin/aarch64-linux-android-ranlib"
fi
