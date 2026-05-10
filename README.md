# Stimulus Plumbers

[![CI Stimulus][ci_stimulus_badge]][ci_stimulus]
[![CI Rails][ci_rails_badge]][ci_rails]

Accessible, WCAG 2.1 AA compliant UI components for Rails + Hotwire applications.

## Packages

| Package | Description |
|---------|-------------|
| [`@stimulus-plumbers/controllers`](stimulus-plumbers/) | Stimulus JS controllers |
| [`stimulus_plumbers`](stimulus-plumbers-rails/) | Rails view helpers and form builder |

The two packages work together: the Rails gem renders semantic, ARIA-wired HTML; the npm package provides the Stimulus controllers that drive behavior.

## License

MIT © Ryan Chang

[ci_stimulus_badge]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-stimulus.yml/badge.svg
[ci_stimulus]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-stimulus.yml
[ci_rails_badge]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-rails.yml/badge.svg
[ci_rails]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-rails.yml
