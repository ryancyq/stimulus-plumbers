# Guide

Adding this gem registers and activates the Tailwind theme automatically in Rails — no config
needed. Outside Rails, activate it explicitly with `config.theme.use(:tailwind)`.

Run the install generator once to wire the required `@source` directive into your Tailwind CSS
entry file:

```bash
bin/rails generate stimulus_plumbers:tailwind:install
```

It re-runs automatically on `assets:precompile`/`tailwindcss:build` after that — see
[README.md](../README.md#installation) for file-detection order and the `TAILWIND_CSS_FILE`
override.

Icons: pass a kebab-case name to `sp_icon` or any `icon_leading:`/`icon_trailing:` option (append
`/solid` for the filled variant) — see [README.md](../README.md#icons) for aliases and the
optional `heroicons` gem.

To implement a custom theme instead of/alongside Tailwind, see
[stimulus-plumbers-rails/docs/component/theme.md](../../stimulus-plumbers-rails/docs/component/theme.md).
