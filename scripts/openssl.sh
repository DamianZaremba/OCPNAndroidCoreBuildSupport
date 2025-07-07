#!/usr/bin/env bash
#
# This script downloads and cross compiles OpenSSL at a targeted release.
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

exit_if_target_release_exists "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}" "${TARGET_RELEASE}"

# Download the target release if we don't have it
if [ ! -f "${WORKING_SRC_DIR}/openssl-${TARGET_RELEASE}.tar.gz" ];
then
  echo "Downloading OpenSSL @ ${TARGET_RELEASE}"
  mkdir -p "${WORKING_SRC_DIR}/"
  wget -c -O "${WORKING_SRC_DIR}/openssl-${TARGET_RELEASE}.tar.gz" "https://github.com/openssl/openssl/releases/download/openssl-${TARGET_RELEASE}/openssl-${TARGET_RELEASE}.tar.gz"
fi

# Compile
echo "Setting up build folder for openssl-${TARGET_ARCH}"
if [ ! -d "${WORKING_BUILD_DIR}/openssl-${TARGET_ARCH}" ];
then
  mkdir -p "${WORKING_BUILD_DIR}/openssl-${TARGET_ARCH}"
  tar -xf "${WORKING_SRC_DIR}/openssl-${TARGET_RELEASE}.tar.gz" -C "${WORKING_BUILD_DIR}/openssl-${TARGET_ARCH}" --strip-components=1
fi
cd "${WORKING_BUILD_DIR}/openssl-${TARGET_ARCH}"

echo "Building OpenSSL for ${TARGET_ARCH}"
set_android_compiler ${TARGET_ARCH}
./Configure android-${TARGET_ARCH} -D__ANDROID_API__="${TARGET_ANDROID_API}" no-shared

make -j${BUILD_NUMBER_OF_CPUS}

# Install
echo "Installing OpenSSL for ${TARGET_ARCH}"
rm -rf "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}"

mkdir -p "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}/lib/"
cp "libcrypto.a" "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}/lib/"
cp "libssl.a" "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}/lib/"

mkdir -p "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}/include/"
cp -r "include/openssl" "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}/include/"

echo "${TARGET_RELEASE}" > "${WORKING_DIR}/noarch/openssl/${TARGET_ARCH}/.release"
