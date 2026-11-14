# webrtc (Nanogram fork) changelog

Branch `nanogram` (alias `nanogram-security-fixes`), the WebRTC tree built by Nanogram for iOS, macOS and Android. Base: `M123` (ali-fareed/webrtc).

Newest first. Fork-only commits, grouped by day; entries for new work go on top under `## Unreleased`, then are
moved under their date when the app repositories pin them.

## Unreleased

- jni_zero/scoped_java_ref.h includes <iterator> (std::input_iterator_tag did not compile on its own with the NDK 30 libc++; found by the syntax-only check of the carried third_party files).
- macOS CMake builds `rtc_base/boringssl_certificate.cc` and `boringssl_identity.cc` (the iOS and Android lists already had them). The Mac moves from OpenSSL to the shared BoringSSL headers (`TG_OWT_OPENSSL_INCLUDE_PATH`); with BoringSSL `ssl_identity.cc`, `ssl_certificate.cc` and `openssl_stream_adapter.cc` use `BoringSSLIdentity` and `BoringSSLCertificate`, so without these two files the Mac link fails. `nanogram/build-files/mac-cmake.txt` regenerated (1,462 to 1,464 sources). Not built.
- Records: libyuv is named as klaipher/libyuv `nanogram` 947f5326 (upstream 0b8dd231 minus the Bazel files), not 'the official 0b8dd231'; the behaviour-jump list now names the Mac items (reflector ports under 1024, TGCALLS seams, H.264 decoder gate, FFmpeg 7+ pts fix).
- third_party/libevent removed (84 files): Android moved to the stdlib task queue, iOS and the Mac never compiled libevent. The three build-file lists were regenerated from the integrated app build files (mac 1,462, Android 1,343, iOS 1,288, common 1,113) and BUILD-FILES.md updated.
- CMake abseil: libabsl is an INTERFACE target over abseil's STATIC archives, which a static `libtg_owt.a` does not absorb (tg_owt had them as an OBJECT library inside it); the Mac ships only that archive. On Apple platforms `cmake/libabsl.cmake` now collects the transitive abseil archives and merges them into `libtg_owt.a` after the build (`libtool -static`, option `TG_OWT_MERGE_ABSEIL`, default ON). Check `nm -u` on the final archive.
- Android Java: `sdk/android/api/org/webrtc/EglThread.java` removed (and its `sdk/android/BUILD.gn` entry). It needs `EglBase.EglConnection`, which the Telegram-modified `EglBase.java` folded in with the Android Java does not have, and the Android app never compiled it. The srcDirs class set is now exactly Android's 173 files (checked both ways with `comm -3`).
- CMake libyuv list: the MSA header and sources are gone from `cmake/libyuv.cmake` (and its remove block). The single libyuv (klaipher/libyuv 947f5326) no longer has them, and CMake stops at configure on a missing source file. All 71 remaining paths exist in 947f5326.
- One source for iOS, macOS and Android: debug-log hunks dropped; abseil LTS 20260817.0 (`absl_nonnull`/`absl_nullable`); libsrtp v2.5.0, crc32c 21fc8ef3, usrsctp removed; pffft, rnnoise, libevent, jni_zero under `third_party/`; macOS audio device, Metal renderer, OpenSSL accessors, include hygiene, ICE comparator fix; Android legacy audio device, iSAC, JVM thread tracking, H.265 bounds checks, Java and generated JNI headers; the CMake build at the repository root with include shims. Details in NANOGRAM-CHANGES.md.
- Merge Telegram's webrtc 590a8b2 ("Check vector sizes when crossfading from CNG/expand to normal", CVE-2026-9119) into the fork. Its `normal.cc` and `normal.h` are byte-identical to our 0ee3826 (verified with `git diff` of both blobs), so the code stays as is; `normal_unittest.cc` takes upstream's version (our 0ee3826 test edit of `LastModeRfc3389CngSmallInput` is replaced). Merged, not rebased: the pin moves forward without a force-push, and 590a8b2 is now an ancestor, so the next upstream sync starts from it. The other 11 fork fixes are untouched (`git diff` 86cd593..merge touches only `normal_unittest.cc`).

## 2026-11-04

- Check desktop capture bounds during resolution changes (2c6b83a)
- Clamp NetEq crossfades to the available audio samples (0ee3826)
- Reject wrapped packet sequences beyond the FEC mask (2623f0b)
- Avoid integer overflow in UniqueTimestampCounter (fdb34df)
- Limit remote simulcast layers to the codec capacity (96d5e31)
- Reject SCTP acknowledgments beyond sent data (82a3e8b)
- Clear channels before removing stopped transceivers (2627100)
- Fix VP8 temporal layer bounds checking (0d3db3a)
- Route OpenH264 encoder messages to the WebRTC log (69cd34d)
- Fix possible use-after-free on GOOG_DELTA_ACK (7a953a0)
- Fix possible crash on DTLS/SCTP in unsupported media (f0cb1f3)
- Fix possible crash on zero-length GOOG_MISC_INFO (095a245)

## 2026-09-19

- tgcalls seam: RTCConfiguration::disable_payload_type_demuxing (6513c71)

