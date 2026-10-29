import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';
import { attachPasswordStrength } from '../plumbers/password_strength';
import { onMorph } from '../plumbers/plumber/morph';
import { Requestor } from '../requestor';

export default class extends Controller {
  static targets = ['input', 'rule', 'level', 'checkIcon', 'closeIcon'];
  static outlets = ['progress'];
  static values = {
    scorer: { type: String, default: 'rules' },
    rules: { type: Array, default: [] },
    options: { type: Object, default: {} },
    labels: { type: Object, default: {} },
    announceDelay: { type: Number, default: 700 },
  };

  connect() {
    this._requestor = new Requestor();
    attachPasswordStrength(this, { type: this.scorerValue });
    this.connection = new AbortController();
    // The cached page shows the empty-password state.
    document.addEventListener('turbo:before-cache', () => this._render(''), { signal: this.connection.signal });
    onMorph(this.element, () => this._render(), { signal: this.connection.signal });
    this._render();
  }

  disconnect() {
    this._requestor?.cancel();
    this.connection?.abort();
    this.connection = null;
  }

  rulesValueChanged() {
    this._rerender();
  }

  optionsValueChanged() {
    this._rerender();
  }

  labelsValueChanged() {
    this._rerender();
  }

  score() {
    this.announce(this._draw(this.readValue()));
  }

  readValue() {
    return this.hasInputTarget ? this.inputTarget.value : '';
  }

  drawRules(rules) {
    this.ruleTargets.forEach((target) => {
      const satisfied = !!rules[target.dataset.rule];
      target.dataset.satisfied = String(satisfied);
      this.drawIcons(target, satisfied);
    });
  }

  drawIcons(target, satisfied) {
    // Targets are controller-scoped, so this.checkIconTargets would return every rule's
    // icons flat. Query within the rule element instead.
    const check = target.querySelector('[data-password-strength-target="checkIcon"]');
    const close = target.querySelector('[data-password-strength-target="closeIcon"]');
    if (!check || !close) return;

    setHidden(check, !satisfied);
    setHidden(close, satisfied);
  }

  announce(level) {
    if (level === this._level) return;

    this._level = level;
    this._requestor.schedule(() => this._writeLabel(level), this.announceDelayValue);
  }

  _rerender() {
    if (this.connection) this._render();
  }

  // Draws the current state at once, without a debounced announcement.
  _render(password = this.readValue()) {
    this._requestor.cancel();
    this._level = this._draw(password);
    this._writeLabel(this._level);
  }

  _draw(password) {
    const { value, level, rules } = this.strength.score(password, this.rulesValue, this.optionsValue);

    if (this.hasProgressOutlet) this.progressOutlet.setValue(value);
    this.drawRules(rules);
    return level;
  }

  // Writes the live label only when its text changes.
  _writeLabel(level) {
    if (!this.hasLevelTarget) return;

    const label = this.labelsValue[level] ?? level;
    if (this.levelTarget.textContent.trim() !== label) this.levelTarget.textContent = label;
  }
}
