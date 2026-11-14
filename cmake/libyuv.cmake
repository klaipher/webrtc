add_library(libyuv OBJECT EXCLUDE_FROM_ALL)
init_target(libyuv)
add_library(tg_owt::libyuv ALIAS libyuv)

link_libjpeg(libyuv)

# Nanogram: libyuv is the one official source (0b8dd231) that the app repositories pin; this
# repository does not carry it. Pass -DTG_OWT_LIBYUV_DIR=<path to the libyuv checkout>.
set(TG_OWT_LIBYUV_DIR "" CACHE PATH "Path to the libyuv checkout (include/, source/).")
if (TG_OWT_LIBYUV_DIR STREQUAL "")
    message(FATAL_ERROR "You should specify 'TG_OWT_LIBYUV_DIR'.")
endif()
set(libyuv_loc ${TG_OWT_LIBYUV_DIR})

nice_target_sources(libyuv ${libyuv_loc}
PRIVATE
    include/libyuv.h
    include/libyuv/basic_types.h
    include/libyuv/compare.h
    include/libyuv/compare_row.h
    include/libyuv/convert.h
    include/libyuv/convert_argb.h
    include/libyuv/convert_from.h
    include/libyuv/convert_from_argb.h
    include/libyuv/cpu_id.h
    include/libyuv/loongson_intrinsics.h
    include/libyuv/macros_msa.h
    include/libyuv/mjpeg_decoder.h
    include/libyuv/planar_functions.h
    include/libyuv/rotate.h
    include/libyuv/rotate_argb.h
    include/libyuv/rotate_row.h
    include/libyuv/row.h
    include/libyuv/scale.h
    include/libyuv/scale_argb.h
    include/libyuv/scale_rgb.h
    include/libyuv/scale_row.h
    include/libyuv/scale_uv.h
    include/libyuv/version.h
    include/libyuv/video_common.h

    # Source Files
    source/compare.cc
    source/compare_common.cc
    source/compare_gcc.cc
    source/compare_win.cc
    source/convert.cc
    source/convert_argb.cc
    source/convert_from.cc
    source/convert_from_argb.cc
    source/convert_jpeg.cc
    source/convert_to_argb.cc
    source/convert_to_i420.cc
    source/cpu_id.cc
    source/mjpeg_decoder.cc
    source/mjpeg_validate.cc
    source/planar_functions.cc
    source/rotate.cc
    source/rotate_any.cc
    source/rotate_argb.cc
    source/rotate_common.cc
    source/rotate_gcc.cc
    source/rotate_win.cc
    source/row_any.cc
    source/row_common.cc
    source/row_gcc.cc
    source/row_win.cc
    source/scale.cc
    source/scale_any.cc
    source/scale_argb.cc
    source/scale_common.cc
    source/scale_gcc.cc
    source/scale_uv.cc
    source/scale_win.cc
    source/video_common.cc

    # LSX
    source/rotate_lsx.cc
    source/row_lasx.cc
    source/row_lsx.cc
    source/scale_lsx.cc

    # ARM neon
    source/compare_neon.cc
    source/compare_neon64.cc
    source/rotate_neon.cc
    source/rotate_neon64.cc
    source/row_neon.cc
    source/row_neon64.cc
    source/scale_neon.cc
    source/scale_neon64.cc

    # MSA Source Files
    source/compare_msa.cc
    source/rotate_msa.cc
    source/row_msa.cc
    source/scale_msa.cc

    # RISC-V RVV
    source/row_rvv.cc
    source/scale_rvv.cc

    # Nanogram: sources that exist in the official libyuv 0b8dd231 and not in the
    # 04821d1e snapshot tg_owt built (iOS builds scale_rgb.cc too).
    source/scale_rgb.cc
)

# libyuv 0b8dd231: SVE/SME kernels stay off (as in the iOS BUILD), and the AArch64 Neon
# kernels use dot-product and i8mm instructions (iOS: -march=armv8-a+dotprod+i8mm).
target_compile_definitions(libyuv
PRIVATE
    LIBYUV_DISABLE_SVE
    LIBYUV_DISABLE_SME
)

remove_target_sources(libyuv ${libyuv_loc}

    # MSA Source Files
    source/compare_msa.cc
    source/rotate_msa.cc
    source/row_msa.cc
    source/scale_msa.cc
)

if (arm_use_neon)
    target_compile_definitions(libyuv
    PRIVATE
        LIBYUV_NEON
    )
    set_source_files_properties(
        ${libyuv_loc}/source/compare_neon64.cc
        ${libyuv_loc}/source/rotate_neon64.cc
        ${libyuv_loc}/source/row_neon64.cc
        ${libyuv_loc}/source/scale_neon64.cc
        PROPERTIES COMPILE_OPTIONS "-march=armv8-a+dotprod+i8mm"
    )
else()
    target_compile_definitions(libyuv
    PRIVATE
        LIBYUV_DISABLE_NEON
    )
    remove_target_sources(libyuv ${libyuv_loc}

        # ARM neon
        source/compare_neon.cc
        source/compare_neon64.cc
        source/rotate_neon.cc
        source/rotate_neon64.cc
        source/row_neon.cc
        source/row_neon64.cc
        source/scale_neon.cc
        source/scale_neon64.cc
    )
endif()

if (riscv_use_rvv)
    target_compile_definitions(libyuv
    PRIVATE
        USE_RVV
    )
else()
    target_compile_definitions(libyuv
    PRIVATE
        LIBYUV_DISABLE_RVV
    )
    remove_target_sources(libyuv ${libyuv_loc}

        # RISC-V RVV
        source/row_rvv.cc
        source/scale_rvv.cc
    )
endif()

target_include_directories(libyuv
PUBLIC
    $<BUILD_INTERFACE:${libyuv_loc}/include>
    $<INSTALL_INTERFACE:${webrtc_includedir}/third_party/libyuv/include>
)

target_compile_definitions(libyuv
PRIVATE
    HAVE_JPEG
)
