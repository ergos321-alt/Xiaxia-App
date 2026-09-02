# ZeroChat Source Audit

Audit basis: the uploaded `ZeroChat-main.zip`, repository tree dated 2026-03-24. The README, license, Flutter entrypoint, all files under `lib/core`, `lib/models`, `lib/pages`, `lib/services`, `lib/widgets`, Android project files, and the complete `server` tree were inspected before implementation.

## Decision record

| Upstream area | Decision | V0.1 treatment |
| --- | --- | --- |
| `LICENSE` | KEEP | MIT license preserved unchanged. |
| Flutter/Gradle application skeleton | KEEP / MODIFY | Wrapper and base Android structure retained; namespace, package, label, theme, icon, and permissions changed to Xiaxia. |
| `analysis_options.yaml` | KEEP | Flutter lint baseline retained. |
| `pubspec.yaml` | MODIFY | Product renamed; dependencies reduced to Flutter, HTTP, and local preferences. AI/background/media packages removed from the dependency surface. |
| `lib/main.dart` | REMOVE / REPLACE | ZeroChat service boot graph and schedulers removed. New minimal Xiaxia composition root added. |
| `lib/core/message_store.dart` | MODIFY | Its local persistence idea was retained, but role/group semantics were replaced by `ConversationStore`. |
| `lib/models/message.dart` | MODIFY | Replaced with a smaller immutable `ChatMessage` using `user/xiaxia` authors and delivery state. |
| `lib/core/chat_controller.dart` | REMOVE / REPLACE | Prompt building, memory injection, role behavior, provider calls, segmentation, stickers, and simulated behavior removed. New controller talks only through `CoreClient`. |
| `lib/widgets/chat_bubble.dart`, `input_bar.dart` | MODIFY | Rendering responsibilities rebuilt as restrained message lines and keyboard-safe composer. WeChat visual rules were not retained. |
| `lib/widgets/tab_bar.dart` | REMOVE / REPLACE | Four-tab WeChat shell replaced by two-destination Home/Chat navigation. |
| `lib/pages/chat_page.dart`, `chat_detail_page.dart` | MODIFY | Fake initial messages and fake AI reply removed; replaced by Core-bound Chat. |
| `lib/pages/chat_list_page.dart` | DEFER | Multi-conversation list is outside V0.1. |
| Contacts, groups, role pages | REMOVE | They encode multi-role/persona product structure and do not belong to Xiaxia V0.1. |
| API/model/global prompt/settings pages | REMOVE | Direct provider configuration, prompts, model parameters, and role controls are forbidden. A narrow Core connection sheet replaces them. |
| Moments pages | DEFER | Presentation ideas may be revisited, but AI generation and fake completeness are excluded. |
| Favorites pages/services | DEFER | Potentially reusable later; not needed to build the first door. |
| Image/sticker/media services | DEFER | Media infrastructure may be reconsidered against a real House need. It is not shipped in V0.1. |
| `memory_manager.dart`, `memory_service.dart` | REMOVE | Second memory authority. |
| `proactive_message_scheduler.dart` | REMOVE | App-side proactive decision engine. |
| `moments_scheduler.dart`, `group_scheduler.dart`, `task_service.dart` | REMOVE | App-side scheduler/agent behavior. |
| `api_service.dart`, `intent_service.dart` | REMOVE | Direct model-provider requests, model settings, intent-model calls, prompt construction, and ZeroChat backend coupling. |
| Remaining role/group/moment/settings services | REMOVE or DEFER | Not part of the V0.1 compiled source. |
| `server/` | BYPASS / REMOVE FROM DELIVERY | FastAPI AI, memory, role, behavior, and scheduler backend is a second brain. The directory is not present in Xiaxia App. |
| Android notification/background/camera/storage permissions | REMOVE | V0.1 requests only Internet. Future device capabilities must return through explicit boundaries. |
| Android app identity | MODIFY | `com.zerochat.zerochat` changed to `com.xiaxia.app`; ZeroChat labels and runtime strings removed. |
| Upstream screenshots and robot launcher identity | REMOVE | They are not Xiaxia product assets. A restrained leaf launcher vector is used. |

## Brain-removal verification

`tool/verify_boundaries.sh` rejects provider endpoints, chat-completions paths, prompt/model parameter tokens, any shipped `server/` directory, and runtime `ZeroChat` product markers. This is a regression guard, not a substitute for Flutter analysis or tests.

## What was intentionally not reused

ZeroChat's UI and AI behavior are tightly interwoven around roles, WeChat contacts, generated Moments, schedulers, and provider settings. Retaining those files behind disabled routes would leave a second-brain regression surface. The V0.1 fork therefore keeps the application foundation and useful persistence concepts while compiling a deliberately smaller Xiaxia-owned `lib/` tree.
