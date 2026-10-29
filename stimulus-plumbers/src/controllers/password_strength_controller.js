import { Controller } from '@hotwired/stimulus';
import { announce, setHidden } from '../accessibility/aria';
import { attachPasswordStrength } from '../plumbers/password_strength';
import { Requestor } from '../requestor';

export default class extends Controller {
  static targets = ['input', 'meter', 'rule', 'level', 'checkIcon', 'closeIcon'];
  static values = {
    scorer: { type: String, default: 'rules' },
    rules: { type: Array, default: [] },
    options: { type: Object, default: {} },
    labels: { type: Object, default: {} },
    announceDelay: { type: Number, default: 700 },
  };

  initialize() {
    this._requestor = new Requestor();
    attachPasswordStrength(this, { type: this.scorerValue });
  }

  disconnect() {
    this._requestor.cancel();
    this._announcedFrom = null;
  }

  // Value callbacks also run on every connect, so they draw the first state: nothing over
  // server-rendered markup, the current input over a restored snapshot. Never announces.
  rulesValueChanged() {
    this._draw(this.readValue());
  }

  optionsValueChanged() {
    this._draw(this.readValue());
  }

  labelsValueChanged() {
    this._draw(this.readValue());
  }

  // Draws at once; announces the level after a pause in typing, if it differs from the one
  // shown when the typing began.
  score() {
    this._announcedFrom ??= this._shownLabel();
    this._draw(this.readValue());
    this._requestor.schedule(() => this._announce(), this.announceDelayValue);
  }

  readValue() {
    return this.hasInputTarget ? this.inputTarget.value : '';
  }

  drawRules(rules) {
    this.ruleTargets.forEach((target) => {
      const satisfied = !!rules[target.dataset.rule];
      if (target.dataset.satisfied !== String(satisfied)) target.dataset.satisfied = String(satisfied);
      this.drawIcons(target, satisfied);
    });
  }

  drawIcons(target, satisfied) {
    // Targets are controller-scoped, so this.checkIconTargets would return every rule's
    // icons flat. Query within the rule element instead.
    const check = target.querySelector('[data-password-strength-target="checkIcon"]');
    const close = target.querySelector('[data-password-strength-target="closeIcon"]');
    if (!check || !close) return;

    // SVG icons have no `hidden` property, so read the attribute.
    if (check.hasAttribute('hidden') === satisfied) setHidden(check, !satisfied);
    if (close.hasAttribute('hidden') !== satisfied) setHidden(close, satisfied);
  }

  // Re-scores the input as it is now, so a password cleared without typing never announces
  // the level it had.
  _announce() {
    const label = this._label(this._score(this.readValue()).level);
    if (label !== this._announcedFrom) announce(label);
    this._announcedFrom = null;
  }

  // Writes only what differs, so redrawing an unchanged state changes nothing.
  _draw(password) {
    const { value, level, rules } = this._score(password);

    if (this.hasMeterTarget && this.meterTarget.dataset.progressCurrentValue !== `${value}`) {
      this.meterTarget.dataset.progressCurrentValue = `${value}`;
    }
    this.drawRules(rules);
    if (this.hasLevelTarget && this._shownLabel() !== this._label(level)) {
      this.levelTarget.textContent = this._label(level);
    }
  }

  _score(password) {
    return this.strength.score(password, this.rulesValue, this.optionsValue);
  }

  _label(level) {
    return this.labelsValue[level] ?? level;
  }

  _shownLabel() {
    return this.hasLevelTarget ? this.levelTarget.textContent.trim() : null;
  }
}
