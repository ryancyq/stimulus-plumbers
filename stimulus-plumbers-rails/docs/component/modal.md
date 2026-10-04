# Modal

`sp_modal` renders one native `<dialog>` and its optional trigger, content slots, and action
buttons under one `modal` controller. The JavaScript API is documented in the [JS modal
guide](../../../stimulus-plumbers/docs/component/modal.md); accessibility rules live in
[ARIA.md](../../../ARIA.md).

Migration from legacy custom-overlay markup is documented in the [JS modal migration
guide](../../../stimulus-plumbers/docs/component/modal.md#migration-from-legacy-modal-markup).

The supported contract allows one active modal at a time. Opening another modal while one is open
is unsupported; applications should close or replace the active modal first.

```erb
<%= sp_modal id: "delete-project", title: "Delete project?" do |modal| %>
  <% modal.trigger { "Delete project" } %>
  <% modal.body do %>
    <p>This action cannot be undone.</p>
  <% end %>
  <% modal.footer do %>
    <%= modal.dismiss_button "Cancel", autofocus: true %>
    <%= modal.close_button "Delete", result: "delete", variant: :destructive %>
  <% end %>
<% end %>
```

## Local form

Use the existing builder slots for a form rendered in the current page:

```erb
<%= sp_modal id: "edit-project", title: "Edit project" do |modal| %>
  <% modal.trigger { "Edit project" } %>
  <% modal.body do %>
    <%= form_with model: @project, url: project_path(@project), method: :patch, id: "edit-project-form" do |form| %>
      <%= form.label :name %>
      <%= form.text_field :name %>
    <% end %>
  <% end %>
  <% modal.footer do %>
    <%= modal.dismiss_button "Cancel" %>
    <%= submit_tag "Save", form: "edit-project-form" %>
  <% end %>
<% end %>
```

## Options

| Option           | Default         | Description                         |
| ---------------- | --------------- | ----------------------------------- |
| `id:`            | required        | Stable dialog id                    |
| `title:`         | —               | Visible accessible name             |
| `aria_label:`    | —               | Name for a titleless dialog         |
| `size:`          | `:md`           | `:sm`, `:md`, `:lg`, or `:xl`       |
| `closed_by:`     | `:closerequest` | `:any`, `:closerequest`, or `:none` |
| `kind:`          | `:dialog`       | `:dialog` or `:alertdialog`         |
| `**html_options` | —               | Attributes for the outer wrapper    |

`title:` takes precedence over `aria_label:`. A title renders as `#{id}-title` and owns the
dialog's `aria-labelledby`. The `body` slot is the default scrolling region; `header` adds
content beside the generated title and `footer` is optional.

Blank IDs, missing accessible names, and unsupported `closed_by:` or `kind:` values raise
`ArgumentError`. Visual theme options such as `size:` use the theme's warning and fallback path.

The builder methods are `trigger`, `header`, `body`, `footer`, `dismiss_button`, and
`close_button`. `close_button` accepts an optional `result:`; `dismiss_button` may also pass a
result for a dismissal request.

`trigger` renders the packaged Button for a zero-arity block. A one-arity block receives complete
button attributes, including `type`, `commandfor`, `command`, and `data-action`; it does not use
`aria-expanded`.

Packaged `dismiss_button` and `close_button` controls set native `commandfor` and `command`
attributes alongside their Stimulus actions. `result:` also becomes the button `value`, so native
dialog closing establishes `dialog.returnValue`.

## Turbo modal

`sp_modal_turbo` renders a layout-level Turbo modal with `modal` and `modal-turbo` on the same
wrapper. It has no block or builder:

```erb
<%= sp_modal_turbo id: "modal", size: :md, closed_by: :closerequest %>
```

Options are `id:` (required stable frame ID), `size: :md`, `closed_by: :closerequest`,
`close_on_success: true`, `aria_label: nil`, and wrapper `**html_options`. Without `aria_label`,
the dialog uses `aria-labelledby="#{id}-title"`; remote responses should include a visible
heading with that ID. With `aria_label`, it uses `aria-label` instead.

Use `sp_modal_link_to` for a normal styled link targeting the Turbo modal:

```erb
<%= sp_modal_link_to "Edit project", url: edit_project_path(@project), modal_id: "modal" %>
```

On the web it sets `data-turbo-frame="modal"` while preserving caller data and actions. In
Hotwire Native it is a normal navigation link; path configuration owns `context: "modal"`.
The route remains directly navigable and should return a matching `<turbo-frame id="modal">`
for frame requests or the normal page for a direct visit. A 422 validation response stays open;
a successful form submission closes by default and clears the frame. Follow Turbo's normal form
contract by redirecting successful state-changing submissions; use HTTP 303 for non-GET requests.

On validation responses, deliberately put `autofocus` on the invalid field (or another intentional
static error target when appropriate) so the replacement preserves useful focus. The adapter does
not override valid author or Turbo focus.

The frame response uses direct region children: a `<header>` with the matching visible title
(for example, `<h2 id="modal-title">`) when the dialog uses `aria-labelledby`, one body `<div>`
containing the form, and an optional `<footer>`. A footer submit can target the body form with its
standard `form="..."` attribute:

```erb
<turbo-frame id="modal">
  <header><h2 id="modal-title">Edit project</h2></header>
  <div>
    <%= form_with model: @project, url: project_path(@project), method: :patch, id: "edit-project-form" do |form| %>
      <%= form.label :name %>
      <%= form.text_field :name %>
    <% end %>
  </div>
  <footer><%= submit_tag "Save", form: "edit-project-form" %></footer>
</turbo-frame>
```

## Hotwire Native route-level forms

`sp_modal_link_to` remains a normal navigation link in Hotwire Native. Configure the route in the
app's Path Configuration:

On successful submission, choose the navigation helper for the intended outcome:

```ruby
class ProjectsController < ApplicationController
  def update
    if @project.update(project_params)
      recede_or_redirect_to project_path(@project)
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
```

Use `recede_or_redirect_to` to dismiss the modal route, `refresh_or_redirect_to` when the current
screen must refresh, or `resume_or_redirect_to` when native navigation should remain unchanged.
Each helper redirects to the supplied destination on the web.

```json
{
  "settings": {},
  "rules": [
    {
      "patterns": ["/projects/new$", "/projects/[^/]+/edit$"],
      "properties": {
        "context": "modal",
        "pull_to_refresh_enabled": false
      }
    }
  ]
}
```

Android also sets the app's registered `uri` for the modal destination, for example
`"uri": "hotwire://fragment/web/modal/sheet"`. iOS may additionally set `modal_style` and the
static `modal_dismiss_gesture_enabled` property according to the app's presentation policy. See
the official [Path Configuration reference](https://native.hotwired.dev/reference/path-configuration),
[Android Path Configuration guide](https://native.hotwired.dev/android/path-configuration), and
[iOS Path Configuration guide](https://native.hotwired.dev/ios/path-configuration).
