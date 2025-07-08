host_build {
    QT_ARCH = arm64
    QT_BUILDABI = arm64-little_endian-lp64
    QT_TARGET_ARCH = arm64
    QT_TARGET_BUILDABI = arm64-little_endian-lp64
} else {
    QT_ARCH = arm64
    QT_BUILDABI = arm64-little_endian-lp64
}
QT.global.enabled_features = shared cross_compile shared thread appstore-compliant c++11 c++14 c++17 c++1z c99 c11 future concurrent signaling_nan
QT.global.disabled_features = framework rpath simulator_and_device debug_and_release build_all c++2a c++2b pkg-config force_asserts separate_debug_info static
QT_CONFIG += shared shared release c++11 c++14 c++17 c++1z concurrent no-pkg-config reduce_exports stl
CONFIG += shared cross_compile shared release
QT_VERSION = 5.15.17
QT_MAJOR_VERSION = 5
QT_MINOR_VERSION = 15
QT_PATCH_VERSION = 17
QT_GCC_MAJOR_VERSION = 4
QT_GCC_MINOR_VERSION = 2
QT_GCC_PATCH_VERSION = 1
QT_APPLE_CLANG_MAJOR_VERSION = 20
QT_APPLE_CLANG_MINOR_VERSION = 0
QT_APPLE_CLANG_PATCH_VERSION = 0
QT_EDITION = OpenSource
