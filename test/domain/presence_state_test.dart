import 'package:flutter_test/flutter_test.dart';
import 'package:xiaxia_app/domain/presence/presence_state.dart';

void main() {
  test('absent is a valid quiet state', () {
    expect(PresenceState.absent.mode, PresenceMode.absent);
    expect(PresenceState.absent.isQuiet, isTrue);
    expect(PresenceState.absent.traceLine, isNull);
  });

  test('shadow is a presentation mode, not a pet state', () {
    const state = PresenceState(mode: PresenceMode.shadow);
    expect(state.mode, PresenceMode.shadow);
  });

  test('all four presentation modes remain representable', () {
    expect(
      PresenceMode.values,
      containsAll(<PresenceMode>[
        PresenceMode.trace,
        PresenceMode.shadow,
        PresenceMode.embodied,
        PresenceMode.absent,
      ]),
    );
  });
}
