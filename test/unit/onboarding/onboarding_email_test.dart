import 'package:flutter_test/flutter_test.dart';
import 'package:memotion/features/onboarding/providers/onboarding_provider.dart';

void main() {
  group('onboarding email step', () {
    test('accepts a valid email and rejects invalid values', () {
      expect(isValidOnboardingEmail('patient@example.com'), isTrue);
      expect(isValidOnboardingEmail(' patient@example.com '), isTrue);
      expect(isValidOnboardingEmail('not-an-email'), isFalse);
      expect(isValidOnboardingEmail(''), isFalse);
      expect(isValidOnboardingEmail(null), isFalse);
    });

    test('only allows step 2 to proceed with a valid email', () {
      final notifier = OnboardingNotifier()..goToStep(2);

      expect(notifier.canProceed(), isFalse);
      expect(notifier.getValidationError(), 'Please enter an email address.');

      notifier.setEmail('invalid');
      expect(notifier.canProceed(), isFalse);
      expect(
        notifier.getValidationError(),
        'Please enter a valid email address.',
      );

      notifier.setEmail('patient@example.com');
      expect(notifier.canProceed(), isTrue);
      expect(notifier.getValidationError(), isNull);
    });
  });
}
