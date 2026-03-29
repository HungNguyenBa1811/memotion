# Memotion Responsive UI Guideline

> **For AI agents and developers.** This document describes the exact patterns in use.
> Follow these rules strictly — do not invent new patterns.

---

## 1. Breakpoints & Core Utility

All breakpoint logic lives in `lib/core/utils/responsive_utils.dart`.

| Range | Label | `isPhone` | `isTablet` | `isLargeTablet` |
|---|---|---|---|---|
| width < 600 dp | Phone | ✓ | — | — |
| 600 ≤ width < 900 dp | Tablet | — | ✓ | — |
| width ≥ 900 dp | Large Tablet | — | — | ✓ |

Key helpers to use:

```dart
ResponsiveUtils.isTabletOrLarger(context)   // bool — tablet or larger
ResponsiveUtils.horizontalPadding(context)  // 16 / 32 / 48 dp
ResponsiveUtils.verticalPadding(context)    // 16 / 24 / 32 dp
ResponsiveUtils.contentMaxWidth(context)    // ∞ / 680 / 900 dp
ResponsiveUtils.cardColumns(context)        // 2 / 3 / 4
ResponsiveUtils.textScaleFactor(context)    // 1.0 / 1.15 / 1.25
ResponsiveUtils.bottomNavPadding(context)   // 120 on phone, 24 on tablet+
```

---

## 2. The Golden Rule: Screens Own Padding, Widgets Are Padding-Agnostic

**Widgets must NOT add their own horizontal padding or margin.**
The screen that uses the widget wraps it in `Padding` or puts it inside a padded column.

### ✅ Correct pattern
```dart
// In the screen:
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: ResponsiveUtils.horizontalPadding(context),
  ),
  child: MyWidget(),   // MyWidget has no internal horizontal padding
)
```

### ❌ Wrong pattern (double-padding bug)
```dart
// MyWidget internally does:
Padding(padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.horizontalPadding(context)), ...)

// Screen also wraps it:
Padding(padding: EdgeInsets.all(ResponsiveUtils.horizontalPadding(context)), child: MyWidget())
// Result: 2× padding on each side — content is crushed
```

**Widgets that follow this rule:**
- `GreetingHero` — no outer Padding; screen wraps it
- `PatientGreetingHero` — same
- `UpcomingMedicationCard` — no self-margin; screen wraps it

---

## 3. Standard Screen Layout Pattern

Every dashboard / list screen uses this structure. No exceptions.

```dart
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      child: Center(                                       // centers on wide screens
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.contentMaxWidth(context), // caps width at 680/900 dp
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.horizontalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // All content goes here — no child adds its own horizontal padding
                ...
                SizedBox(height: ResponsiveUtils.bottomNavPadding(context)), // always last
              ],
            ),
          ),
        ),
      ),
    ),
  ),
)
```

**Why `ConstrainedBox` + `Center`:**
- On phone: `contentMaxWidth = ∞` → no constraint, fills screen
- On tablet: `contentMaxWidth = 680` → content stops at 680 dp and centers
- On large tablet: `contentMaxWidth = 900` → content stops at 900 dp and centers

---

## 4. When NOT to Use a Two-Column (Row) Layout

### ❌ Do NOT use `isTablet ? Row(...) : Column(...)` on dashboard/home screens

The split-pane (Master-Detail Row) pattern only makes sense when:
- One pane is a **list** that drives a **detail panel** in the other pane (e.g., medication list + detail)
- Both panes have roughly equal, substantial content

**Do NOT split if:**
- One pane would end up with just a title + 4 small cards (home screen)
- One pane would have only a single button (patient home screen)
- The content is a profile/settings flow (profile screen)
- It is a health report / summary dashboard (health report screen)

All of the above use the single-column `Center > ConstrainedBox` pattern from §3.

---

## 5. Hero Section Pattern (`GreetingHero` / `PatientGreetingHero`)

The hero widget uses a `LayoutBuilder`-driven `Stack` to place the green mood card on the left and the grandparent illustration on the right. The illustration layer is **on top** of the card layer.

```
┌──────────────────────────────────────────────────┐  ← SizedBox (full width × imageHeight)
│  ┌────────────────────┐                          │
│  │  Green mood card   │   ┌──────────────────┐   │  ← Layer 2: image (painted on top)
│  │  (Layer 1, behind) │   │  Grandparent img  │   │
│  └────────────────────┘   └──────────────────┘   │
└──────────────────────────────────────────────────┘
```

### Implementation
```dart
LayoutBuilder(
  builder: (_, constraints) {
    final useWide = constraints.maxWidth >= 480; // NOT isTabletOrLarger!
    final cardWidth  = useWide ? 300.0 : 240.0;
    final cardHeight = useWide ? 180.0 : 160.0;
    final imageHeight = cardHeight + (useWide ? 40.0 : 20.0); // peeks above card

    return SizedBox(
      width: double.infinity,
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,   // both Align children get full canvas
        children: [
          // Layer 1 — card, bottom-left, behind
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(width: cardWidth, height: cardHeight, ...),
          ),
          // Layer 2 — illustration, bottom-right, ON TOP
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              'assets/images/caregiver_elderly.png',
              height: imageHeight,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  },
)
```

**Key rules:**
- Use `constraints.maxWidth >= 480` (actual available width), NOT `isTabletOrLarger`. On tablet the left pane is ~365 dp (phone-sized), so phone values must apply inside it.
- `StackFit.expand` is required so `Align` can position children correctly.
- The illustration is always the **last** child in Stack so it paints on top.
- No `clipBehavior: Clip.none` or negative `Positioned` offsets needed.

---

## 6. Action Card Grid

```dart
GridView.count(
  crossAxisCount: ResponsiveUtils.cardColumns(context), // 2 / 3 / 4 — never hardcode!
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 162 / 171,
  children: [...],
)
```

Never use `crossAxisCount: isTablet ? 2 : 2` or any hardcoded value.

---

## 7. Typography Scale

All font sizes must be multiplied by `textScaleFactor`:

```dart
final textScale = ResponsiveUtils.textScaleFactor(context); // 1.0 / 1.15 / 1.25
Text('...', style: style.copyWith(fontSize: 16 * textScale))
```

**Base sizes (phone):**

| Element | Phone | Tablet | Large Tablet |
|---|---|---|---|
| Hero greeting | 18 sp | 20.7 sp | 22.5 sp |
| Section heading | 22 sp | 25.3 sp | 27.5 sp |
| Card title | 18 sp | 20.7 sp | 22.5 sp |
| Body | 14–16 sp | 16–18.4 sp | 17.5–20 sp |
| Caption | 12–13 sp | 13.8–15 sp | 15–16.25 sp |

---

## 8. Icon Sizes

| Context | Phone | Tablet | Large Tablet |
|---|---|---|---|
| Nav / action icon | 24 dp | 32 dp | 36 dp |
| Card icon | 80 dp | 90 dp | 100 dp |
| Avatar | 59 dp | 80 dp | 90–130 dp |
| Notification button | 48 dp (min touch) | 56 dp | 56 dp |

Always maintain **48 dp minimum touch target** regardless of visual size.

---

## 9. Spacing Reference

| Token | Phone | Tablet | Large Tablet |
|---|---|---|---|
| `horizontalPadding` | 16 dp | 32 dp | 48 dp |
| `verticalPadding` | 16 dp | 24 dp | 32 dp |
| `sectionGap` | 12 dp | 16 dp | 20 dp |
| `bottomNavPadding` | 120 dp | 24 dp | 24 dp |
| Between sections | 24 dp | 24 dp | 24 dp |

---

## 10. Anti-Patterns to Avoid

| Anti-pattern | Why bad | Fix |
|---|---|---|
| Widget adds its own `horizontal: hPad` padding | Double-padding when screen also wraps it | Remove from widget; screen owns it |
| `isTablet ? Row([left, right]) : Column(...)` on dashboards | Sparse panes look bad; wrong pattern for home/profile | Use single column + `ConstrainedBox(maxWidth)` |
| `crossAxisCount: isTablet ? 2 : 2` | Doesn't scale | Use `ResponsiveUtils.cardColumns(context)` |
| Fixed-width mood card with `isTablet ? 300 : 240` ignoring pane width | Overflows into adjacent panes | Use `LayoutBuilder` with `constraints.maxWidth >= 480` |
| `Positioned(right: -130)` for illustration layout | Absolute offset breaks in two-pane layouts | Use `Stack(fit: StackFit.expand)` + `Align` |
| `SizedBox(height: 120)` at bottom for nav | Breaks on tablet (nav is a rail, not bottom bar) | Use `ResponsiveUtils.bottomNavPadding(context)` |

---

## 11. Files Quick Reference

| File | Purpose |
|---|---|
| `lib/core/utils/responsive_utils.dart` | All breakpoint helpers and size tokens |
| `lib/core/widgets/responsive_layout.dart` | `ResponsiveLayout`, `ResponsiveContentBox`, `ResponsiveTwoPanel` |
| `lib/features/home/widgets/greeting_hero.dart` | Caretaker hero (Stack + Align mood section) |
| `lib/features/home/widgets/patient_greeting_hero.dart` | Patient hero (same pattern) |
| `lib/features/home/widgets/upcoming_medication_card.dart` | No self-margin; screen wraps it |
| `lib/features/home/widgets/action_card.dart` | Uses `ResponsiveUtils` for icon sizes |
| `lib/features/home/screens/caretaker/caretaker_home_screen.dart` | Single-column + ConstrainedBox |
| `lib/features/home/screens/patient/patient_home_screen.dart` | Single-column + ConstrainedBox |
| `lib/features/profile/screens/profile_screen.dart` | Single-column + ConstrainedBox |
| `lib/features/profile/screens/caretaker_health_report_screen.dart` | Single-column + ConstrainedBox |
