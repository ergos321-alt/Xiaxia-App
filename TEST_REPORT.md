# Test Report

Date: 2026-09-02 (UTC)

## PASS

| Check | Result | Evidence |
| --- | --- | --- |
| Core contract source audit | PASS | `/v1/chat`, `/health`, `/v1/status`, schemas, response headers, 422, sanitized 502, and degraded-memory behavior checked against the supplied Core source/tests. |
| Production adapter wiring | PASS | `main.dart` injects `ProductionCoreClientFactory`; the pending-contract factory is absent. |
| Mobile brain-boundary scan | PASS | `tool/verify_boundaries.sh` rejects provider/prompt/model/scheduler backend markers and HTTP in feature UI/controller files. |
| Conversation authority static check | PASS | First Core conversation ID is nullable; legacy App placeholders are discarded; only Core replies populate the saved ID. |
| Protected UI/domain comparison | PASS | Recursive diff against the supplied V0.1 source is empty for Home, `ChatPage`, navigation shell, Design System, Presence, House, Ownership, Reality, and proactive-presentation files. |
| Fixture JSON syntax | PASS | Local request/response fixtures parse as JSON. |
| Android XML syntax | PASS | Android manifests and resources parse as XML. |

These PASS items are source/static validations only. They are not substitutes for Flutter analysis, Flutter tests, an APK build, runtime screenshots, or production Core verification.

## Added test coverage — NOT RUN

- exact `POST /v1/chat` path and request mapping;
- first request without `conversation_id`;
- follow-up with the Core-issued `conversation_id`;
- real loopback mock HTTP server transport;
- required response parsing and request-ID header/body agreement;
- Bearer authentication;
- 401/403, 422, sanitized 502 `model_unavailable`, other unavailable responses;
- timeout and malformed response;
- `X-Memory-Degraded: true` still returns the reply;
- unauthenticated `/health` and authenticated `/v1/status`;
- new/legacy/persisted Core conversation-ID storage;
- ChatController persistence, follow-up continuity, failure, and manual retry;
- retained Home, Chat, Presence, ownership, and navigation widget/domain tests.

The suite is `NOT RUN` because `flutter` and `dart` are unavailable in this environment.

## BLOCKED

| Required verification | Status | Actual result/blocker |
| --- | --- | --- |
| `flutter analyze` | BLOCKED | Exit 127: `flutter: command not found`. |
| `flutter test` | BLOCKED | Exit 127: `flutter: command not found`. |
| `flutter build apk --debug` | BLOCKED | Exit 127: `flutter: command not found`; Android SDK is also absent. |
| Android debug APK | BLOCKED | No Flutter/Android toolchain, so no APK is claimed or delivered. |
| Home Light runtime screenshot | BLOCKED | No Flutter runtime/emulator/device. |
| Home absent/quiet runtime screenshot | BLOCKED | No Flutter runtime/emulator/device. |
| Chat runtime screenshot | BLOCKED | No Flutter runtime/emulator/device. |
| Core unavailable runtime screenshot | BLOCKED | No Flutter runtime/emulator/device. |
| Dark Home runtime screenshot | BLOCKED | No Flutter runtime/emulator/device. |
| App → production Core reply | BLOCKED | No production Core base URL or `CORE_API_TOKEN` was supplied to this environment. |

## Commands attempted

```text
flutter analyze
flutter test
flutter build apk --debug
```

Each Flutter command exits before project evaluation because the executable is absent. Java is present; Flutter, Dart, Android SDK, ADB, emulator, and Docker are absent.

## Required authorized-environment run

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

After installing the debug APK, follow `README.md` to capture the five runtime screenshots and, when URL/token are available, the production integration receipt. Do not convert any of those rows to PASS until the corresponding command or runtime flow has actually completed.
