import { Controller } from '@hotwired/stimulus';

export default class ComboboxTimeController extends Controller {
  static targets = ['hour', 'minute', 'period'];

  connect() {
    this.select(this.toH24());
  }

  onSelect(event) {
    const item = event.target.closest('[role="option"]');
    if (!item) return;
    const drum = item.closest('[role="listbox"]');
    drum.querySelectorAll('[role="option"]').forEach((o) => o.setAttribute('aria-selected', 'false'));
    item.setAttribute('aria-selected', 'true');
    this.select(this.toH24());
  }

  select(value) {
    if (value) this.dispatch('selected', { detail: { value }, bubbles: true });
  }

  onNavigate(event) {
    if (!['ArrowUp', 'ArrowDown'].includes(event.key)) return;
    event.preventDefault();
    this.step(event.currentTarget, event.key === 'ArrowDown' ? 1 : -1);
  }

  step(drum, delta) {
    const items = [...drum.querySelectorAll('[role="option"]')];
    const current = drum.querySelector('[aria-selected="true"]');
    const idx = items.indexOf(current);
    const next = delta > 0 ? items[Math.min(idx + 1, items.length - 1)] : items[Math.max(idx - 1, 0)];
    if (!next || next === current) return;
    items.forEach((o) => o.setAttribute('aria-selected', 'false'));
    next.setAttribute('aria-selected', 'true');
    next.scrollIntoView({ block: 'nearest' });
    this.select(this.toH24());
  }

  toH24() {
    const h = this.selectedValue(this.hourTarget);
    const m = this.selectedValue(this.minuteTarget);
    if (!h || !m) return null;
    if (!this.hasPeriodTarget) return `${h}:${m}`;
    const period = this.selectedValue(this.periodTarget);
    let hour = parseInt(h, 10);
    if (period === 'AM') hour = hour === 12 ? 0 : hour;
    else hour = hour === 12 ? 12 : hour + 12;
    return `${String(hour).padStart(2, '0')}:${m}`;
  }

  selectedValue(drum) {
    return drum?.querySelector('[aria-selected="true"]')?.dataset.value ?? null;
  }
}
