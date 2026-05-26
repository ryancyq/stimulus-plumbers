# Changelog

All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

---
## [0.3.3](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-rails/v0.3.2..stimulus-plumbers-rails/v0.3.3) - 2026-05-26

### Bug Fixes

- both stimulus/turbo calendar will render aria-current=date on today date. tailwind theme will apply today css style via aria attribute ([#77](https://github.com/ryancyq/stimulus-plumbers/issues/77)) - ([29da3cd](https://github.com/ryancyq/stimulus-plumbers/commit/29da3cdf81a069fb4fdfbee3a6d4ac57c9ed9a16)) - Ryan Chang
- untested examples ([#79](https://github.com/ryancyq/stimulus-plumbers/issues/79)) - ([a99e887](https://github.com/ryancyq/stimulus-plumbers/commit/a99e887be863508d08c8657757f5ec32d931580e)) - Ryan Chang
- rename conflicts with stimulus value/target/class result in ambiguous definitions ([#81](https://github.com/ryancyq/stimulus-plumbers/issues/81)) - ([60d47a7](https://github.com/ryancyq/stimulus-plumbers/commit/60d47a7a907878b45a10f07e82bf647b815b47f0)) - Ryan Chang
- rename autocomplete to typeahead for accurate naming ([#83](https://github.com/ryancyq/stimulus-plumbers/issues/83)) - ([ff5ff26](https://github.com/ryancyq/stimulus-plumbers/commit/ff5ff26143aba80c85b3e638e060c294c92dcc31)) - Ryan Chang
- update version bump script to ruby - ([854935c](https://github.com/ryancyq/stimulus-plumbers/commit/854935c16b840ef9a7fdeac245c25016cdc66053)) - Ryan Chang
- overuse of html_options, replace with generic kwargs - ([9efa833](https://github.com/ryancyq/stimulus-plumbers/commit/9efa8332840334298502fd3f4d990ba48d0570ae)) - Ryan Chang
- calendar helper when no date is provided - ([a049c71](https://github.com/ryancyq/stimulus-plumbers/commit/a049c71ca64ab32e712ed8cc28057bec4910bc2b)) - Ryan Chang

### Features

- calendar month selected ([#78](https://github.com/ryancyq/stimulus-plumbers/issues/78)) - ([d826697](https://github.com/ryancyq/stimulus-plumbers/commit/d8266979fff9041474b29ffa937acfec94e95ca3)) - Ryan Chang
- button with icons ([#82](https://github.com/ryancyq/stimulus-plumbers/issues/82)) - ([7ae5267](https://github.com/ryancyq/stimulus-plumbers/commit/7ae52675a6983b42f574f9919495686b6802a121)) - Ryan Chang
- button variant ([#84](https://github.com/ryancyq/stimulus-plumbers/issues/84)) - ([07b7f9c](https://github.com/ryancyq/stimulus-plumbers/commit/07b7f9c8beebe0be31817809476ab9715926e1ee)) - Ryan Chang
- allow theme schema validation to support other validator like method/boolean instead of just array ([#86](https://github.com/ryancyq/stimulus-plumbers/issues/86)) - ([0eeb485](https://github.com/ryancyq/stimulus-plumbers/commit/0eeb48533e0a7ce20d9031fd782f854ae52d6a64)) - Ryan Chang
- svg icon rendering ([#85](https://github.com/ryancyq/stimulus-plumbers/issues/85)) - ([7405c67](https://github.com/ryancyq/stimulus-plumbers/commit/7405c670b618f6f7e723c852ac633ca2655eda68)) - Ryan Chang
- combobox theme ([#87](https://github.com/ryancyq/stimulus-plumbers/issues/87)) - ([5220185](https://github.com/ryancyq/stimulus-plumbers/commit/522018500956d271da0a6dde44d6c335e2a0c649)) - Ryan Chang

### Tests

- reorganize test structure due to recent refactoring ([#80](https://github.com/ryancyq/stimulus-plumbers/issues/80)) - ([edbb1a8](https://github.com/ryancyq/stimulus-plumbers/commit/edbb1a832eb493dd41434bb1d668e5cef076d52a)) - Ryan Chang
- theme scheme validator include/exclude usecases - ([edf287f](https://github.com/ryancyq/stimulus-plumbers/commit/edf287fa6c01ff718d5291909f67300f36a232ef)) - Ryan Chang

---
## [0.3.1](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-rails/v0.3.0..stimulus-plumbers-rails/v0.3.1) - 2026-05-19

### Features

- form input group + fieldset ([#75](https://github.com/ryancyq/stimulus-plumbers/issues/75)) - ([b18916f](https://github.com/ryancyq/stimulus-plumbers/commit/b18916f2dcf004ae358a598ce54f28231b069af3)) - Ryan Chang

---
## [0.3.0](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-rails/v0.2.9..stimulus-plumbers-rails/v0.3.0) - 2026-05-18

### Bug Fixes

- reduce complexity violations raised by rubocop ([#65](https://github.com/ryancyq/stimulus-plumbers/issues/65)) - ([f540d38](https://github.com/ryancyq/stimulus-plumbers/commit/f540d3820158229661249c2c9095eca95c638ff1)) - Ryan Chang
- default theme to base ([#71](https://github.com/ryancyq/stimulus-plumbers/issues/71)) - ([3ba50fe](https://github.com/ryancyq/stimulus-plumbers/commit/3ba50feb8233083c3cca40467940ebf99eab7178)) - Ryan Chang
- update calendar + combobox documentation and test coverage ([#72](https://github.com/ryancyq/stimulus-plumbers/issues/72)) - ([3fb4a6f](https://github.com/ryancyq/stimulus-plumbers/commit/3fb4a6f93f049bb7d88ed7de2dcbb592f8a58185)) - Ryan Chang

### Dependencies

- replace runtime dep from railties to actionview ([#66](https://github.com/ryancyq/stimulus-plumbers/issues/66)) - ([c58dff5](https://github.com/ryancyq/stimulus-plumbers/commit/c58dff56149319f97247a4078fba766218c7bf9b)) - Ryan Chang

### Documentation

- update readme with rake task cmds - ([8bbb0f8](https://github.com/ryancyq/stimulus-plumbers/commit/8bbb0f855d4b0a1cd2c115b071f6b1e6388d47d2)) - Ryan Chang

### Features

- icon schema for theme ([#70](https://github.com/ryancyq/stimulus-plumbers/issues/70)) - ([ff952c6](https://github.com/ryancyq/stimulus-plumbers/commit/ff952c6eb390b249e4605a9ddc178709133b8bbc)) - Ryan Chang
- theme config ([#73](https://github.com/ryancyq/stimulus-plumbers/issues/73)) - ([2745309](https://github.com/ryancyq/stimulus-plumbers/commit/27453095d7c6140cda49dc24eb86b12bab5894c7)) - Ryan Chang

### Style

- add calendar week + combobox trigger theme option ([#67](https://github.com/ryancyq/stimulus-plumbers/issues/67)) - ([e7f52e3](https://github.com/ryancyq/stimulus-plumbers/commit/e7f52e3c394138b146da96d22381e06008fd0f6b)) - Ryan Chang

### Tests

- rename system tests as a11y test to reflect its usage accurately ([#64](https://github.com/ryancyq/stimulus-plumbers/issues/64)) - ([4bd7563](https://github.com/ryancyq/stimulus-plumbers/commit/4bd7563aea00543cfdb01bebe9d2491e8846caca)) - Ryan Chang
- playwright snapshot ([#68](https://github.com/ryancyq/stimulus-plumbers/issues/68)) - ([d0ef50e](https://github.com/ryancyq/stimulus-plumbers/commit/d0ef50e7bf8fd86d67f1b19b453a56ed8a0d9349)) - Ryan Chang

---
## [0.2.9](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-rails/v0.2.8..stimulus-plumbers-rails/v0.2.9) - 2026-05-15

### Bug Fixes

- combobox options + theme ([#53](https://github.com/ryancyq/stimulus-plumbers/issues/53)) - ([38b8f56](https://github.com/ryancyq/stimulus-plumbers/commit/38b8f5632fd62ed62947d62567e704a0b8b46f74)) - Ryan Chang
- update broken ruby action bindings ([#55](https://github.com/ryancyq/stimulus-plumbers/issues/55)) - ([f2259df](https://github.com/ryancyq/stimulus-plumbers/commit/f2259dfd8f2369bb588ee24fec3d9e8a8f854093)) - Ryan Chang

### Documentation

- update form input ([#49](https://github.com/ryancyq/stimulus-plumbers/issues/49)) - ([dd35b7f](https://github.com/ryancyq/stimulus-plumbers/commit/dd35b7fdadf5ffb8808b00c0c5b75542bcde4d02)) - Ryan Chang
- update theme to align with implementation ([#57](https://github.com/ryancyq/stimulus-plumbers/issues/57)) - ([0645cfa](https://github.com/ryancyq/stimulus-plumbers/commit/0645cfa9896aa65082b7f2fd9e619d2216c13f75)) - Ryan Chang

### Features

- form input search ([#50](https://github.com/ryancyq/stimulus-plumbers/issues/50)) - ([130b966](https://github.com/ryancyq/stimulus-plumbers/commit/130b9666a644a54b94da5ba23f5d0b32a0458f53)) - Ryan Chang

### Tests

- code coverage report ([#48](https://github.com/ryancyq/stimulus-plumbers/issues/48)) - ([78950e6](https://github.com/ryancyq/stimulus-plumbers/commit/78950e603ac7e003b5c6361ab6016796caca3397)) - Ryan Chang

---
## [0.2.8](https://github.com/ryancyq/stimulus-plumbers/compare/stimulus-plumbers-rails/v0.2.7..stimulus-plumbers-rails/v0.2.8) - 2026-05-10

### Features

- input group ([#46](https://github.com/ryancyq/stimulus-plumbers/issues/46)) - ([a5e24f6](https://github.com/ryancyq/stimulus-plumbers/commit/a5e24f6dbc8b740822333164ceeefd7d20367f1b)) - Ryan Chang

### Tests

- theme coverage ([#45](https://github.com/ryancyq/stimulus-plumbers/issues/45)) - ([cc86565](https://github.com/ryancyq/stimulus-plumbers/commit/cc86565fd65a5b9dc390e838d379de75576d60ba)) - Ryan Chang

---
## [0.2.2] - 2026-04-14

### Dependencies

- migrate from rspec to minitest ([#16](https://github.com/ryancyq/stimulus-plumbers/issues/16)) - ([b183919](https://github.com/ryancyq/stimulus-plumbers/commit/b1839196235a7462d58bb2d3f9532388ffd916c2)) - Ryan Chang

### Documentation

- update claude.md - ([2b36f6d](https://github.com/ryancyq/stimulus-plumbers/commit/2b36f6dcf7ce7c9154c187b011c2f8cf4cc5b9f9)) - Ryan Chang

### Features

- stimulus plumbers rails gem ([#4](https://github.com/ryancyq/stimulus-plumbers/issues/4)) - ([e492e0f](https://github.com/ryancyq/stimulus-plumbers/commit/e492e0f910a6331328d52725f1931d9cd86c9563)) - Ryan Chang
- stimulus-rails UI components ([#15](https://github.com/ryancyq/stimulus-plumbers/issues/15)) - ([8e8b58c](https://github.com/ryancyq/stimulus-plumbers/commit/8e8b58c661a7cd8c79d7e65b729e3ea077e596b9)) - Ryan Chang
- form builder ([#21](https://github.com/ryancyq/stimulus-plumbers/issues/21)) - ([21aa9a6](https://github.com/ryancyq/stimulus-plumbers/commit/21aa9a634eca340e712f922f43ceb7383b56daee)) - Ryan Chang

### Tests

- a11y ([#17](https://github.com/ryancyq/stimulus-plumbers/issues/17)) - ([4109a8a](https://github.com/ryancyq/stimulus-plumbers/commit/4109a8af8be8aab06ddbcff35e870556a6205852)) - Ryan Chang
- update rake test task to include system test - ([aa215b0](https://github.com/ryancyq/stimulus-plumbers/commit/aa215b0a84a36f32083327b4e7f03a646187cee9)) - Ryan Chang

<!-- generated by git-cliff -->
