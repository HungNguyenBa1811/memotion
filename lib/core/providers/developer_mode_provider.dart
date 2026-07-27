import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperModeState {
  static const int tapsRequired = 8;

  const DeveloperModeState({this.helpTapCount = 0, this.isEnabled = false});

  final int helpTapCount;
  final bool isEnabled;

  int get remainingTaps => tapsRequired - helpTapCount;
}

class DeveloperModeNotifier extends StateNotifier<DeveloperModeState> {
  DeveloperModeNotifier() : super(const DeveloperModeState());

  DeveloperModeState registerHelpTap() {
    final nextTapCount = state.helpTapCount + 1;
    if (nextTapCount >= DeveloperModeState.tapsRequired) {
      state = DeveloperModeState(isEnabled: !state.isEnabled);
    } else {
      state = DeveloperModeState(
        helpTapCount: nextTapCount,
        isEnabled: state.isEnabled,
      );
    }
    return state;
  }
}

final developerModeProvider =
    StateNotifierProvider<DeveloperModeNotifier, DeveloperModeState>(
      (ref) => DeveloperModeNotifier(),
    );
