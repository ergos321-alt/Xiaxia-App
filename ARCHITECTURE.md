# Architecture

## Authority boundary

```text
Xiaxia App
├── Presentation
├── Local UI state
├── Navigation
├── Local conversation cache
├── Android secure credential boundary
└── CoreClient
    └── Xiaxia Core (external authority)
        ├── Identity
        ├── Memory
        ├── Grounding
        ├── Model
        ├── Continuity
        ├── Proactivity
        └── Houses
```

No runtime file in `lib/` contains persona text, a system prompt, model parameters, provider URLs, memory retrieval, or proactive scheduling.

## Runtime composition

`main.dart` composes:

1. `SharedPreferences` for non-secret local state.
2. `PlatformSecureTokenStore` for the Core credential.
3. `ConversationStore` for one local V0.1 conversation.
4. `ChatController` for UI state and retry behavior.
5. `ProductionCoreClientFactory` for the external Core boundary.

The production adapter is verified against the supplied Xiaxia Core V0.1 routes and schemas. `main.dart` wires that adapter through `HttpCoreClient`; widgets and chat state remain unaware of endpoint and JSON details.

## Core client layering

- `CoreClient`: domain-facing send/reply contract.
- `CoreClientFactory`: construction seam based on local connection configuration.
- `HttpCoreClient`: HTTP, Bearer authentication, timeout, status mapping, malformed-response handling.
- `CoreContractAdapter`: the sole owner of endpoint path and JSON field mapping.
- `ProductionCoreContractAdapter`: `/v1/chat`, `/health`, and `/v1/status` mapping.
- `CoreDiagnosticsClient`: developer-only health/status verification.

HTTP does not appear in pages or widgets.

## Local data

The app persists only UI continuity:

- nullable Core-issued conversation ID;
- local rendered message list;
- Core base URL;
- encrypted Core credential.

This cache is not Xiaxia Memory and is never injected into a prompt. The first request sends only the current message. After Core returns a conversation ID, follow-up requests send the current message plus that Core-issued ID. Response request IDs and headers are retained only as developer diagnostics.

## Extension seams

- `HouseKind` and `HouseMaterial`: small material-layer variants over the shared design system.
- `ArtifactOwner`: `xiaxia`, `user`, or explicitly created `shared`.
- `RealityFact` and `XiaxiaInterpretation`: separate types to prevent fact/inference collapse.
- `ProactivePresentationKind`: `whisper`, `shadow`, `notification`, `knock`, `call`; presentation only, no decision engine.
- `PresenceState`: Core-ready presentation model; V0.1 uses deterministic fixtures only.

No generic plugin system, service locator, agent runtime, or speculative House framework was added.
