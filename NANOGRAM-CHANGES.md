# How this WebRTC tree differs from M123

Upstream: https://github.com/ali-fareed/webrtc (branch `M123`, the tree Telegram-iOS builds). Ours: branch
`nanogram` (the old name `nanogram-security-fixes` stays as an alias until every consumer pin has moved), based on
upstream 590a8b2 (6513c71 + the CVE-2026-9119 NetEq fix), checked 2026-11-07. It is the one WebRTC source for
Nanogram iOS, macOS and Android. History: [CHANGELOG.md](CHANGELOG.md). Build files per platform:
[nanogram/BUILD-FILES.md](nanogram/BUILD-FILES.md).
Format: docs/fork-records.md in klaipher/nanogram.

### Security and crash fixes ported from desktop-app/tg_owt
- What: 12 fixes that desktop-app/tg_owt carries (2026-10): zero-length GOOG_MISC_INFO, DTLS/SCTP in unsupported media,
  use-after-free on GOOG_DELTA_ACK, VP8 temporal layer bounds, clearing channels before removing stopped transceivers,
  SCTP acknowledgments beyond sent data, remote simulcast layer limit, UniqueTimestampCounter overflow, FEC mask
  sequence wrap, NetEq crossfade clamp (since 590a8b2 upstream carries the same code, byte-identical `normal.cc`/`normal.h`; this one is no longer a difference), desktop capture bounds during resolution changes, OpenH264 messages to the WebRTC log.
- Why: remote crash and memory-safety findings; keeps iOS equal to the Mac's tg_owt.
- Where: `pc/`, `net/dcsctp/tx/`, `modules/audio_coding/neteq/`, `modules/rtp_rtcp/source/`, `modules/video_coding/`,
  `video/`, `modules/desktop_capture/`; each fix carries a unit test where WebRTC has a test target for it.
- Upstream: yes (they are upstream tg_owt fixes).
- Sync: after an upstream move, `git diff <upstream>:modules/audio_coding/neteq/normal.cc <ours>:...` must stay empty. The allow-listed difference list in `docs/mac-core-paths.txt` of klaipher/nanogram names the 7 seam files
  that legitimately differ from tg_owt; `tools/dev/parity` checks the rest.

### tgcalls seam
- What: `RTCConfiguration::disable_payload_type_demuxing` and its plumbing (6513c71).
- Where: `api/peer_connection_interface.*`, `pc/peer_connection*`, `pc/sdp_offer_answer.cc`, `pc/webrtc_sdp.cc`.
- Upstream: no (needed by tgcalls). Sync: re-apply when moving to a newer WebRTC branch.

### One source for iOS, macOS and Android (2026-11)
- What: this tree now carries what the three apps used to keep apart.
  - macOS (from klaipher/tg_owt `nanogram-mac`): audio device (device UID, no key-state polling, no pan-right mixdown,
    1 ms timer clamp), Metal renderer on the main display's GPU (`TARGET_OS_OSX`), OpenSSL 1.1+/3 certificate
    accessors, libc++ include fixes, ICE controller comparator fix, empty-rect check in the desktop differ, and the
    CMake build at the root (`CMakeLists.txt`, `cmake/`).
  - Android: the legacy Java/OpenSL ES/AAudio audio device (`modules/audio_device/android`, wired into
    `audio_device_impl.cc`), iSAC, JVM thread tracking, H.265 parser bounds checks, the `org.webrtc` Java the app
    modifies, and the generated JNI headers (`nanogram/android-generated`).
  - Dependencies: abseil LTS 20260817.0, libsrtp v2.5.0 and crc32c 21fc8ef3 as submodules; pffft, rnnoise (the
    Chromium VAD weights), libevent and jni_zero as snapshots under `third_party/`. usrsctp is gone.
  - `absl::Nonnull<T>`/`absl::Nullable<T>` became `T absl_nonnull`/`T absl_nullable` (91 uses, 24 files); the debug
    log counters were removed.
- Why: a fix in shared native code has to land once and reach every app.
- Where: see the commits since 779c4aa7 on `nanogram`.
- Upstream: no.
- Sync: after an upstream move, re-run `nanogram/gen_build_lists.py` for each platform and compare the lists.
- Behaviour jumps to test: libsrtp 2.2.0 -> 2.5.0 on iOS and Android (SRTP interop), abseil on all three, Apple Clang vs
  `ABSL_ATTRIBUTE_LIFETIME_BOUND` (fallback patch in `patches/`).
- Not carried, on purpose: Windows/Linux/FreeBSD desktop-app edits, the system-libsrtp option, Telegram's `FileLog`
  debug counters, Android's commented-out AVX2 dispatch (use `-mavx2 -mfma`).

### CMake libyuv list follows the single libyuv
- What: `cmake/libyuv.cmake` no longer names `include/libyuv/macros_msa.h` and `source/{compare,rotate,row,scale}_msa.cc`, and the remove_target_sources block for them is gone.
- Why: libyuv 947f5326 (klaipher/libyuv, used through TG_OWT_LIBYUV_DIR by the Mac build) has no MSA files; `remove_target_sources` only marks them header-only, CMake still needs them to exist, so configure failed.

### EglThread.java removed
- What: `sdk/android/api/org/webrtc/EglThread.java` is deleted (also from `sdk/android/BUILD.gn`).
- Why: it imports `EglBase.EglConnection`, which the Telegram-modified `EglBase.java` (folded in with the Android Java, 8cf9fad) does not have, so Gradle compiling the srcDirs failed. The Android app never carried the class. The srcDirs class set is now exactly the 173 files of the old `org/webrtc` set (checked in both directions).
- Where: `sdk/android/api/org/webrtc/`.
- Upstream: no. Sync: if `EglBase.java` ever gets `EglConnection` back, the class can return.
