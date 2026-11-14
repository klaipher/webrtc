# Nanogram: include shims.
#
# The sources of this repository keep the include paths of the Bazel/GN build
# (third_party/ffmpeg/libavcodec/avcodec.h, third_party/openh264/src/codec/api/wels/*.h,
# third_party/opus/src/include/opus.h, third_party/libyuv/include/libyuv/*.h). The CMake build
# gets those libraries from directories chosen by the caller (TG_OWT_*_INCLUDE_PATH,
# TG_OWT_LIBYUV_DIR), so it exposes them under the expected prefix through symbolic links in
# the build tree (never in the source tree), which libwebrtcbuild puts on the include path.
set(nanogram_shim_dir ${CMAKE_CURRENT_BINARY_DIR}/nanogram_shims)

function(nanogram_shim_link target_dir link_relpath)
    if ("${target_dir}" STREQUAL "")
        return()
    endif()
    get_filename_component(link_parent "${nanogram_shim_dir}/${link_relpath}" DIRECTORY)
    file(MAKE_DIRECTORY "${link_parent}")
    file(CREATE_LINK "${target_dir}" "${nanogram_shim_dir}/${link_relpath}" SYMBOLIC)
endfunction()

# Called after external.cmake declared the TG_OWT_*_INCLUDE_PATH cache variables.
function(nanogram_make_include_shims)
    # third_party/ffmpeg/<libavcodec|libavformat|libavutil>/...
    nanogram_shim_link("${TG_OWT_FFMPEG_INCLUDE_PATH}" third_party/ffmpeg)
    # third_party/openh264/src/codec/api/wels/codec_api.h: the include path holds wels/
    nanogram_shim_link("${TG_OWT_OPENH264_INCLUDE_PATH}" third_party/openh264/src/codec/api)
    # third_party/opus/src/include/opus.h: the include path holds opus.h
    nanogram_shim_link("${TG_OWT_OPUS_INCLUDE_PATH}" third_party/opus/src/include)
    # third_party/libyuv/include/libyuv/*.h
    nanogram_shim_link("${TG_OWT_LIBYUV_DIR}" third_party/libyuv)
endfunction()
