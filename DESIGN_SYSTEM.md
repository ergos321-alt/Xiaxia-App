# Xiaxia Design System V0.1

## Product constitution

- Presence before Interface: Home opens on a lived-in scene, not a composer.
- Trace before Avatar: books, cup, window, and room light carry presence before a person image.
- Life before Data: no model, token usage, retrieval, prompt, or memory metrics appear in normal UI.
- Silence is valid: `absent` renders a quiet room without offline copy or welcome pressure.
- Attention belongs to the user: V0.1 has no forced modal, navigation, vibration, or recurring mascot motion.
- Ownership without bureaucracy: ownership is a domain type and will be expressed through authorship/material nuance, not permission badges.

## Tokens

Light palette:

- background `#F6F3EE`
- raised warm white `#FCFAF6`
- text `#2C2D29`
- muted sage `#9DA68C`
- deep sage `#69745E`
- pale sage `#E3E6DB`
- apricot `#E3BE99`
- clay pink `#D8B1A5`

Dark palette:

- room charcoal `#20221F`
- raised charcoal `#2A2D29`
- green-grey `#82907A`
- warm text `#F1EEE7`

## Typography and spacing

The app uses the system's modern CJK sans fallback stack with restrained weights, 1.45–1.65 line height, and editorial hierarchy. House headings may later add a serif extension without changing the base body face.

Spacing follows `4 / 8 / 12 / 16 / 24 / 32 / 48`. Separation prefers whitespace and hairlines. Containers appear only where material distinction aids reading.

## Presence

`PresenceScene` is drawn from code so V0.1 ships no generated person image. Modes:

- `trace`: room, open book, cup, and vase; no Xiaxia body.
- `shadow`: adds a small cat silhouette as UI shadow, never an avatar or pet system.
- `embodied`: demonstrates only the future material slot.
- `absent`: retains light and space; no status diagnosis.

Fixtures are selected deterministically at build time. There is no random timer, affection score, idle performance, or proactive decision.

## Motion and accessibility

Motion is limited to short platform transitions and an interruptible chat scroll. The scene has no continuous animation. Semantic labels describe each Presence mode. System dark mode is supported. Future motion must respect reduced-motion preferences before it is introduced.

## House rule

Houses inherit navigation, typography, spacing, base colors, motion rhythm, and identity language. `HouseMaterial` supplies only a small surface/divider variation. V0.1 defines examples but does not open fake House pages.
