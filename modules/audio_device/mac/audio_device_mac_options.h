#ifndef MODULES_AUDIO_DEVICE_MAC_AUDIO_DEVICE_MAC_OPTIONS_H_
#define MODULES_AUDIO_DEVICE_MAC_AUDIO_DEVICE_MAC_OPTIONS_H_

#include <atomic>

namespace webrtc {

// Runtime options for the macOS audio device. Nanogram-only. Defaults keep the upstream
// behaviour except for key-state polling, which nothing consumes (see pollKeyState()).
struct AudioDeviceMacOptions {
  // Upstream asks the HID system for the state of every virtual key (about 93 calls) on
  // each 10 ms capture iteration to feed the transient suppressor's typing status. No
  // call path enables the transient suppressor (config.transient_suppression.enabled is
  // false and WebRtcVoiceEngine never sets it), so the result is never used. Off by default.
  static std::atomic<bool>& pollKeyState() {
    static std::atomic<bool> value{false};
    return value;
  }
};

}  // namespace webrtc

#endif  // MODULES_AUDIO_DEVICE_MAC_AUDIO_DEVICE_MAC_OPTIONS_H_
