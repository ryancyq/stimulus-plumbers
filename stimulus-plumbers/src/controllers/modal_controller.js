import { Controller } from '@hotwired/stimulus';
import { FocusTrap } from '../accessibility/focus';
import { announce } from '../accessibility/aria';
import { attachDismisser } from '../plumbers';

export default class extends Controller {
  static targets = ['modal', 'overlay'];

  initialize() {
    this.onCancel = this.close.bind(this);
  }

  connect() {
    if (!this.hasModalTarget) {
      console.error('ModalController requires a modal target. Add data-modal-target="modal" to your element.');
    }
  }

  modalTargetConnected(modal) {
    this.isNativeDialog = modal instanceof HTMLDialogElement;
    if (this.isNativeDialog) {
      modal.addEventListener('cancel', this.onCancel);
      modal.addEventListener('click', this.onBackdropClick);
    } else {
      this.focusTrap = new FocusTrap(modal, { escapeDeactivates: true });
      attachDismisser(this, { element: modal });
    }
  }

  modalTargetDisconnected(modal) {
    if (this.isNativeDialog) {
      modal.removeEventListener('cancel', this.onCancel);
      modal.removeEventListener('click', this.onBackdropClick);
    }
  }

  dismissed = () => {
    this.close();
  };

  open(event) {
    if (event) event.preventDefault();
    if (!this.hasModalTarget) return;

    if (this.isNativeDialog) {
      this.previouslyFocused = document.activeElement;
      this.modalTarget.showModal();
    } else {
      const targetToShow = this.hasOverlayTarget ? this.overlayTarget : this.modalTarget;
      targetToShow.hidden = false;

      document.body.style.overflow = 'hidden';

      if (this.focusTrap) {
        this.focusTrap.activate();
      }
    }

    announce('Modal opened');
  }

  close(event) {
    if (event) event.preventDefault();
    if (!this.hasModalTarget) return;

    if (this.isNativeDialog) {
      this.modalTarget.close();

      if (this.previouslyFocused && this.previouslyFocused.isConnected) {
        setTimeout(() => {
          this.previouslyFocused.focus();
        }, 0);
      }
    } else {
      const targetToHide = this.hasOverlayTarget ? this.overlayTarget : this.modalTarget;
      targetToHide.hidden = true;

      document.body.style.overflow = '';

      if (this.focusTrap) {
        this.focusTrap.deactivate();
      }
    }

    announce('Modal closed');
  }

  onBackdropClick = (event) => {
    const rect = this.modalTarget.getBoundingClientRect();
    const isOutsideDialog =
      event.clientY < rect.top ||
      event.clientY > rect.bottom ||
      event.clientX < rect.left ||
      event.clientX > rect.right;

    if (isOutsideDialog) {
      this.close();
    }
  };
}
