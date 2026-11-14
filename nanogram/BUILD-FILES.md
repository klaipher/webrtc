# Which files each platform compiles

One source tree, three build systems. The lists in `nanogram/build-files/` are generated, not hand-kept:

```
python3 -I nanogram/gen_build_lists.py mac                                  > build-files/mac-cmake.txt
python3 -I nanogram/gen_build_lists.py android <app>/jni/voip/CMakeLists.txt > build-files/android-cmake.txt
python3 -I nanogram/gen_build_lists.py ios     <app>/third-party/webrtc/BUILD > build-files/ios-bazel.txt
```

A list holds the source files (`.c .cc .cpp .mm .m .S .inc`) that platform's build file names, as paths
relative to this repository. Conditionals (`select()`, CMake `if`, `remove_target_sources`) are not evaluated, so
a list is the superset a platform can compile. Entries that are not tracked here (abseil, libsrtp, crc32c,
libyuv, system libraries) are printed to stderr by the script and are not listed.

| Platform | Build file | Sources | List |
|---|---|---|---|
| macOS | `CMakeLists.txt` + `cmake/*.cmake` (this repository) | 1,464 | `build-files/mac-cmake.txt` |
| Android | `TMessagesProj/jni/voip/CMakeLists.txt` (app) | 1,343 | `build-files/android-cmake.txt` |
| iOS | `third-party/webrtc/BUILD` (app) | 1,288 | `build-files/ios-bazel.txt` |

1,113 files are compiled by all three (`build-files/common-all-three.txt`). The platform-only parts:

- **iOS only (9)**: UIKit/Metal views and `UIDevice` helpers under `sdk/objc` (7), and the two
  `api/task_queue/default_task_queue_factory_*libevent*.cc` files the iOS BUILD names (the iOS build uses the GCD task queue).
- **macOS only (164)**: `modules/desktop_capture` (100; the list includes the Windows and Linux entries behind
  CMake conditions), the macOS and desktop audio/video-capture backends, `sdk/objc` AppKit pieces.
- **Android only (195)**: `sdk/android` JNI and native API (85), the iSAC codec (62), the legacy Java/OpenSL ES/AAudio
  audio device `modules/audio_device/android` (9 of its 28 files are .cc files the app compiles; AAudio is not built, the rest are headers),
  `rtc_base/ifaddrs_android.cc`, test utilities
  (`virtual_socket_server`, `nat_*`, `fake_clock`, ...), `audio/voip`.

## Per-platform build settings (what is not in the file lists)

- **Defines.** `WEBRTC_USE_H264` and `WEBRTC_USE_H264_DECODER` (the FFmpeg decoder gate) on every platform that
  links FFmpeg. Android adds `WEBRTC_ANDROID WEBRTC_LINUX WEBRTC_POSIX`, and
  drops `WEBRTC_HAVE_USRSCTP`, `__Userspace__`, `SCTP_*` (usrsctp is not part of any build any more).
- **Include roots.** The repository root, plus: `third_party/abseil-cpp` (abseil LTS 20260817.0),
  `third_party/libsrtp/include`, `third_party/libsrtp/crypto/include`, `third_party/libsrtp_config` (the one
  `config.h`, needs `-DHAVE_CONFIG_H`), `third_party/crc32c/src/include`, (there is no libevent: Android uses the stdlib task queue, `task_queue_stdlib.cc`). Android also needs `nanogram/android-generated` as an include root (the generated headers include `third_party/jni_zero/jni_export.h`, which resolves from the repository root).
- **Prefixes the sources use.** `third_party/ffmpeg/<libav*>/...`, `third_party/openh264/src/codec/api/wels/...`,
  `third_party/opus/src/include/...`, `third_party/libyuv/include/libyuv/...`. macOS builds symlinks for them in the
  build tree (`cmake/nanogram_shims.cmake`); Bazel and Android map the same prefixes in their own files.
- **libyuv** is not in this repository: every consumer points at the one libyuv the apps pin, klaipher/libyuv `nanogram` (947f5326 = upstream 0b8dd231 minus the Bazel files).
  Its AArch64 Neon kernels need `-march=armv8-a+dotprod+i8mm` and `LIBYUV_DISABLE_SVE`/`LIBYUV_DISABLE_SME`.
- **abseil** `ABSL_ATTRIBUTE_LIFETIME_BOUND`: if Apple Clang rejects it, `nanogram/apply_abseil_workaround.sh`
  builds a patched copy (see NANOGRAM-CHANGES.md).
- **x86 AVX2** (Android x86/x86_64 only): the Android app used to comment the AVX2 dispatch out of six sources
  because it did not pass `-mavx2 -mfma`; those edits are not carried. Compile the `*_avx2.cc` files with
  `-mavx2 -mfma`, as upstream does. arm64 and arm64-v8a are unaffected.
- **Generated files.** `experiments/registered_field_trials.h` comes from `experiments/field_trials.py header`
  (CMake does this for macOS; Android's committed copy is byte-identical to the output). Android's JNI headers are
  carried in `nanogram/android-generated/` (see its README).

## Android Java source directories (Gradle `srcDirs`, tests excluded)

- `sdk/android/api`
- `sdk/android/src/java`
- `modules/audio_device/android/java/src` (the `org.webrtc.voiceengine` classes)
- `rtc_base/java/src`

The Java here that Telegram modified imports `org.telegram.*` classes, so it compiles only inside the Android app.
