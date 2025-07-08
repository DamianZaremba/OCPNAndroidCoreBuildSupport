# Versions to target
: "${PLUGIN_NDK_RELEASE:=29.0.13599879}"
: "${TARGET_ANDROID_API:=34}"
: "${ANDROID_STUDIO_RELEASE:=2025.1.1.13}"
: "${CMD_TOOLS_RELEASE:=13114758_latest}"

# Build variables
WORKING_DIR=$(pwd)
BUILD_ARCH=$(uname -m)
: "${WORKING_SRC_DIR:=${WORKING_DIR}/src}"
: "${WORKING_BUILD_DIR:=${WORKING_DIR}/build}"

# Locations to target
case $(uname -s) in
    Linux)
      ANDROID_STUDIO_DIR=$HOME/android-studio
      ANDROID_SDK_ROOT=$HOME/.android/sdk
      ANDROID_NDK_HOST="linux-x86_64"
      BUILD_NUMBER_OF_CPUS=$(nproc)
    ;;
    Darwin)
      ANDROID_STUDIO_DIR=/Applications/Android\ Studio.app
      ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
      ANDROID_NDK_HOST="darwin-x86_64"
      BUILD_NUMBER_OF_CPUS=$(sysctl -n hw.ncpu)
    ;;
esac

# If the NDK path exists (i.e. we are not in setup.sh)
# Then pull the NDK toolchain into our path
ANDROID_NDK_ROOT="${ANDROID_SDK_ROOT}/ndk/${PLUGIN_NDK_RELEASE}"
ANDROID_NDK_TOOLCHAIN="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${ANDROID_NDK_HOST}"
if [ -d "${ANDROID_NDK_TOOLCHAIN}" ];
then
  echo "Using NDK Toolchain: ${ANDROID_NDK_TOOLCHAIN}"
  export ANDROID_NDK_ROOT="${ANDROID_SDK_ROOT}/ndk/${PLUGIN_NDK_RELEASE}"
  export PATH="${ANDROID_NDK_TOOLCHAIN}/bin:${PATH}"
fi

# Helper functions
function exit_if_target_release_exists() {
  target_directory=$1
  target_release=$2

  if [ -f "${target_directory}/.release" ] && \
     [ "$(cat "${target_directory}/.release")" == "${target_release}" ] && \
     [ -z "$FORCE_REBUILD" ];
  then
    echo "Found target release (${target_release}) already present in ${target_directory}"
    exit 0
  fi
}

function set_android_compiler() {
  target_arch=$1
  case $target_arch in
      arm|armhf)
        export CC="armv7a-linux-androideabi${TARGET_ANDROID_API}-clang"
        export CXX="armv7a-linux-androideabi${TARGET_ANDROID_API}-clang++"
        export build_target_host="armv7a-linux-androideabi${TARGET_ANDROID_API}"
        export AR="llvm-ar"
      ;;
      arm64)
        export CC="aarch64-linux-android${TARGET_ANDROID_API}-clang"
        export CXX="aarch64-linux-android${TARGET_ANDROID_API}-clang++"
        export build_target_host="aarch64-linux-android${TARGET_ANDROID_API}"
        export AR="llvm-ar"
      ;;
  esac
}
