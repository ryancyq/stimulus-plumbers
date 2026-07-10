import { Controller } from '@hotwired/stimulus';
import { setValueMin, setValueMax, setValueNow } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['fill', 'meter'];
  static values = {
    variant: { type: String, default: 'bar' },
    current: { type: Number, default: 0 },
    min: { type: Number, default: 0 },
    max: { type: Number, default: 100 },
    optimum: Number,
    low: Number,
    high: Number,
    indeterminate: { type: Boolean, default: false },
    indeterminateFraction: { type: Number, default: 0.25 },
  };

  connect() {
    if (this.variantValue === 'ring' && this.hasFillTarget) this.setCircumference(this.fillTarget);
    this.render();
  }

  setValue(value) {
    this.currentValue = this.clamp(value);
    this.render();
    this.dispatch('changed', { detail: { value: this.currentValue, min: this.minValue, max: this.maxValue } });
  }

  currentValueChanged() {
    this.render();
  }

  clamp(value) {
    return Math.min(this.maxValue, Math.max(this.minValue, value));
  }

  render() {
    switch (this.variantValue) {
      case 'meter':
        return this.renderMeter();
      case 'ring':
      case 'bar':
        setValueMin(this.element, this.minValue);
        setValueMax(this.element, this.maxValue);
        setValueNow(this.element, this.indeterminateValue ? null : this.currentValue);
        this.element.classList.toggle('sp-progress-indeterminate', this.indeterminateValue);
        return this.variantValue === 'ring' ? this.renderRing() : this.renderBar();
      default:
        return;
    }
  }

  percent() {
    const range = this.maxValue - this.minValue;
    return range <= 0 ? 0 : ((this.currentValue - this.minValue) / range) * 100;
  }

  renderBar() {
    if (!this.hasFillTarget) return;
    if (this.indeterminateValue) {
      this.fillTarget.style.width = `${this.indeterminateFractionValue * 100}%`;
      return;
    }
    this.fillTarget.style.width = `${this.percent()}%`;
  }

  renderRing() {
    if (!this.hasFillTarget) return;
    if (this.circumference == null) this.setCircumference(this.fillTarget);
    if (this.indeterminateValue) {
      const arc = this.circumference * this.indeterminateFractionValue;
      this.fillTarget.style.strokeDasharray = `${arc} ${this.circumference - arc}`;
      return;
    }
    this.fillTarget.style.strokeDasharray = `${this.circumference}`;
    this.fillTarget.style.strokeDashoffset = `${this.circumference * (1 - this.percent() / 100)}`;
  }

  setCircumference(circle) {
    const r = parseFloat(circle.getAttribute('r'));
    this.circumference = 2 * Math.PI * r;
  }

  renderMeter() {
    if (!this.hasMeterTarget || !(this.meterTarget instanceof HTMLMeterElement)) return;
    const meter = this.meterTarget;
    meter.value = this.currentValue;
    meter.min = this.minValue;
    meter.max = this.maxValue;
    if (this.hasLowValue) meter.low = this.lowValue;
    if (this.hasHighValue) meter.high = this.highValue;
    if (this.hasOptimumValue) meter.optimum = this.optimumValue;
  }
}
