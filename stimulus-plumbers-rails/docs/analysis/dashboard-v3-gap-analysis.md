# Dashboard v3 — Gap Analysis

> `ActionList` was renamed to `List` (`sp_list`) after this doc was written.
> All `ActionList`/`sp_action_list` references below should be read as `List`/`sp_list`.

**Design source:** `trip-planner/project/dashboard-v3.html` (fundravel travel planning app)  
**Packages evaluated:** `@stimulus-plumbers/controllers` (npm) · `stimulus-plumbers` (Rails gem) · `stimulus-plumbers-tailwind` (Rails gem)  
**Date:** 2026-05-22

---

## Summary

The dashboard-v3 design specifies five screens: **Upcoming**, **Empty State**, **Discover**, **New Trip sheet**, and **Success**. Mapping each UI element against the existing component catalogue reveals **11 missing components**, **4 components with partial gaps**, and **3 areas where the theme layer has no coverage**. The gaps cluster around navigation primitives (bottom nav, tab bar, FAB), card enhancements (cover images with overlays, progress bars, chips), and modal sheet patterns.

---

## Screen Inventory vs Package Coverage

### 1. Upcoming Screen

| UI Element                       | Design Class(es)                                   | Package Coverage                 | Gap                                                                          |
| -------------------------------- | -------------------------------------------------- | -------------------------------- | ---------------------------------------------------------------------------- |
| Status bar (time + icons)        | `.sb`                                              | — (decorative, server-rendered)  | None — app concern                                                           |
| Top nav with avatar + brand      | `.nav`, `.av`, `.brand`                            | `sp_avatar` ✓                    | **Partial** — no nav shell component                                         |
| Icon-only buttons (search, bell) | `.ibtn`                                            | `sp_button` (icon variant) ✓     | **Partial** — no notification badge/dot overlay                              |
| Notification dot on bell         | `.ndot`                                            | —                                | **Missing** — `sp_badge` or badge slot on `sp_button`                        |
| Hero eyebrow + heading           | `.hero-ey`, `.hero-h`                              | —                                | None — typography, app concern                                               |
| Active trip live banner          | `.banner`, `.banner-dot`                           | —                                | **Missing** — no live/status banner component                                |
| Animated pulse dot               | `@keyframes pulse`                                 | —                                | **Missing** — no animation utility                                           |
| Contextual stat tiles (3-up)     | `.stat`, `.stat.accent`, `.stat.urgent`            | —                                | **Missing** — no `sp_stat` or metric tile component                          |
| Pill tab nav with counts         | `.chapters`, `.ch`, `.chc`                         | `action_list` (menu) ✓ (partial) | **Missing** — no `sp_tabs` pill-style with badge counts                      |
| Section header + sort link       | `.sec-h`, `.sec-lbl`, `.sec-lnk`                   | —                                | None — trivial markup, app concern                                           |
| Trip card shell                  | `.tcard`                                           | `sp_card` ✓                      | **Partial** — no cover image section with overlay content                    |
| Cover image + gradient overlay   | `.tcover`, `.cov-grad`, `.cov-title`, `.cov-dates` | —                                | **Missing** — `sp_card` has no full-bleed cover slot with positioned overlay |
| Cover chip (e.g. "18 d", "SOON") | `.cov-chip`, `.cov-chip.emb`                       | —                                | **Missing** — no `sp_badge`/`sp_chip` component                              |
| Progress bar with % label        | `.prog`, `.prog-fill`, `.prog-pct`                 | —                                | **Missing** — no `sp_progress_bar` component                                 |
| Next-actions list (urgency dots) | `.next-act`, `.na-r`, `.na-dot.u`                  | `sp_action_list` (partial)       | **Missing** — no urgency/status dot variant; no "+N more" pattern            |
| Member avatar stack              | `.m-avs`, `.m-av` (overlap)                        | `sp_avatar` (single) ✓           | **Missing** — no `sp_avatar` group/stack variant                             |
| Member status text               | `.m-status`                                        | —                                | None — app concern                                                           |
| Dashed invite button             | `.m-invite` (dashed border)                        | `sp_button` ✓                    | **Missing** — no dashed/ghost-dashed variant in theme                        |
| Floating Action Button (FAB)     | `.fab` (pill, shadow, fixed pos)                   | `sp_button` ✓                    | **Missing** — no FAB variant/wrapper                                         |
| Bottom navigation bar            | `.bnav`, `.bni`, `.bni-d`                          | —                                | **Missing** — no `sp_bottom_nav` component                                   |

### 2. Empty State Screen

| UI Element                     | Design Class(es)                        | Package Coverage | Gap                                                           |
| ------------------------------ | --------------------------------------- | ---------------- | ------------------------------------------------------------- |
| Empty state illustration + CTA | `.empty-wrap`, `.empty-ill`, `.empty-h` | —                | **Missing** — no `sp_empty_state` component                   |
| OR divider with label          | `.empty-div` (pseudo-element lines)     | `sp_divider` ✓   | **Partial** — `sp_divider` does not support center label text |
| Feature highlight rows         | `.empty-feat-r`, `.ef-ico`, `.ef-name`  | —                | None — composable from `sp_card`/`sp_icon`, app concern       |

### 3. Discover Screen

| UI Element                       | Design Class(es)                           | Package Coverage                         | Gap                                                                           |
| -------------------------------- | ------------------------------------------ | ---------------------------------------- | ----------------------------------------------------------------------------- |
| 2-column media grid              | `.disc-grid`                               | —                                        | None — CSS grid, app concern                                                  |
| Destination card (cover + tags)  | `.disc-card`, `.disc-tags`, `.disc-tag`    | `sp_card` (partial) ✓                    | **Missing** — no tag/chip list component; cover overlay gap same as trip card |
| Contextual "Because you..." line | `.disc-because`                            | —                                        | None — app concern                                                            |
| List item with thumbnail + badge | `.disc-item`, `.disc-thumb`, `.disc-badge` | `sp_action_list` + `sp_avatar` (partial) | **Missing** — no list-item thumbnail variant; badge component missing         |

### 4. New Trip Sheet (Bottom Sheet)

| UI Element                        | Design Class(es)           | Package Coverage                   | Gap                                                                                     |
| --------------------------------- | -------------------------- | ---------------------------------- | --------------------------------------------------------------------------------------- |
| Scrim overlay (blurred)           | `.scrim` (backdrop-filter) | `modal_controller` (JS) ✓          | **Partial** — `modal_controller` targets dialog, not bottom sheet                       |
| Bottom sheet with drag handle     | `.sheet`, `.sh-dl`         | —                                  | **Missing** — no `sp_sheet` / drawer / bottom sheet component                           |
| Bottom sheet form fields          | `.sf`, `.sf-lbl`, `.sf-v`  | Form builder ✓                     | **Partial** — form builder covers inputs but not the tappable field-row display pattern |
| Side-by-side field row            | `.sfrow`                   | —                                  | None — layout, app concern                                                              |
| Date range display in "When"      | `May 8–15`                 | `sp_combobox_date` (single date) ✓ | **Missing** — `combobox_date_controller` handles single dates; no date-range mode       |
| Traveler count display "2 adults" | `.sf-v` showing count      | —                                  | **Missing** — no stepper/counter input component (`sp_stepper`)                         |
| Sheet CTA button                  | `.sh-cta`                  | `sp_button` ✓                      | None                                                                                    |
| "Start from template" text link   | `.sh-or span`              | —                                  | None — app concern                                                                      |

### 5. Success Screen

| UI Element                     | Design Class(es)              | Package Coverage      | Gap                                                                         |
| ------------------------------ | ----------------------------- | --------------------- | --------------------------------------------------------------------------- |
| Full-screen success transition | `.sapp` (dark bg, centered)   | —                     | **Missing** — no confirmation/success state component or transition wrapper |
| Success ring + checkmark       | `.s-ring`                     | `sp_icon` ✓ (partial) | **Missing** — no `sp_icon` ring/badge container variant                     |
| Summary card (icon rows)       | `.s-card`, `.s-row`, `.s-ico` | `sp_card` ✓           | **Partial** — usable but no icon-label-value row pattern                    |

---

## Categorised Gap List

### A — Missing Components (net-new work required)

| #   | Component                                  | Design Usage                                                  | Priority                      |
| --- | ------------------------------------------ | ------------------------------------------------------------- | ----------------------------- |
| A1  | **`sp_bottom_nav`**                        | 4-item bottom navigation bar with active indicator dot        | High — used on every screen   |
| A2  | **`sp_tabs`** (pill variant)               | "Upcoming / Past" tab switcher with count badge               | High — used on every screen   |
| A3  | **`sp_sheet`** (bottom sheet / drawer)     | "New Trip" slide-up modal with scrim + drag handle            | High — core creation flow     |
| A4  | **`sp_badge` / `sp_chip`**                 | Trip countdown chip, destination tags, list item badges       | High — used across 4 screens  |
| A5  | **`sp_progress_bar`**                      | Trip planning % bar with label row                            | High — inside every trip card |
| A6  | **`sp_stat`** (metric tile)                | 3-up contextual stats (next trip countdown, planned%, budget) | Medium                        |
| A7  | **`sp_avatar` group/stack**                | Overlapping member avatars with CSS negative-margin stacking  | Medium — trip cards + sheet   |
| A8  | **`sp_empty_state`**                       | Illustration + heading + subtitle + CTA for zero-data screens | Medium                        |
| A9  | **`sp_live_banner`** (status banner)       | Pulsing active-trip summary strip with progress and agenda    | Medium                        |
| A10 | **`sp_stepper`** (counter input)           | "Who: 2 adults" increment/decrement field                     | Medium — New Trip sheet       |
| A11 | **Date range mode for `sp_combobox_date`** | "When: May 8–15" — start + end date selection                 | High — New Trip sheet         |

### B — Partial Gaps (existing component needs extension)

| #   | Component                            | Gap                                                                            | Notes                                               |
| --- | ------------------------------------ | ------------------------------------------------------------------------------ | --------------------------------------------------- |
| B1  | **`sp_card`** — cover slot           | No full-bleed cover section with gradient overlay and positioned text/chip     | Trip cards and discover cards both use this pattern |
| B2  | **`sp_button`** — FAB variant        | No floating pill variant with drop shadow; no dashed/ghost-dashed border style | FAB and invite button                               |
| B3  | **`sp_button`** — notification badge | No badge/dot overlay on icon buttons                                           | Bell icon in nav                                    |
| B4  | **`sp_divider`** — center label      | No text label centered between rule lines                                      | Empty state divider                                 |

### C — Theme (Tailwind) Coverage Gaps

| #   | Theme Key            | Affected Component(s)      | Notes                                           |
| --- | -------------------- | -------------------------- | ----------------------------------------------- |
| C1  | Bottom nav / tab bar | `sp_bottom_nav`, `sp_tabs` | No theme keys exist; components don't exist yet |
| C2  | Badge / chip sizes   | `sp_badge`                 | No theme key; component doesn't exist yet       |
| C3  | Progress bar         | `sp_progress_bar`          | No theme key; component doesn't exist yet       |

---

## Interaction / Behaviour Gaps (JS Controllers)

| #   | Behaviour                              | Design Spec                                          | Current Controller                            | Gap                                                                                                              |
| --- | -------------------------------------- | ---------------------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| J1  | Bottom sheet slide-up + dismiss        | Drag handle, swipe-down to close, scrim tap to close | `modal_controller` (dialog-focused)           | Needs new controller or `modal_controller` variant with bottom-anchored positioning and swipe gesture            |
| J2  | Tab switching with URL or Turbo frames | "Upcoming / Past" tabs change content                | `flipper_controller`, `visibility_controller` | No tab controller that manages `aria-selected`, panel association, and keyboard navigation per ARIA tabs pattern |
| J3  | Bottom nav active state + routing      | Highlight active nav item based on current page      | —                                             | No controller; typically server-side active class, but no helper to set it                                       |
| J4  | Animated pulse dot                     | CSS `@keyframes pulse` on live banner                | —                                             | CSS-only; no controller needed, but theme has no animation utility class                                         |
| J5  | Date range selection                   | Select start date, then end date; highlight range    | `combobox_date_controller` (single)           | Controller needs range mode with two-date state machine                                                          |
| J6  | Stepper / counter                      | Tap +/– to increment adults/children                 | —                                             | Needs new `stepper_controller` or `input_formatter_controller` extension                                         |
| J7  | Success transition                     | Full-screen dark overlay after form submit           | —                                             | No controller; app-level Turbo stream or redirect; consider `sp_sheet` dismissal callback                        |

---

## Accessibility Gaps (WCAG 2.1 AA)

| #   | Element                    | Gap                                                                                                                                             |
| --- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| W1  | Pill tab nav               | Needs `role="tablist"`, `role="tab"`, `aria-selected`, `aria-controls` per ARIA Tabs pattern; keyboard: Arrow keys navigate, Enter/Space select |
| W2  | Bottom nav                 | Needs `role="navigation"` + `aria-label="App navigation"`; active item needs `aria-current="page"`                                              |
| W3  | Bottom sheet               | Needs `role="dialog"`, `aria-modal="true"`, `aria-labelledby`; focus must trap inside; Escape closes                                            |
| W4  | Progress bar               | Needs `role="progressbar"`, `aria-valuenow`, `aria-valuemin="0"`, `aria-valuemax="100"`, `aria-label`                                           |
| W5  | Live banner pulse dot      | If conveying status purely by animation/color, needs accessible label (`aria-label` on banner)                                                  |
| W6  | Stepper input              | Needs `role="spinbutton"` or native `<input type="number">`; `aria-valuenow/min/max`; `aria-label`                                              |
| W7  | Avatar stack               | Decorative avatars must have `aria-hidden="true"`; member count must be conveyed in text                                                        |
| W8  | Notification badge on bell | Badge number must be announced: `aria-label="Notifications, 1 unread"` on the button                                                            |
| W9  | FAB                        | Needs `aria-label` ("Create new trip") since it uses an icon + text — text present, label redundant but must not conflict                       |
| W10 | Success ring checkmark     | Icon must have `aria-hidden="true"`; success heading should receive focus or be in `role="status"`                                              |

---

## Recommended Build Order

Given the design, the highest-leverage work to unblock app developers is:

1. **A11 — Date range mode** on `sp_combobox_date` (unblocks the core New Trip form)
2. **A3 — `sp_sheet`** bottom sheet component + `modal_controller` variant (unblocks New Trip flow)
3. **A1 — `sp_bottom_nav`** (every screen; pure markup + theme work, no new controller needed)
4. **A2 — `sp_tabs`** pill variant (every screen; needs tab ARIA controller — J2)
5. **A4 — `sp_badge`/`sp_chip`** (used across 4 of 5 screens)
6. **B1 — `sp_card` cover slot** (trip cards + discover cards)
7. **A5 — `sp_progress_bar`** (inside every trip card)
8. **A7 — `sp_avatar` stack** + **B3 — badge on button** (trip card member row)
9. **A10 — `sp_stepper`** (New Trip "Who" field)
10. **A6 — `sp_stat`**, **A8 — `sp_empty_state`**, **A9 — `sp_live_banner`** (polish / differentiation)
