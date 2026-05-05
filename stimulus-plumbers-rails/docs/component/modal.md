# Modal

The `modal` controller is used directly in HTML — there is no Rails helper. See the [JS controller docs](../../../stimulus-plumbers/docs/component/modal.md) for targets, methods, and usage examples.

## Quick example (ERB)

```erb
<div data-controller="modal">
  <%= tag.button "Open", data: { action: "modal#open" } %>

  <%= tag.dialog data: { modal_target: "modal" },
                 aria: { labelledby: "modal-title", modal: true } do %>
    <h2 id="modal-title">Confirm action</h2>
    <p>Are you sure?</p>
    <%= tag.button "Cancel",  data: { action: "modal#close" } %>
    <%= tag.button "Confirm" %>
  <% end %>
</div>
```
