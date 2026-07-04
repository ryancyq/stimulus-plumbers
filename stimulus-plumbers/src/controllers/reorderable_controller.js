import { Controller } from '@hotwired/stimulus';
import { RovingTabIndex } from '../accessibility/keyboard';
import { setDisabled } from '../accessibility/aria';
import { attachReorderable } from '../plumbers';

export default class extends Controller {
  static targets = ['item', 'handle', 'trigger'];
  static values = {
    moveKey: { type: String, default: 'Alt' },
    editing: { type: Boolean, default: false },
    orientation: { type: String, default: 'vertical' },
  };

  connect() {
    this.reorderable = attachReorderable(this, {
      moveKey: this.moveKeyValue,
      orientation: this.orientationValue,
      onMoved: 'moved',
    });
    this.reorderable.attachItems(this.itemTargets);

    this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: this.orientationValue });
    this.rovingTabIndex.activate();
  }

  disconnect() {
    this.reorderable.detachItems(this.itemTargets);
    this.rovingTabIndex?.deactivate();
    this.rovingTabIndex = null;
  }

  itemTargetConnected(item) {
    this.reorderable?.attachItem(item);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  itemTargetDisconnected(item) {
    this.reorderable?.detachItem(item);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  editingValueChanged(value) {
    this.triggerTargets.forEach((trigger) => setDisabled(trigger, value));
  }

  toggleEditing() {
    this.editingValue = !this.editingValue;
  }

  enterEditing() {
    this.editingValue = true;
  }

  exitEditing() {
    this.editingValue = false;
  }

  onPointerDown(event) {
    if (!this.editingValue) return;
    const item = event.currentTarget.closest('[data-reorderable-target~="item"]');
    if (!item) return;
    this.reorderable.startDrag(item, event.currentTarget, event.pointerId);
  }

  onPointerMove(event) {
    if (!this.editingValue) return;
    this.reorderable.drag(event);
  }

  onPointerUp(event) {
    if (!this.editingValue) return;
    this.reorderable.endDrag(event.currentTarget, event.pointerId);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  moved(item) {
    this.rovingTabIndex?.updateItems(this.itemTargets);
    this.rovingTabIndex.setCurrentIndex(this.itemTargets.indexOf(item));
  }
}
