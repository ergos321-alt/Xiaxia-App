# Xiaxia Core Production Integration

## Verified contract source

The mapping was checked against the supplied Xiaxia Core V0.1 implementation:

- `app/api/routes.py`
- `app/api/schemas.py`
- `tests/test_chat.py`
- `tests/test_health_status.py`

No Xiaxia Core file was modified.

## Chat contract

`ProductionCoreContractAdapter` is the only mobile class that owns Core paths and JSON field mapping.

```http
POST /v1/chat
Authorization: Bearer <CORE_API_TOKEN>
Content-Type: application/json
```

First request:

```json
{"message":"..."}
```

Follow-up request:

```json
{"message":"...","conversation_id":"<Core-issued ID>"}
```

Required response fields:

```json
{
  "reply":"...",
  "conversation_id":"...",
  "request_id":"..."
}
```

All three response values must be nonblank. When `X-Request-ID` is present, it must agree with the body `request_id`; disagreement is treated as malformed.

## Conversation authority

`ConversationStore` persists a nullable Core-issued conversation ID separately from the local rendered-message list. A new installation has no Core ID, so the first request omits `conversation_id`. Legacy `app-...` placeholder IDs from the Foundation build are discarded during load.

After the first successful response, `ChatController` saves Core's `conversation_id`. Subsequent messages send that ID and the new message only. The App does not send cached history and does not generate a replacement production conversation ID.

## Response metadata

`HttpCoreClient` captures the following into `CoreReplyDiagnostics`:

- HTTP status
- `X-Request-ID`
- `X-Model`
- `X-Memory-Retrieved-Count`
- `X-Memory-Degraded`

Chat presentation reads none of these fields. A true memory-degraded header does not suppress or replace a valid reply. The debug integration receipt logs only status, conversation/request identifiers, and whether the reply is nonempty.

## Errors

| Core/network result | App failure kind | User-facing behavior |
| --- | --- | --- |
| 401/403 | `authentication` | Credential error; manual connection action; no automatic retry loop. |
| 422 | `invalidRequest` | Restrained invalid-message error; validation body remains private. |
| 502 + `detail.code=model_unavailable` | `modelUnavailable` | Temporary reply-unavailable message; upstream detail remains private. |
| Other non-2xx | `unavailable` | Generic Core unavailable state. |
| Timeout | `timeout` | Manual retry offered. |
| Invalid JSON, blank/missing required fields, or request-ID mismatch | `malformedResponse` | Generic incompatible-response state. |
| HTTP client failure | `unavailable` | Generic Core unavailable state. |

The App contains no provider endpoint, Persona, Memory retrieval, prompt construction, model parameters, or Agent scheduler.

## Health and runtime status

- `GET /health`: no authentication; parsed as status/service/version.
- `GET /v1/status`: same Bearer credential; parsed only inside the developer diagnostics boundary.

The debug connection sheet displays only verification success/failure. Normal Home and Chat never display Qwen/model, Memory configuration, database, Identity file count, token, or retrieval count.

## Production acceptance status

No production Core base URL or credential was included in the supplied materials. A real App → production Core message was therefore not run and is not marked PASS. The debug APK/manual verification procedure is documented in `README.md` for the authorized environment holding those values.
