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

# Nanogram: tg_owt built abseil as an OBJECT library, so its objects ended up inside libtg_owt.a, the only
# WebRTC archive the Mac app links. abseil's own targets are separate STATIC archives, and a static
# library does not absorb the archives it links. On Apple platforms the abseil archives are therefore
# merged into libtg_owt.a after it is built (libtool -static). Set TG_OWT_MERGE_ABSEIL=OFF when the final
# link names the abseil archives itself. Verify with `nm -u` on the merged archive.
function(tg_owt_collect_absl_archives out_var)
    set(todo ${ARGN})
    set(seen "")
    set(archives "")
    while (NOT "${todo}" STREQUAL "")
        list(POP_FRONT todo item)
        string(REGEX REPLACE "^\\$<LINK_ONLY:(.*)>$" "\\1" item "${item}")
        if (NOT item MATCHES "^absl(::|_)" OR NOT TARGET ${item})
            continue()
        endif()
        get_target_property(aliased ${item} ALIASED_TARGET)
        if (aliased)
            set(item ${aliased})
        endif()
        if (item IN_LIST seen)
            continue()
        endif()
        list(APPEND seen ${item})
        get_target_property(item_type ${item} TYPE)
        if (item_type STREQUAL "STATIC_LIBRARY")
            list(APPEND archives ${item})
            get_target_property(item_deps ${item} LINK_LIBRARIES)
            if (item_deps)
                list(APPEND todo ${item_deps})
            endif()
        endif()
        get_target_property(item_iface_deps ${item} INTERFACE_LINK_LIBRARIES)
        if (item_iface_deps)
            list(APPEND todo ${item_iface_deps})
        endif()
    endwhile()
    set(${out_var} ${archives} PARENT_SCOPE)
endfunction()

option(TG_OWT_MERGE_ABSEIL "Merge the abseil archives into libtg_owt.a (Apple platforms)." ON)
if (APPLE AND TG_OWT_MERGE_ABSEIL)
    tg_owt_collect_absl_archives(TG_OWT_ABSEIL_ARCHIVES
        absl::base absl::strings absl::str_format absl::cord absl::synchronization absl::time
        absl::status absl::statusor absl::hash absl::flat_hash_map absl::flat_hash_set absl::flags
        absl::flags_parse absl::random_random absl::random_distributions absl::crc32c absl::log absl::check)
    set(TG_OWT_ABSEIL_ARCHIVE_FILES "")
    foreach (archive ${TG_OWT_ABSEIL_ARCHIVES})
        list(APPEND TG_OWT_ABSEIL_ARCHIVE_FILES "$<TARGET_FILE:${archive}>")
    endforeach()
    # Nanogram: tg_owt is defined before this file is included (see CMakeLists.txt).
    add_dependencies(tg_owt ${TG_OWT_ABSEIL_ARCHIVES})
    add_custom_command(TARGET tg_owt POST_BUILD
        COMMAND libtool -static -o "$<TARGET_FILE:tg_owt>.merged"
            "$<TARGET_FILE:tg_owt>" ${TG_OWT_ABSEIL_ARCHIVE_FILES}
        COMMAND ${CMAKE_COMMAND} -E rename "$<TARGET_FILE:tg_owt>.merged" "$<TARGET_FILE:tg_owt>"
        COMMENT "Merging the abseil archives into libtg_owt.a"
        VERBATIM)
endif()
