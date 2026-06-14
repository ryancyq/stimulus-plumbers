# Changelog

All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

---
## [0.4.0](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-tailwind/v0.3.3..stimulus-plumbers-tailwind/v0.4.0) - 2026-06-14

### Bug Fixes

- separate form field/choice rendering ([#92](https://github.com/ryancyq/stimulus-plumbers/issues/92)) - ([beedf5f](https://github.com/ryancyq/stimulus-plumbers/commit/beedf5f25849fd8e0411db69733bdb7afda99d9c)) - Ryan Chang
- redesign combobox + popover integration ([#93](https://github.com/ryancyq/stimulus-plumbers/issues/93)) - ([acffee6](https://github.com/ryancyq/stimulus-plumbers/commit/acffee6e8661daa9245223eb4c95df9d066ff452)) - Ryan Chang
- avatar image theme ([#102](https://github.com/ryancyq/stimulus-plumbers/issues/102)) - ([8135d9b](https://github.com/ryancyq/stimulus-plumbers/commit/8135d9bf03df72365b66a22d4c4bfad356c3007f)) - Ryan Chang
- button link with external url will have icon render by default ([#103](https://github.com/ryancyq/stimulus-plumbers/issues/103)) - ([0429cba](https://github.com/ryancyq/stimulus-plumbers/commit/0429cbab170d5a4a7a5009fe0f70023917521725)) - Ryan Chang
- action list / popover builder ([#105](https://github.com/ryancyq/stimulus-plumbers/issues/105)) - ([fc27045](https://github.com/ryancyq/stimulus-plumbers/commit/fc2704527cec4a8e3f5ea5119de33026c936defb)) - Ryan Chang
- button group builder ([#107](https://github.com/ryancyq/stimulus-plumbers/issues/107)) - ([c649df2](https://github.com/ryancyq/stimulus-plumbers/commit/c649df22162758958d4bfcd5a13f56c9bbb61eb6)) - Ryan Chang
- floating label for form inputs ([#109](https://github.com/ryancyq/stimulus-plumbers/issues/109)) - ([16c1c9b](https://github.com/ryancyq/stimulus-plumbers/commit/16c1c9ba2601dbbd9819be2272836a0f56b0b404)) - Ryan Chang
- calendar + combobox date ([#110](https://github.com/ryancyq/stimulus-plumbers/issues/110)) - ([d47065f](https://github.com/ryancyq/stimulus-plumbers/commit/d47065fc888bd81c2e72066dc98d061ff8a6e5a7)) - Ryan Chang
- action list with builder ([#111](https://github.com/ryancyq/stimulus-plumbers/issues/111)) - ([8ba6c3f](https://github.com/ryancyq/stimulus-plumbers/commit/8ba6c3f4a4c51d8e95c57fdde5e7ba499cc17e86)) - Ryan Chang
- icon helper + update doc ([#113](https://github.com/ryancyq/stimulus-plumbers/issues/113)) - ([301adf4](https://github.com/ryancyq/stimulus-plumbers/commit/301adf406102d2d98b8cbd65cb2e3f4f921b5a2e)) - Ryan Chang

### Features

- form floating label ([#96](https://github.com/ryancyq/stimulus-plumbers/issues/96)) - ([13e9854](https://github.com/ryancyq/stimulus-plumbers/commit/13e985424cd2460820f5ae0e7d5c6debad6392e4)) - Ryan Chang
- button variant type ([#97](https://github.com/ryancyq/stimulus-plumbers/issues/97)) - ([c680077](https://github.com/ryancyq/stimulus-plumbers/commit/c680077f14df2aad943c84ed2559d87bcf41e12b)) - Ryan Chang
- calendar with days/months/years views ([#99](https://github.com/ryancyq/stimulus-plumbers/issues/99)) - ([fa530c8](https://github.com/ryancyq/stimulus-plumbers/commit/fa530c8eea38351e08cc27ad66aa6733fdb44f46)) - Ryan Chang
- button fab outline ([#104](https://github.com/ryancyq/stimulus-plumbers/issues/104)) - ([ba877d8](https://github.com/ryancyq/stimulus-plumbers/commit/ba877d8312fcb8362ccd287173af12651e6b7627)) - Ryan Chang

### Style

- update component styling ([#89](https://github.com/ryancyq/stimulus-plumbers/issues/89)) - ([be240aa](https://github.com/ryancyq/stimulus-plumbers/commit/be240aa2a8e9a92b66c95086a8c5d0cfff067da4)) - Ryan Chang
- tailwind choice checkbox/radio ([#95](https://github.com/ryancyq/stimulus-plumbers/issues/95)) - ([1c56b75](https://github.com/ryancyq/stimulus-plumbers/commit/1c56b753596f2d28b4d2320004ae32046e474f8a)) - Ryan Chang
- fix card style across button/link/checkbox/radio ([#108](https://github.com/ryancyq/stimulus-plumbers/issues/108)) - ([6c6f2cc](https://github.com/ryancyq/stimulus-plumbers/commit/6c6f2ccfaca8bffdf186062ad73c38ebee5bdd21)) - Ryan Chang

### Tests

- add snapshots coverage ([#91](https://github.com/ryancyq/stimulus-plumbers/issues/91)) - ([bbd6022](https://github.com/ryancyq/stimulus-plumbers/commit/bbd6022ad37af9a1553971b6a4a928786eb7c421)) - Ryan Chang
- address unit/a11y test gaps ([#101](https://github.com/ryancyq/stimulus-plumbers/issues/101)) - ([68f30e1](https://github.com/ryancyq/stimulus-plumbers/commit/68f30e1ddd1b11a6ab315beb40eb55a4a2946001)) - Ryan Chang
- update sandbox view and snapshot spec ([#120](https://github.com/ryancyq/stimulus-plumbers/issues/120)) - ([d331248](https://github.com/ryancyq/stimulus-plumbers/commit/d331248a082bbc598cad35d38ab16dbde3563c19)) - Ryan Chang

---
## [0.3.3](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-tailwind/v0.3.2..stimulus-plumbers-tailwind/v0.3.3) - 2026-05-26

### Bug Fixes

- both stimulus/turbo calendar will render aria-current=date on today date. tailwind theme will apply today css style via aria attribute ([#77](https://github.com/ryancyq/stimulus-plumbers/issues/77)) - ([29da3cd](https://github.com/ryancyq/stimulus-plumbers/commit/29da3cdf81a069fb4fdfbee3a6d4ac57c9ed9a16)) - Ryan Chang
- rename conflicts with stimulus value/target/class result in ambiguous definitions ([#81](https://github.com/ryancyq/stimulus-plumbers/issues/81)) - ([60d47a7](https://github.com/ryancyq/stimulus-plumbers/commit/60d47a7a907878b45a10f07e82bf647b815b47f0)) - Ryan Chang
- rename autocomplete to typeahead for accurate naming ([#83](https://github.com/ryancyq/stimulus-plumbers/issues/83)) - ([ff5ff26](https://github.com/ryancyq/stimulus-plumbers/commit/ff5ff26143aba80c85b3e638e060c294c92dcc31)) - Ryan Chang
- update version bump script to ruby - ([854935c](https://github.com/ryancyq/stimulus-plumbers/commit/854935c16b840ef9a7fdeac245c25016cdc66053)) - Ryan Chang

### Features

- button with icons ([#82](https://github.com/ryancyq/stimulus-plumbers/issues/82)) - ([7ae5267](https://github.com/ryancyq/stimulus-plumbers/commit/7ae52675a6983b42f574f9919495686b6802a121)) - Ryan Chang
- button variant ([#84](https://github.com/ryancyq/stimulus-plumbers/issues/84)) - ([07b7f9c](https://github.com/ryancyq/stimulus-plumbers/commit/07b7f9c8beebe0be31817809476ab9715926e1ee)) - Ryan Chang
- allow theme schema validation to support other validator like method/boolean instead of just array ([#86](https://github.com/ryancyq/stimulus-plumbers/issues/86)) - ([0eeb485](https://github.com/ryancyq/stimulus-plumbers/commit/0eeb48533e0a7ce20d9031fd782f854ae52d6a64)) - Ryan Chang
- svg icon rendering ([#85](https://github.com/ryancyq/stimulus-plumbers/issues/85)) - ([7405c67](https://github.com/ryancyq/stimulus-plumbers/commit/7405c670b618f6f7e723c852ac633ca2655eda68)) - Ryan Chang
- combobox theme ([#87](https://github.com/ryancyq/stimulus-plumbers/issues/87)) - ([5220185](https://github.com/ryancyq/stimulus-plumbers/commit/522018500956d271da0a6dde44d6c335e2a0c649)) - Ryan Chang

---
## [0.3.2](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-tailwind/v0.3.1..stimulus-plumbers-tailwind/v0.3.2) - 2026-05-20

### Dependencies

- bump stimulus plumber version for tailwind gem - ([b534534](https://github.com/ryancyq/stimulus-plumbers/commit/b5345347638fd2a98fec67812caf087f5528b805)) - Ryan Chang

---
## [0.3.1] - 2026-05-19

### Features

- tailwind gem ([#74](https://github.com/ryancyq/stimulus-plumbers/issues/74)) - ([d9cbbdc](https://github.com/ryancyq/stimulus-plumbers/commit/d9cbbdce65d1d6f93773613a477ea082912af967)) - Ryan Chang

<!-- generated by git-cliff -->
