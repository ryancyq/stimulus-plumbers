import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';
import { attachFormatter, attachCharacterCells } from '../plumbers';

export default class extends Controller {
  static targets = ['input', 'toggle', 'cell', 'revealIcon', 'concealIcon'];
  static values = {
    format: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
    revealed: { type: Boolean, default: false },
    groups: { type: Array, default: [] },
    labelReveal: { type: String, default: '' },
    labelConceal: { type: String, default: '' },
  };

  connect() {
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.primeFilledState();
    this.format(this.readValue());
    this.drawToggle();
  }

  formatValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.primeFilledState();
    this.format(this.readValue());
    this.drawToggle();
  }

  optionsValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.primeFilledState();
    this.format(this.readValue());
  }

  revealedValueChanged() {
    if (!this.formatter) return;
    this.format(this.readValue());
    this.drawToggle();
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
    this.drawCells(this.cellsValue(this.formatter.normalize(this.readValue())));
  }

  format(value) {
    if (!this.formatter) return;
    this.onFormatting(value);
  }

  toggle() {
    if (!this.formatter.maskable() && this.formatValue !== 'password') return;
    this.revealedValue = !this.revealedValue;
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
    this.drawCells(this.cellsValue(this.formatter?.normalize(this.readValue()) ?? ''));
  }

  onBlur() {
    this.drawCells(this.cellsValue(this.formatter?.normalize(this.readValue()) ?? ''));
  }

  /** Conceals the value for cell display when the formatter masks and reveal is off */
  cellsValue(value) {
    if (!this.formatter || this.revealedValue || !this.formatter.maskable()) return value;
    return this.formatter.mask(value);
  }

  drawCells(value) {
    if (!this.hasCellTarget) return;
    const focused = this.hasInputTarget && document.activeElement === this.inputTarget;
    this.characterCells?.draw(value, { focused });
  }

  drawToggle() {
    if (!this.hasToggleTarget) return;
    const hasToggleBehavior = this.formatter?.maskable() || this.formatValue === 'password';
    this.toggleTarget.hidden = !hasToggleBehavior;
    if (!hasToggleBehavior || !this.hasRevealIconTarget) return;

    setHidden(this.revealIconTarget, this.revealedValue);
    setHidden(this.concealIconTarget, !this.revealedValue);
    const label = this.revealedValue ? this.labelConcealValue : this.labelRevealValue;
    if (label) this.toggleTarget.setAttribute('aria-label', label);
  }

  readValue() {
    if (!this.hasInputTarget) return '';
    return this.inputTarget instanceof HTMLInputElement ? this.inputTarget.value : this.inputTarget.textContent;
  }

  onFormatting(raw) {
    if (!this.formatter) return;

    if (this.formatValue === 'password') {
      if (this.hasInputTarget) this.inputTarget.type = this.revealedValue ? 'text' : 'password';
      return;
    }

    const value = this.formatter.normalize(raw);
    const formatted =
      this.revealedValue || !this.formatter.maskable() ? this.formatter.format(value) : this.formatter.mask(value);

    if (this.hasInputTarget) {
      if (this.inputTarget instanceof HTMLInputElement) {
        this.inputTarget.value = formatted;
      } else {
        this.inputTarget.textContent = formatted;
      }
    }

    this.dispatch('formatted', { detail: { value: formatted } });
    this.drawCells(this.cellsValue(value));

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
