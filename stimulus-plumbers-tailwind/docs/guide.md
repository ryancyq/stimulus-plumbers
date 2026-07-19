# Guide

Adding this gem registers and activates the Tailwind theme automatically in Rails — no config
needed. Outside Rails, activate it explicitly with `config.theme.use(:tailwind)`.

Run the install generator once to wire the required CSS imports and `@source` directive into your
Tailwind CSS entry file:

```bash
bin/rails generate stimulus_plumbers:tailwind:install
```

It re-runs automatically on `assets:precompile`/`tailwindcss:build` after that. File detection and
the `STIMULUS_PLUMBERS_CSS_ENTRY` override are shared with the core gem — see
[stimulus-plumbers-rails/docs/guide.md#css-entry-file-detection](../../stimulus-plumbers-rails/docs/guide.md#css-entry-file-detection).

## Installed CSS files

The Tailwind installer copies these files into the application and imports them relatively:

- `app/assets/stylesheets/stimulus_plumbers/tokens.css`
- `app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css` — registers the indeterminate progress bar slide keyframe.

Both files are application-owned: later generator runs restore a missing copy but never overwrite
an existing one. Legacy imports that point into gem directories are migrated to these app-local
paths.

Icons: pass a kebab-case name to `sp_icon` or any `icon_leading:`/`icon_trailing:` option (append
`/solid` for the filled variant) — see [README.md](../README.md#icons) for aliases and the
optional `heroicons` gem.

To implement a custom theme instead of/alongside Tailwind, see
[stimulus-plumbers-rails/docs/component/theme.md](../../stimulus-plumbers-rails/docs/component/theme.md).
