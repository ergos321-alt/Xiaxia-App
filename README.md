# Xiaxia App V0.1 · Production Core Integration

Xiaxia App is the Flutter doorway to Xiaxia Core. The mobile app owns presentation, navigation, local UI state, a local message cache, and device boundaries. Xiaxia Core remains the sole authority for Identity, Memory, grounding, conversation history, model access, and future proactivity.

> Xiaxia App 不是操作林知夏的地方，而是遇见林知夏的地方。

## Production connection

The verified Xiaxia Core V0.1 contract is now wired into production composition:

```text
ChatPage
  → ChatController
  → CoreClient
  → HttpCoreClient
  → ProductionCoreContractAdapter
  → POST /v1/chat
```

- `Authorization: Bearer <stored credential>` is added by `HttpCoreClient`.
- The first message sends only `message`.
- The App persists the `conversation_id` returned by Core and reuses it on follow-up messages.
- Local rendered messages are never reconstructed into a Core request.
- `X-Memory-Degraded: true` does not fail an otherwise successful reply.
- Provider/model/memory diagnostics never appear in normal Home or Chat UI.

The Core URL is stored in local preferences. The Bearer credential is encrypted with an Android Keystore AES-GCM key and is never hardcoded.

## V0.1 surface retained

- Presence-first Home with deterministic `trace`, `shadow`, `embodied`, and `absent` fixtures.
- Quiet Home/Chat mobile navigation.
- Local message continuity, timestamps, sending/error/manual-retry states.
- Light and dark Xiaxia themes.
- Minimal extension seams for Houses, ownership, Reality semantics, and proactive presentation.

Diary, Reading, Moments, Reality, Hand, Watch, Browser, Voice, Call, and autonomous proactivity remain outside this pass.

## Developer connection verification

In a debug build, open the Core connection sheet and use `Developer · 验证 Core`:

1. `GET /health` is called without authentication.
2. When a credential is entered, `GET /v1/status` is also called with the same Bearer token.
3. The UI reports only whether verification succeeded; it does not display model, memory, database, Identity, retrieval, or token details.

## Build

Requirements:

- Flutter SDK compatible with Dart `^3.10.3`
- Android SDK and Java 17
- Android 6.0 / API 23 or newer

Create `android/local.properties` for the workstation:

```properties
sdk.dir=/absolute/path/to/Android/sdk
flutter.sdk=/absolute/path/to/flutter
```

Then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

This execution environment contains Java but no Flutter, Dart, Android SDK, ADB, emulator, or device. Therefore those commands and runtime screenshots are not represented as passing. See [TEST_REPORT.md](TEST_REPORT.md).

## Manual production acceptance when URL/token are available

1. Install the debug APK and save the production Core base URL and credential in the connection sheet.
2. Run the developer Core verification.
3. Start log capture with `flutter logs` or `adb logcat` and filter for `Core integration receipt:`.
4. Send one nonblank message from Chat and confirm a Xiaxia reply appears.
5. Send a second message in the same App conversation.
6. Record the receipt fields: HTTP status, nonempty `conversation_id`, nonempty `request_id`, and `reply_non_empty=true`.
7. Confirm the second request continues the same Core conversation.

The receipt never logs the credential, user message, Xiaxia reply, model name, retrieval count, or memory contents.

## Presence fixture capture

```bash
flutter run --dart-define=XIAXIA_PRESENCE_STATE=absent
flutter run --dart-define=XIAXIA_PRESENCE_STATE=shadow
flutter run --dart-define=XIAXIA_PRESENCE_STATE=embodied
```

## Source lineage

This project is forked from `sh1nny0u/ZeroChat` under the MIT License. The original `LICENSE` is preserved. The supplied aesthetic reference remains at `design/reference/xiaxia-app-concept-visual.png`; it is not runtime screenshot evidence and is not bundled as an App asset.
