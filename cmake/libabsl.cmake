# Nanogram: abseil is the official LTS 20260817.0 (third_party/abseil-cpp, one pin for iOS, macOS and
# Android) and is built with its own CMake project. tg_owt's hand-maintained list of absl .cc files
# (written for 20240116) does not match the 20260817 layout. The target list below is the one the
# Android app builds against the same release (TMessagesProj/jni/CMakeLists.txt, webrtc_absl).
#
# If an Apple Clang build rejects ABSL_ATTRIBUTE_LIFETIME_BOUND, run
#   nanogram/apply_abseil_workaround.sh third_party/abseil-cpp <build>/abseil-patched
# and configure with -DTG_OWT_ABSEIL_DIR=<build>/abseil-patched (see NANOGRAM-CHANGES.md).
set(TG_OWT_ABSEIL_DIR "${third_party_loc}/abseil-cpp" CACHE PATH "Path to the abseil 20260817.0 checkout.")

set(ABSL_PROPAGATE_CXX_STD ON CACHE BOOL "" FORCE)
set(ABSL_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(ABSL_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(ABSL_USE_GOOGLETEST_HEAD OFF CACHE BOOL "" FORCE)
add_subdirectory(${TG_OWT_ABSEIL_DIR} ${CMAKE_CURRENT_BINARY_DIR}/abseil EXCLUDE_FROM_ALL)

add_library(libabsl INTERFACE)
add_library(tg_owt::libabsl ALIAS libabsl)
target_link_libraries(libabsl
INTERFACE
    absl::base
    absl::strings
    absl::str_format
    absl::cord
    absl::synchronization
    absl::time
    absl::status
    absl::statusor
    absl::hash
    absl::flat_hash_map
    absl::flat_hash_set
    absl::flags
    absl::flags_parse
    absl::random_random
    absl::random_distributions
    absl::crc32c
    absl::log
    absl::check
)
