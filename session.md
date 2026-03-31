# Memotion Design System & Theme Details

This document outlines the visual identity and design tokens for the Memotion project, based on the Flutter implementation.

## 🎨 Color Palette

| Category | Name | Hex Code | Preview | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Primary** | Primary | `#00695C` | ![#00695C](https://via.placeholder.com/15/00695C?text=+) | Main brand color, buttons |
| | Primary Light | `#439889` | ![#439889](https://via.placeholder.com/15/439889?text=+) | Hover states, accents |
| | Primary Dark | `#003D33` | ![#003D33](https://via.placeholder.com/15/003D33?text=+) | Deep accents |
| **Secondary** | Secondary (Teal) | `#4DB6AC` | ![#4DB6AC](https://via.placeholder.com/15/4DB6AC?text=+) | Secondary accents, icons |
| | Teal Accent | `#00BFA5` | ![#00BFA5](https://via.placeholder.com/15/00BFA5?text=+) | Bright teal highlights |
| **Figma Tokens** | Purple Accent | `#5F33E1` | ![#5F33E1](https://via.placeholder.com/15/5F33E1?text=+) | Design system primary accent |
| | SOS/CTA | `#D77658` | ![#D77658](https://via.placeholder.com/15/D77658?text=+) | Critical actions, SOS button |
| | Light Green Accent| `#A0FFD5` | ![#A0FFD5](https://via.placeholder.com/15/A0FFD5?text=+) | Soft green highlights |
| **Background** | Main Background | `#F1F8E9` | ![#F1F8E9](https://via.placeholder.com/15/F1F8E9?text=+) | App scaffold background |
| | Surface | `#FFFFFF` | ![#FFFFFF](https://via.placeholder.com/15/FFFFFF?text=+) | Cards, dialogs |
| | Surface Variant | `#FAFAF5` | ![#FAFAF5](https://via.placeholder.com/15/FAFAF5?text=+) | Alternative backgrounds |
| **Typography** | Text Primary | `#221F1F` | ![#221F1F](https://via.placeholder.com/15/221F1F?text=+) | Main headings and body |
| | Text Secondary | `#221F1F` (60%) | ![#221F1F99](https://via.placeholder.com/15/221F1F99?text=+) | Captions, hints |
| **Status** | Success | `#4CAF50` | ![#4CAF50](https://via.placeholder.com/15/4CAF50?text=+) | Success states |
| | Error | `#E53935` | ![#E53935](https://via.placeholder.com/15/E53935?text=+) | Error/Critical states |
| | Warning | `#FF9800` | ![#FF9800](https://via.placeholder.com/15/FF9800?text=+) | Alerts |

---

## ✍️ Typography

**Font Family:** [Lexend](https://fonts.google.com/specimen/Lexend) (via Google Fonts)

### Headings
- **Headline 1:** 22pt | Bold (700) | Line Height: 1.35
- **Headline 2:** 19pt | SemiBold (600)
- **Headline 3:** 16pt | SemiBold (600)
- **Section Heading:** 20pt | Bold (700)
- **Card Title:** 18pt | Bold (700)

### Body & UI
- **Body Large:** 16pt | Regular (400) | Letter Spacing: 0.5
- **Body Medium:** 14pt | Regular (400)
- **Body Small:** 12pt | Regular (400)
- **Caption:** 11pt | Regular (400)
- **Light Description:** 12pt | Light (300)

### Stats & Numbers
- **Numeric Stat:** 17pt | Bold (700)
- **Large Stat:** 24pt | Bold (700)

---

## 🧱 Component Tokens

### 🔘 Buttons
- **Elevated Button:**
  - Background: `#00695C`
  - Text: `#FAFAF5`
  - BorderRadius: `32px` (Pill shape)
  - Elevation: `0`
  - Padding: `24px (H) x 16px (V)`
- **Outlined Button:**
  - Border: `#00695C` (1px)
  - Text: `#00695C`
  - BorderRadius: `32px`

### ⌨️ Input Fields
- **Background:** `#FFFFFF` (Filled)
- **BorderRadius:** `6px`
- **Default Border:** `#E0E0E0` (1px)
- **Focused Border:** `#00695C` (2px)
- **Hint Text:** `#9E9E9E`, 14pt, Regular

### 🏛️ AppBar
- **Background:** `#F1F8E9`
- **Elevation:** `0`
- **Title Style:** 19pt, SemiBold, Center Aligned
- **Icon Color:** `#221F1F`

---

## 🌑 Shadows
- **Shadow Default:** `rgba(0, 0, 0, 0.1)`
- **Card Shadow:** `rgba(0, 0, 0, 0.25)`
