# Onboarding Screens Rename Plan

> Status: **PLANNED — not implemented**
> Scope: `lib/features/onboarding/screens/` naming cleanup
> Date: 2026-07-24

## Background — why the names are confusing

| File | Class | What it *actually* is | Problem |
|---|---|---|---|
| `onboarding_screen.dart` | `OnboardingScreen` | **Welcome/landing page** at route `/` — logo + "Register"/"Login" buttons, shown *before* auth | Not onboarding at all. It's the app's entry landing screen |
| `onboarding_screen_new.dart` | `OnboardingScreenNew` | The **real onboarding wizard** — PageView driving all 17 steps at `/onboarding/1` | `_new` is a leftover migration suffix (the "old" screen it replaced is already deleted — see the "Legacy - deprecated" comment in `onboarding.dart:22`) |
| `onboarding_screen_16.dart` | `OnboardingScreen16` | Standalone "Review & Submit" screen | **Dead code.** Zero inbound imports (lib + test). Superseded by `widgets/step_builders/step16_builder.dart`, which renders the same review step inside the wizard |
| `onboarding_loading_screen.dart` | `OnboardingLoadingScreen` | Loading screen during the 3 submission API calls | ✅ Name is accurate — keep as-is |

## 1:1 rename mapping

| # | Old file | New file | Old class | New class |
|---|---|---|---|---|
| 1 | `screens/onboarding_screen.dart` | `screens/welcome_screen.dart` | `OnboardingScreen` | `WelcomeScreen` |
| 2 | `screens/onboarding_screen_new.dart` | `screens/onboarding_wizard_screen.dart` | `OnboardingScreenNew` (+ `_OnboardingScreenNewState`) | `OnboardingWizardScreen` (+ `_OnboardingWizardScreenState`) |
| 3 | `screens/onboarding_screen_16.dart` | **DELETE** (dead code) | `OnboardingScreen16` | — |
| 4 | `screens/onboarding_loading_screen.dart` | *(unchanged)* | `OnboardingLoadingScreen` | *(unchanged)* |

Deliberately **not** reusing the freed name `onboarding_screen.dart` for the wizard — that would make git history/diffs ambiguous. `onboarding_wizard_screen.dart` also matches the file's own doc comment ("Onboarding wizard with split layout").

## Import/reference fixes (exhaustive — only 2 files import these screens)

### `lib/core/router/app_router.dart`

| Line | Change |
|---|---|
| 7 | `import '../../features/onboarding/screens/onboarding_screen.dart'` → `welcome_screen.dart` |
| 8 | `import '../../features/onboarding/screens/onboarding_screen_new.dart'` → `onboarding_wizard_screen.dart` |
| 122 | `OnboardingScreen(...)` → `WelcomeScreen(...)` |
| 146 | `const OnboardingScreenNew(initialStep: 1)` → `const OnboardingWizardScreen(initialStep: 1)` |

### `lib/features/onboarding/onboarding.dart` (barrel)

| Line | Change |
|---|---|
| 20 | `export 'screens/onboarding_screen_new.dart';` → `export 'screens/onboarding_wizard_screen.dart';` |
| 22 | (optional) drop the stale comment about the deprecated legacy export |

Notes:
- No references in `test/`.
- `onboarding_screen_16.dart` has zero inbound imports → deletion is safe.
- `onboarding_loading_screen.dart` import (router line 9) is untouched.

## Optional follow-up (recommended — same confusion family)

`AppRoutes.onboarding = '/'` (`app_router.dart:38`) points at the *welcome* screen, while actual onboarding lives at `AppRoutes.onboardingStep1 = '/onboarding/1'`. Rename the constant `onboarding` → `welcome` (~5 call sites, all inside `app_router.dart`: lines 121, 124, 130, 138 — sign-in/registration back-navigation callbacks). Purely mechanical.

## Execution order

1. `git mv` files #1 and #2 (preserves history) + rename classes inside
2. Delete `onboarding_screen_16.dart`
3. Fix the 2 importing files (`app_router.dart`, `onboarding.dart`)
4. (Optional) route-constant rename `AppRoutes.onboarding` → `AppRoutes.welcome`
5. Verify:
   - `flutter analyze` — clean
   - `grep -r "OnboardingScreenNew\|OnboardingScreen16\|onboarding_screen_new\|onboarding_screen_16" lib/ test/` — no matches
