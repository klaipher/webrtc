# How this WebRTC tree differs from M123

Upstream: https://github.com/ali-fareed/webrtc (branch `M123`, the tree Telegram-iOS builds). Ours: branch
`nanogram-security-fixes`, 13 commits, 40 files, +536/-113 at 2026-11-05. History: [CHANGELOG.md](CHANGELOG.md).
Format: docs/fork-records.md in klaipher/nanogram.

### Security and crash fixes ported from desktop-app/tg_owt
- What: 12 fixes that desktop-app/tg_owt carries (2026-10): zero-length GOOG_MISC_INFO, DTLS/SCTP in unsupported media,
  use-after-free on GOOG_DELTA_ACK, VP8 temporal layer bounds, clearing channels before removing stopped transceivers,
  SCTP acknowledgments beyond sent data, remote simulcast layer limit, UniqueTimestampCounter overflow, FEC mask
  sequence wrap, NetEq crossfade clamp, desktop capture bounds during resolution changes, OpenH264 messages to the WebRTC log.
- Why: remote crash and memory-safety findings; keeps iOS equal to the Mac's tg_owt.
- Where: `pc/`, `net/dcsctp/tx/`, `modules/audio_coding/neteq/`, `modules/rtp_rtcp/source/`, `modules/video_coding/`,
  `video/`, `modules/desktop_capture/`; each fix carries a unit test where WebRTC has a test target for it.
- Upstream: yes (they are upstream tg_owt fixes).
- Sync: the allow-listed difference list in `docs/mac-core-paths.txt` of klaipher/nanogram names the 7 seam files
  that legitimately differ from tg_owt; `tools/dev/parity` checks the rest.

### tgcalls seam
- What: `RTCConfiguration::disable_payload_type_demuxing` and its plumbing (6513c71).
- Where: `api/peer_connection_interface.*`, `pc/peer_connection*`, `pc/sdp_offer_answer.cc`, `pc/webrtc_sdp.cc`.
- Upstream: no (needed by tgcalls). Sync: re-apply when moving to a newer WebRTC branch.
