# Media Examples

This sample app includes five SwiftUI screens:

- `VOD Player`: plays `marolio.mp4` from Azure Blob Storage with `AVPlayer` and `VideoPlayer`.
- `Live Streaming`: shows a basic HLS live stream player and a reminder to replace the placeholder URL.
- `Audio Player`: demonstrates minimal audio playback controls using `AVPlayer` and `AVAudioSession`.
- `Picture in Picture`: uses `AVPlayerViewController` to enable Picture in Picture playback.
- `YouTube Embed`: embeds a YouTube iframe with `WKWebView`.

The `VOD Player` and `Picture in Picture` screens use `marolio.mp4` hosted in Azure Blob Storage.

Picture in Picture requires enabling `Background Modes > Audio, AirPlay, and Picture in Picture` for the app target in Xcode.
