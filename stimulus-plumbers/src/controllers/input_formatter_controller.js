import { Controller } from '@hotwired/stimulus';
import { attachFormatter, attachCharacterCells } from '../plumbers';

export default class extends Controller {
  static targets = ['input', 'cell'];
  static values = {
    format: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
    groups: { type: Array, default: [] },
  };

  connect() {
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.primeFilledState();
    this.format(this.readValue());
  }

  formatValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.primeFilledState();
    this.format(this.readValue());
  }

  optionsValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.primeFilledState();
    this.format(this.readValue());
  }

  groupsValueChanged() {
    if (!this.formatter) return;
    this.attachCells();
    this.format(this.readValue());
  }

  onChange(event) {
    this.format(event?.detail?.value ?? '');
  }

  // Fires for cells already in the DOM before connect() too, but this.formatter is unset
  // at that point — connect()'s own attachCells() call handles the initial batch, so this
  // only re-attaches for cells added afterward (e.g. Turbo Stream/morph).
  cellTargetConnected() {
    if (!this.formatter) return;
    this.attachCells();
    this.drawCells(this.formatter.normalize(this.readValue()));
  }

  format(value) {
    if (!this.formatter) return;
    this.onFormatting(value);
  }

  onPaste(event) {
    const raw = event.detail?.text ?? '';
    if (!this.formatter || !raw) return;
    const value = this.formatter.normalize(raw);
    if (!this.formatter.validate(value)) return;
    this.format(value);
  }

  attachCells() {
    if (!this.hasCellTarget) return;
    const hints = this.formatter.cells();
    if (!hints) {
      this.detachCells();
      return;
    }
    const hasGroupsOverride = this.groupsValue.length > 0;
    attachCharacterCells(this, {
      groups: hasGroupsOverride ? this.groupsValue : (hints.groups ?? []),
      length: hasGroupsOverride ? 0 : (hints.length ?? 0),
    });
  }

  detachCells() {
    if (!this.hasCellTarget) return;
    this.cellTargets.forEach((cell) => {
      cell.textContent = '';
      cell.removeAttribute('data-filled');
      cell.removeAttribute('data-caret');
    });
    delete this.characterCells;
  }

  onInput() {
    this.format(this.readValue());
  }

  onFocus() {
    this.drawCells(this.formatter?.normalize(this.readValue()) ?? '');
  }

  onBlur() {
    this.drawCells(this.formatter?.normalize(this.readValue()) ?? '');
  }

  drawCells(value) {
    if (!this.hasCellTarget) return;
    const focused = this.hasInputTarget && document.activeElement === this.inputTarget;
    this.characterCells?.draw(value, { focused });
  }

  readValue() {
    if (!this.hasInputTarget) return '';
    return this.inputTarget instanceof HTMLInputElement ? this.inputTarget.value : this.inputTarget.textContent;
  }

  onFormatting(raw) {
    if (!this.formatter) return;

    const value = this.formatter.normalize(raw);
    const formatted = this.formatter.format(value);

    if (this.hasInputTarget) {
      if (this.inputTarget instanceof HTMLInputElement) {
        this.inputTarget.value = formatted;
      } else {
        this.inputTarget.textContent = formatted;
      }
    }

    this.dispatch('formatted', { detail: { value: formatted } });
    this.drawCells(value);

    const full = this.isFull(value);
    if (full && !this.wasFull) {
      this.dispatch('filled', { detail: { value } });
    }
    this.wasFull = full;
  }

  /** Whether value has reached the formatter's configured cell length and is valid.
   *  Prefers the attached CharacterCells' active() count — which already resolves
   *  groups/cell-count/override precedence (see attachCells()) — over the formatter's
   *  raw hint, since some hints (e.g. creditCard) have no fixed length of their own. */
  isFull(value) {
    const expected = this.characterCells?.active() ?? this.formatter?.cells()?.length ?? 0;
    return expected > 0 && value.length === expected && this.formatter.validate(value);
  }

  /** Records the current filled state without dispatching, so system-driven (re)draws
   *  — connect with a prefilled value, format/options changes — never fire `filled` on
   *  their own; only a subsequent user-driven transition into "full" does. */
  primeFilledState() {
    this.wasFull = this.isFull(this.formatter.normalize(this.readValue()));
  }
}
