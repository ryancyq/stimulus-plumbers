import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';
import { attachPasswordStrength } from '../plumbers/password_strength';
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
    this._level = null;
    attachPasswordStrength(this, { type: this.scorerValue });
    this.score();
  }

  disconnect() {
    this._requestor?.cancel();
  }

  score() {
    const { value, level, rules } = this.strength.score(this.readValue(), this.rulesValue, this.optionsValue);

    if (this.hasProgressOutlet) this.progressOutlet.setValue(value);
    this.drawRules(rules);
    this.announce(level);
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
    if (!this.hasLevelTarget) return;

    const label = this.labelsValue[level] ?? level;
    this._requestor.schedule(() => {
      this.levelTarget.textContent = label;
    }, this.announceDelayValue);
  }
}
