import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/core/providers/developer_mode_provider.dart';

void main() {
  test('developer mode unlocks after eight Help taps', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(developerModeProvider.notifier);

    for (var tap = 1; tap < DeveloperModeState.tapsRequired; tap++) {
      final state = notifier.registerHelpTap();
      expect(state.helpTapCount, tap);
      expect(state.remainingTaps, DeveloperModeState.tapsRequired - tap);
      expect(state.isEnabled, isFalse);
    }

    final unlockedState = notifier.registerHelpTap();

    expect(unlockedState.helpTapCount, 0);
    expect(unlockedState.remainingTaps, DeveloperModeState.tapsRequired);
    expect(unlockedState.isEnabled, isTrue);
  });

  test('another eight Help taps turn developer mode off', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(developerModeProvider.notifier);
    for (var tap = 0; tap < DeveloperModeState.tapsRequired; tap++) {
      notifier.registerHelpTap();
    }

    for (var tap = 1; tap < DeveloperModeState.tapsRequired; tap++) {
      final state = notifier.registerHelpTap();
      expect(state.helpTapCount, tap);
      expect(state.remainingTaps, DeveloperModeState.tapsRequired - tap);
      expect(state.isEnabled, isTrue);
    }

    final disabledState = notifier.registerHelpTap();

    expect(disabledState.helpTapCount, 0);
    expect(disabledState.remainingTaps, DeveloperModeState.tapsRequired);
    expect(disabledState.isEnabled, isFalse);
  });
}
