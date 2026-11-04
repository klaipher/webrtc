# webrtc (Nanogram fork) changelog

Branch `nanogram-security-fixes`, the WebRTC tree built by Nanogram for iOS (`third-party/webrtc/webrtc`). Base: `M123` (ali-fareed/webrtc).

Newest first. Fork-only commits, grouped by day; entries for new work go on top under `## Unreleased`, then are
moved under their date when the app repositories pin them.

## Unreleased

(none)

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

