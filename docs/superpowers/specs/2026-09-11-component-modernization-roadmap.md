# Component Modernization Roadmap

**Original date:** 2026-09-11  
**Status:** Proposed  
**Scope:** Modal, overlay, combobox, calendar and calendar field, and deferred maintenance

## Summary

The major redesigns should land before the general minor-fix pass. That order avoids
spending time repairing controllers that the redesigns will remove, replace, or reduce
to compatibility shims.

This is not a blanket freeze on small fixes. A narrowly scoped defect should still be
fixed immediately when it blocks normal use, risks data loss or security, breaks the
supported browser/Rails matrix, or cannot reasonably wait for the redesign release.

## Design documents

- [Modal modernization](./2026-09-09-modal-modernization-design.md)
- [Overlay foundation modernization](./2026-09-11-overlay-foundation-modernization-design.md)
- [Combobox modernization](./2026-09-11-combobox-modernization-design.md)
- [Calendar and calendar field modernization](./2026-09-11-calendar-modernization-design.md)

## Dependency map

```text
overlay foundation ───────▶ combobox

modal foundation ─────────▶ calendar field presentation
                                  ▲
calendar/date-only core ──────────┘
```

The modal and overlay foundations do not depend on one another and may be implemented
in parallel. The calendar's date-only core and standalone calendar may also proceed
while the modal work is underway, but the composed calendar field must wait for the modal
contract. The combobox must wait for the overlay contract.

**Release coupling (2026-10-05).** The combobox redesign removes the date and time variants, so
it ships with the calendar redesign. `sp_calendar_field` replaces the date variant,
and native `time_field` replaces the time variant. Phases 2 and 3 release together with the
popover foundation (overlay Product Decision 1A).

## Recommended delivery order

### Phase 0: Freeze and baseline

1. Freeze new features in the legacy modal, popover, dropdown, combobox, and date
   controllers.
2. Capture the current public Rails helper and controller APIs in compatibility tests.
3. Add browser coverage for the supported desktop, mobile-web, and Hotwire Native
   environments.
4. Publish the deprecation policy and compatibility window before removing anything.

### Phase 1: Independent foundations

Implement the modal and overlay foundations. They can ship independently behind their
new public APIs.

Release gates:

- reconnect and Turbo cache/restore behavior is deterministic;
- every global listener, observer, and compatibility object is disposable;
- nested overlay behavior has browser tests;
- modal flows close or replace the active modal before opening another;
- Hotwire Native ownership is explicit rather than inferred from user-agent checks;
- the old APIs remain available only through documented compatibility adapters.

### Phase 2: Combobox

Build the new listbox combobox on the completed overlay contract. Replace the current
multi-controller composition with one owner for focus, query, active option, selection,
and form value.

Release gates:

- editable and select-only modes pass the same state-machine tests;
- keyboard and screen-reader semantics work with local and Turbo Frame results;
- remote requests remain outside the base controller;
- date and time behavior is no longer exposed as combobox variants.

### Phase 3: Calendar and calendar field

Build and verify the date-only core and standalone calendar, then compose the calendar
field with the completed modal foundation.

Release gates:

- Ruby and JavaScript pass the same date conformance fixtures;
- values remain calendar dates rather than timestamps;
- calendar keyboard navigation and focus restoration pass browser tests;
- the native Rails date input remains the default path;
- Hotwire Native can choose a native date control without emulating the web dialog.

### Phase 4: Migration and legacy removal

1. Migrate first-party examples and documentation.
2. Exercise upgrade paths in a representative Rails application using Turbo navigation,
   frame replacement, morph refreshes, and Hotwire Native.
3. Ship deprecation warnings for one documented compatibility window.
4. Remove retired controllers, fallback code, and aliases only after usage and migration
   coverage are understood.

### Phase 5: Minor-fix pass

After the major component boundaries are stable, address the remaining independent
maintenance items in a dedicated pass. This is the right point to decide whether each
small controller should be repaired, simplified, deprecated, or removed.

The current candidates are:

- progress: react to dynamic values and keep ARIA state synchronized;
- reorderable: handle pointer cancellation and interrupted drags;
- checklist: recompute correctly after Turbo morphs and list replacement;
- password: recalculate after configuration-value changes;
- clipboard: make optional event behavior consistent;
- character cells: replace noisy warnings with a deliberate validation contract;
- focus trap: either harden its edge cases for non-modal consumers or deprecate it if no
  supported component still needs it.

These items should be re-audited after migration. Some may disappear because their only
consumer was retired, and their priority may change once the redesigned APIs are in real
applications.

## Hotfix exception policy

Do not defer a fix merely because its diff is small. Apply a focused hotfix before or
during the redesign program when all of the following are true:

1. The bug affects a supported public path today.
2. The fix is isolated and does not pre-commit the redesigned API.
3. Waiting would cause substantial user harm or block adoption/testing.
4. A regression test can describe the behavior without depending on the legacy internal
   architecture.

The credit-card input length mismatch found in the component audit belongs in this
category: formatting spaces can consume the input's maximum length before all card
digits are entered. It should receive a small compatibility-safe fix and regression test
rather than wait for the entire modernization program.

Lifecycle defects in the overlay stack and ownership defects in the current combobox
are different. They define the major redesign work itself. Patch them on the legacy
branch only if a maintained release must support that branch before the new components
are ready.

## Work policy during modernization

- New features target only the redesigned APIs.
- Legacy components receive security, data-integrity, severe accessibility, and
  release-blocking compatibility fixes.
- Avoid broad cleanup inside code scheduled for removal.
- Every compatibility adapter has an owner, removal condition, and target release.
- Documentation examples migrate before a legacy API is removed.
- Each major component may ship when its own release gates pass; the project does not
  need to wait for all redesigns to complete before publishing useful work.

## Program definition of done

The modernization program is complete when:

1. Modal, overlay, combobox, and calendar field behavior has a single documented owner at
   each layer.
2. The Rails APIs generate valid, stable, accessible markup without requiring users to
   assemble controller internals.
3. Turbo navigation, frame replacement, morph refreshes, caching, and reconnects have
   integration coverage.
4. Hotwire Native integration is explicit and tested.
5. Retired controllers have migration guidance and no undocumented first-party users.
6. The minor-fix audit has been repeated against the post-redesign codebase.
7. Compatibility shims have either been removed or assigned a documented sunset date.
