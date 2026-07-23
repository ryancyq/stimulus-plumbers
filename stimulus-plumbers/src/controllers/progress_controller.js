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
    segmentMode: { type: String, default: 'discrete' },
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
      case 'segmented':
        setValueMin(this.element, this.minValue);
        setValueMax(this.element, this.maxValue);
        setValueNow(this.element, this.indeterminateValue ? null : this.currentValue);
        this.element.classList.toggle('sp-progress-indeterminate', this.indeterminateValue);
        if (this.variantValue === 'ring') return this.renderRing();
        if (this.variantValue === 'segmented') return this.renderSegmented();
        return this.renderBar();
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

  renderSegmented() {
    const fills = this.fillTargets;
    const count = fills.length;
    if (count === 0) return;
    if (this.indeterminateValue) {
      // Each slot holds a chunk the theme slides; index/count stagger relays one chunk across the row.
      fills.forEach((fill, i) => {
        fill.style.setProperty('--sp-progress-index', i);
        fill.style.setProperty('--sp-progress-count', count);
        fill.style.width = `${this.indeterminateFractionValue * 100}%`;
      });
      return;
    }
    // Slot i holds the fill fraction within [i, i+1); discrete snaps the leading slot to whole.
    const filledSegments = (this.percent() / 100) * count;
    fills.forEach((fill, i) => {
      let local = Math.min(1, Math.max(0, filledSegments - i));
      if (this.segmentModeValue === 'discrete') local = local > 0 ? 1 : 0;
      fill.style.width = `${local * 100}%`;
    });
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
