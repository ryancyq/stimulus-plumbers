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
    segmentMode: { type: String, default: 'discrete' },
    format: { type: String, default: '' },
  };

  // The native input is the source of truth, so a range with no current-value attribute adopts
  // what the markup already shows. Runs before the value callbacks, which then paint.
  initialize() {
    if (this.variantValue === 'range') this.currentValue = Number(this.rangeInput.value);
  }

  setValue(value) {
    const next = this._clamp(value);
    if (this.variantValue === 'range') this.rangeInput.value = `${next}`;
    if (next === this.currentValue) return;

    this.currentValue = next;
    this._render();
    this.dispatch('changed', { detail: { value: next, min: this.minValue, max: this.maxValue } });
  }

  // Action for `input->progress#refresh`. Delegates to setValue so a drag dispatches
  // progress:changed like every other value change.
  refresh() {
    this.setValue(Number(this.rangeInput.value));
  }

  currentValueChanged() {
    if (this.variantValue === 'range') this.rangeInput.value = `${this._clamp(this.currentValue)}`;
    this._render();
  }

  minValueChanged() {
    this._render();
  }

  maxValueChanged() {
    this._render();
  }

  optimumValueChanged() {
    this._render();
  }

  lowValueChanged() {
    this._render();
  }

  highValueChanged() {
    this._render();
  }

  indeterminateValueChanged() {
    this._render();
  }

  formatValueChanged() {
    this._render();
  }

  // The input hosts the controller when there is no readout to contain, so it is the fallback.
  get rangeInput() {
    return this.hasInputTarget ? this.inputTarget : this.element;
  }

  // Geometry is CSS driven by --sp-progress-percent; this writes it, the ARIA, and the readout.
  _render() {
    switch (this.variantValue) {
      case 'meter':
        return this._renderMeter();
      case 'range':
        return this._renderRange();
      case 'ring':
      case 'bar':
      case 'segmented':
        setValueMin(this.element, this.minValue);
        setValueMax(this.element, this.maxValue);
        setValueNow(this.element, this.indeterminateValue ? null : this._clamp(this.currentValue));
        this._renderValueText();
        this.element.style.setProperty('--sp-progress-percent', this._percentProperty());
        return;
      default:
        return;
    }
  }

  _clamp(value) {
    return Math.min(this.maxValue, Math.max(this.minValue, value));
  }

  // Clamped: currentValue can arrive out of range from the initial attribute, not just setValue().
  _percent() {
    const range = this.maxValue - this.minValue;
    return range <= 0 ? 0 : ((this._clamp(this.currentValue) - this.minValue) / range) * 100;
  }

  // Two decimals, as the server renders it.
  _percentProperty() {
    return `${Math.round(this._percent() * 100) / 100}`;
  }

  _formattedValue() {
    const n = this._clamp(this.currentValue);
    switch (this.formatValue) {
      case 'percent':
        return `${Math.round(this._percent())}%`;
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
  _renderValueText() {
    if (!this.hasValueTarget || !FORMATS.includes(this.formatValue)) return;
    const text = this.indeterminateValue ? '' : this._formattedValue();
    this.valueTarget.textContent = text;
    if (this.formatValue === 'percent' || this.variantValue === 'range') return;
    setValueText(this.element, text || null);
  }

  // Never writes aria-value* — a native range already exposes its own slider semantics.
  // WebKit has no filled-track pseudo-element, so the fill is a gradient driven by this
  // property; it must land on the element carrying the track background, i.e. the input.
  _renderRange() {
    this.rangeInput.style.setProperty('--sp-progress-percent', this._percentProperty());
    this._renderValueText();
  }

  _renderMeter() {
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
