# Generated Android JNI headers

92 headers (`sdk/android/generated_*_jni/*_jni.h`), the output of Chromium's jni_generator over the Android
Java in `sdk/android/**/org/webrtc` and `modules/audio_device/android/java/**/voiceengine`, taken unchanged from
klaipher/nanogram-android `fdd4407` (`TMessagesProj/jni/voip/webrtc/sdk/android/generated_*`). The Android CMake
build has no generator step, so it consumes them as files.

Use: add this directory as an include root next to the repository root, so that
`#include "sdk/android/generated_base_jni/JniCommon_jni.h"` resolves. The headers include
`webrtc/sdk/android/src/jni/jni_generator_helper.h`, so the repository must be reachable as `webrtc/` from an
include root (the Android app mounts it at `jni/voip/webrtc`, with `jni/voip` as include root).

Regenerate when a Java file with `@CalledByNative`/`@NativeMethods` changes. Not carried from Android, because
they are not needed: `experiments/registered_field_trials.h` (CMake generates it from
`experiments/field_trials.py`; the output equals Android's committed copy byte for byte) and the protobuf
outputs `modules/audio_processing/debug.pb.*`, `logging/rtc_event_log/rtc_event_log*.pb.*` (their `.cc`
lines are commented out of the Android CMake and no compiled source needs them).
