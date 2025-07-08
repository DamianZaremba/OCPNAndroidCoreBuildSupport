#!/usr/bin/env bash
#
# This script downloads and cross compiles wxWidgets at a targeted release.
# It assumes that the Android SDK/NDK is already setup on the host machine.
#
set -xe
source "$(dirname $0)/config.sh"

TARGET_RELEASE=$1
TARGET_ARCH=$2
if [ -z "$TARGET_RELEASE" ] || [ -z "$TARGET_ARCH" ];
then
  echo "Usage: $0 <target release> <target arch>"
  exit 1
fi

exit_if_target_release_exists "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}" "${TARGET_RELEASE}"

# Download the target release if we don't have it
if [ ! -f "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}.tar.bz2" ];
then
  echo "Downloading wxWidgets @ ${TARGET_RELEASE}"
  mkdir -p "${WORKING_SRC_DIR}/"
  wget -c -O "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}.tar.bz2" "https://github.com/wxWidgets/wxWidgets/releases/download/v${TARGET_RELEASE}/wxWidgets-${TARGET_RELEASE}.tar.bz2"
fi

# Extract the target release if we don't have it
if [ ! -d "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}" ];
then
  echo "Extracting wxWidgets @ ${TARGET_RELEASE}"
  mkdir -p "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}"
  tar -xf "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}.tar.bz2" -C "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}" --strip-components=1
fi

# Additional dependencies (GTK)
sudo apt-get install -y libgtk-3-dev

# Compile
echo "Setting up build folder for wxWidgets-${TARGET_ARCH}"
mkdir -p "${WORKING_BUILD_DIR}/wxWidgets-${TARGET_ARCH}"
cd "${WORKING_BUILD_DIR}/wxWidgets-${TARGET_ARCH}"

echo "Building wxWidgets for ${TARGET_ARCH}"
set_android_compiler ${TARGET_ARCH}

"${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}/configure" \
  --prefix "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}" \
  --build=x86_64-unknown-linux-gnu \
  --host="${build_target_host}" \
  --with-qt \
  --disable-compat28 \
  --disable-shared \
  --disable-arttango \
  --enable-image \
  --disable-sockets \
  --with-libtiff=no \
  --disable-dragimage \
  --disable-baseevtloop \
  --disable-xrc \
  --disable-cmdline \
  --disable-miniframe \
  --disable-mdi \
  --disable-stc \
  --disable-ribbon \
  --disable-propgrid \
  --disable-detect_sm \
  --disable-prefseditor \
  --disable-svg \
  --disable-fswatcher \
  --disable-largefile \
  --disable-precomp-headers \
  --disable-utf8 \
  QT5_CUSTOM_DIR="${WORKING_DIR}/${BUILD_ARCH}/qt5" \
  CFLAGS="-g -O3 -pthread -fPIC"

make -j${BUILD_NUMBER_OF_CPUS}

# Install
echo "Installing wxWidgets for ${TARGET_ARCH}"
rm -rf "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}"

mkdir -p "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}/"
cp -r "lib" "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}/"

mkdir -p "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}/include/"
cp -r "${WORKING_SRC_DIR}/wxWidgets-${TARGET_RELEASE}/include/wx" "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}/include/"

echo "${TARGET_RELEASE}" > "${WORKING_DIR}/noarch/wxWidgets/${TARGET_ARCH}/.release"
