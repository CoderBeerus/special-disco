# AniWeb

AniWeb is an Android-first Flutter media browser focused on smooth rendering, resilient playback, and authorized offline media workflows.

## Architecture summary

- Clean modular `lib/` split across `core`, `features`, `data`, `services`, `platform`, and shared `widgets`.
- Riverpod state-notifier architecture for compile-safe isolated state updates.
- GoRouter with a retained shell and indexed-stack section navigation.
- Web stack built on `flutter_inappwebview` with dedicated services for content blocking, media detection, and browser state.
- Media stack built on `media_kit` (hardware-accelerated Android playback path).
- Download pipeline via `background_downloader`, with persisted metadata in SQLite.
- Strict URL/file sanitization and graceful failures for unsupported/protected media.

## Major dependency choices

- `flutter_riverpod`: granular immutable state with low rebuild pressure.
- `go_router`: structured declarative app routing.
- `flutter_inappwebview`: feature-rich, maintained embedded browser + content blocker support.
- `media_kit` + `media_kit_video`: custom player UX backed by performant playback internals.
- `background_downloader`: persistent background-friendly download engine.
- `sqflite`: durable local metadata and resumable state tracking.

## File tree (high-level)

```text
lib/
  core/
  data/
  features/
  platform/
  services/
  state/
  widgets/
test/
```

## Android configuration notes

- A platform channel is wired in `MainActivity.kt` for refresh-rate and immersive-mode integration points.
- The app is designed to request high refresh modes conservatively when supported.
- Background download behavior depends on Android runtime permissions and OEM power management settings.

## Build instructions

1. Install Flutter stable and Android SDK.
2. Run `flutter pub get`.
3. Run `flutter run -d android`.

## Test instructions

- Run unit and widget tests:
  - `flutter test`
- Run static analysis:
  - `flutter analyze`

## Known limitations

- DRM/protected streams are intentionally not bypassed; unsupported sources fail gracefully.
- Advanced HLS/DASH remux and variant introspection are scaffolded at service level and require endpoint-specific legal compatibility.
- Some OEM devices may enforce aggressive background restrictions despite foreground-service-compatible workflows.

## Performance considerations

- Indexed-stack navigation preserves expensive feature state (notably WebView).
- Stateless/const-first widget composition and fine-grained providers minimize rebuilds.
- Heavy operations are designed for async execution and isolated from the UI thread.

## Future improvements

- Add Media3-specific Kotlin player bridge for advanced track/ABR controls.
- Add WorkManager-backed retry policies for network-type constraints.
- Expand integration tests for browser-to-player/download flows on physical high-refresh devices.
