enum PresenceMode { trace, shadow, embodied, absent }

class PresenceState {
  const PresenceState({
    required this.mode,
    this.traceLine,
    this.materialReference,
  });

  final PresenceMode mode;
  final String? traceLine;

  /// Opaque Core-owned reference for a future embodied presence asset.
  final String? materialReference;

  bool get isQuiet => mode == PresenceMode.absent;

  static const absent = PresenceState(mode: PresenceMode.absent);
}

/// Deterministic V0.1 data. This is a presentation fixture, never an AI decision.
class PresenceDemoFixture {
  const PresenceDemoFixture._();

  static PresenceState fromEnvironment() {
    const value = String.fromEnvironment(
      'XIAXIA_PRESENCE_STATE',
      defaultValue: 'trace',
    );
    return switch (value) {
      'shadow' => const PresenceState(
          mode: PresenceMode.shadow,
          traceLine: '窗边那本书还摊在昨晚那一页。',
        ),
      'embodied' => const PresenceState(mode: PresenceMode.embodied),
      'absent' => PresenceState.absent,
      _ => const PresenceState(
          mode: PresenceMode.trace,
          traceLine: '窗边那本书还摊在昨晚那一页。',
        ),
    };
  }
}
