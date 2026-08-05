import { Controller } from '@hotwired/stimulus';
import { setValueMin, setValueMax, setValueNow, setValueText } from '../accessibility/aria';

const FORMATS = ['percent', 'value', 'value_max'];

export default class extends Controller {
  static targets = ['fill', 'input', 'meter', 'value'];
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
    format: { type: String, default: '' },
  };

  connect() {
    if (this.variantValue === 'ring' && this.hasFillTarget) this.setCircumference(this.fillTarget);
    // The native input is the source of truth at connect, so a range with no current-value
    // attribute adopts what the markup already shows instead of resetting it.
    if (this.variantValue === 'range') this.currentValue = Number(this.rangeInput.value);
    this.render();
  }

  setValue(value) {
    this.currentValue = this.clamp(value);
    // Move the control too, or the thumb and the submitted value stay stale. Only here —
    // renderRange also runs on the initial paint, before the input's value has been read.
    if (this.variantValue === 'range') this.rangeInput.value = `${this.currentValue}`;
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
      case 'range':
        return this.renderRange();
      case 'ring':
      case 'bar':
      case 'segmented':
        setValueMin(this.element, this.minValue);
        setValueMax(this.element, this.maxValue);
        setValueNow(this.element, this.indeterminateValue ? null : this.clamp(this.currentValue));
        this.element.classList.toggle('sp-progress-indeterminate', this.indeterminateValue);
        this.renderValueText();
        if (this.variantValue === 'ring') return this.renderRing();
        if (this.variantValue === 'segmented') return this.renderSegmented();
        return this.renderBar();
      default:
        return;
    }
  }

  // Clamped: currentValue can arrive out of range from the initial attribute, not just setValue().
  percent() {
    const range = this.maxValue - this.minValue;
    return range <= 0 ? 0 : ((this.clamp(this.currentValue) - this.minValue) / range) * 100;
  }

  formattedValue() {
    const n = this.clamp(this.currentValue);
    switch (this.formatValue) {
      case 'percent':
        return `${Math.round(this.percent())}%`;
      case 'value':
        return `${n}`;
      case 'value_max':
        return `${n} / ${this.maxValue}`;
      default:
        return '';
    }
  }

  // `percent` omits aria-valuetext — AT derives the percentage from aria-valuenow itself.
  // Range omits it too: the native input already announces its own value.
  renderValueText() {
    if (!this.hasValueTarget || !FORMATS.includes(this.formatValue)) return;
    const text = this.indeterminateValue ? '' : this.formattedValue();
    this.valueTarget.textContent = text;
    if (this.formatValue === 'percent' || this.variantValue === 'range') return;
    setValueText(this.element, text || null);
  }

  // The input hosts the controller when there is no readout to contain, so it is the fallback.
  get rangeInput() {
    return this.hasInputTarget ? this.inputTarget : this.element;
  }

  // Action for `input->progress#refresh`. Delegates to setValue so a drag dispatches
  // progress:changed like every other value change.
  refresh() {
    this.setValue(Number(this.rangeInput.value));
  }

  // Never writes aria-value* — a native range already exposes its own slider semantics.
  // WebKit has no filled-track pseudo-element, so the fill is a gradient driven by this
  // property; it must land on the element carrying the track background, i.e. the input.
  renderRange() {
    this.rangeInput.style.setProperty('--sp-progress-percent', `${this.percent()}`);
    this.renderValueText();
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
