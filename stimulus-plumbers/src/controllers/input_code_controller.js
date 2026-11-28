import { Controller } from '@hotwired/stimulus';
import { setAriaHidden } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['input', 'cell'];

  connect() {
    this.draw();
  }

  cellTargetConnected(cell) {
    setAriaHidden(cell, true);
    this.draw();
  }

  draw() {
    if (!this.hasInputTarget) return;
    const { value, selectionStart, selectionEnd } = this.inputTarget;
    const focused = document.activeElement === this.inputTarget;
    this.cellTargets.forEach((cell, index) => {
      const character = value[index];
      cell.textContent = character ?? '';
      cell.toggleAttribute('data-filled', character !== undefined);
      cell.toggleAttribute('data-caret', focused && selectionStart === selectionEnd && index === selectionStart);
      cell.toggleAttribute('data-selected', focused && index >= selectionStart && index < selectionEnd);
    });
  }
}
