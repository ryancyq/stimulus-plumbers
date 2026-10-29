import { Controller } from '@hotwired/stimulus';
import { attachFragmentLoader } from '../plumbers/fragment_loader';
import { focusFirst } from '../accessibility/focus';

export default class extends Controller {
  static targets = ['region', 'status'];
  static values = {
    src: String,
    reload: { type: Boolean, default: false },
    loadingText: { type: String, default: 'Loading…' },
    errorText: { type: String, default: 'Content could not be loaded' },
  };

  connect() {
    // Survives reconnects; the swapped-in region keeps the id, not necessarily the target.
    this.regionId ??= this.regionTarget.id;
  }

  disconnect() {
    this.loader?.disconnect();
    this.loader = null;
  }

  // Loads the region on the first open, or on every open with `reload`.
  async onOpened(event) {
    if (!this._owns(event) || (this.loaded && !this.reloadValue)) return;

    const panel = event.target;
    this._setStatus(this.loadingTextValue);
    try {
      const region = await this._loader.load(this.srcValue);
      if (!region) return;

      this.loaded = true;
      this._setStatus('');
      // Replacing the focused element drops focus to the body.
      if (document.activeElement === document.body && panel.matches(':popover-open') && !focusFirst(region)) {
        panel.focus();
      }
    } catch {
      this._setStatus(this.errorTextValue);
    }
  }

  onClosed(event) {
    if (!this._owns(event) || !this._loader.busy) return;

    this._loader.cancel();
    this._setStatus('');
  }

  get _loader() {
    if (!this.loader?.element?.isConnected) {
      this.loader?.disconnect();
      this.loader = attachFragmentLoader(this, {
        element: this.regionId ? this.element.querySelector(`#${CSS.escape(this.regionId)}`) : null,
      });
    }
    return this.loader;
  }

  // Popover events bubble from nested popovers; only the panel holding the region counts.
  _owns(event) {
    const region = this._loader.element;
    return !!region && event.target.contains(region);
  }

  _setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text;
  }
}
