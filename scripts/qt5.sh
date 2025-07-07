#!/usr/bin/env bash
#
# This script downloads and cross compiles QT5 at a targeted release.
# It assumes that the Android SDK/NDK is already setup on the host machine.
#
set -xe
source "$(dirname $0)/config.sh"

TARGET_RELEASE=$1
if [ -z "$TARGET_RELEASE" ];
then
  echo "Usage: $0 <target release>"
  exit 1
fi

exit_if_target_release_exists "${WORKING_DIR}/${BUILD_ARCH}/qt5" "${TARGET_RELEASE}"

# Download the target release if we don't have it
if [ ! -f "${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}.tar.xz" ];
then
  major_release=$(echo "${TARGET_RELEASE}" | cut -d. -f1-2)
  echo "Downloading QT5 @ ${TARGET_RELEASE} (${major_release})"
  mkdir -p "${WORKING_SRC_DIR}/"
  wget -c -O "${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}.tar.xz" "https://download.qt.io/official_releases/qt/${major_release}/${TARGET_RELEASE}/single/qt-everywhere-opensource-src-${TARGET_RELEASE}.tar.xz"
fi

if [ ! -d "${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}" ];
then
  echo "Extracting QT5 @ ${TARGET_RELEASE}"
  mkdir -p "${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}"
  tar -xf "${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}.tar.xz" -C "${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}" --strip-components=1
fi

# Compile
echo "Setting up build folder for qt5-${TARGET_ARCH}"
mkdir -p "${WORKING_BUILD_DIR}/qt5-${BUILD_ARCH}"
cd "${WORKING_BUILD_DIR}/qt5-${BUILD_ARCH}"

# Ensure we are using an old JDK (7 not 8 target support)
if [ "$(uname -s)" == "Darwin" ];
then
  export PATH="/opt/homebrew/opt/openjdk@17/bin:${PATH}"
  export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
fi

echo "Building QT5 for ${BUILD_ARCH}"
"${WORKING_SRC_DIR}/qt-everywhere-opensource-src-${TARGET_RELEASE}/configure" \
  -opensource \
  -confirm-license \
  -xplatform android-clang \
  -prefix "${WORKING_DIR}/${BUILD_ARCH}/qt5" \
  -android-sdk "${ANDROID_SDK_ROOT}" \
  -android-ndk "${ANDROID_NDK_ROOT}" \
  -android-ndk-host "${ANDROID_NDK_HOST}" \
  -android-abis armeabi-v7a,arm64-v8a \
  -nomake tests \
  -nomake examples \
  -no-warnings-are-errors \
  -disable-rpath \
  -skip qt3d \
  -skip qtactiveqt \
  -skip qtcharts \
  -skip qtconnectivity \
  -skip qtdatavis3d \
  -skip qtdeclarative \
  -skip qtdoc \
  -skip qtgamepad \
  -skip qtgraphicaleffects \
  -skip qtimageformats \
  -skip qtlocation \
  -skip qtlottie \
  -skip qtmacextras \
  -skip qtmultimedia \
  -skip qtnetworkauth \
  -skip qtpurchasing \
  -skip qtquick3d \
  -skip qtquickcontrols \
  -skip qtquickcontrols2 \
  -skip qtquicktimeline \
  -skip qtremoteobjects \
  -skip qtscript \
  -skip qtscxml \
  -skip qtsensors \
  -skip qtserialbus \
  -skip qtserialport \
  -skip qtspeech \
  -skip qtsvg \
  -skip qttools \
  -skip qttranslations \
  -skip qtvirtualkeyboard \
  -skip qtwayland \
  -skip qtwebchannel \
  -skip qtwebengine \
  -skip qtwebglplugin \
  -skip qtwebsockets \
  -skip qtwebview \
  -skip qtwinextras \
  -skip qtx11extras \
  -skip qtxmlpatterns

make -j${BUILD_NUMBER_OF_CPUS}

# Install
echo "Installing QT5 for ${BUILD_ARCH}"
rm -rf "${WORKING_DIR}/${BUILD_ARCH}/qt5"
make -j${BUILD_NUMBER_OF_CPUS} install

echo "${TARGET_RELEASE}" > "${WORKING_DIR}/${BUILD_ARCH}/qt5/.release"
