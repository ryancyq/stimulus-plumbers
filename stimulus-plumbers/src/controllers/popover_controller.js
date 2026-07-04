import { Controller } from '@hotwired/stimulus';
import { focusFirst } from '../accessibility/focus';
import { announce } from '../accessibility/aria';
import { attachContentLoader, attachDismisser, attachVisibility } from '../plumbers';

export default class extends Controller {
  static targets = ['trigger', 'panel', 'template', 'loader'];
  static values = {
    url: String,
    loadedAt: String,
    reload: { type: String, default: 'never' },
    staleAfter: { type: Number, default: 3600 },
    closeOnSelect: { type: Boolean, default: true },
    announceOpen: { type: String, default: 'Panel opened' },
    announceClose: { type: String, default: 'Panel closed' },
  };

  connect() {
    attachContentLoader(this, {
      element: this.hasPanelTarget ? this.panelTarget : null,
      url: this.hasUrlValue ? this.urlValue : null,
    });

    if (this.hasPanelTarget) {
      attachVisibility(this, {
        element: this.panelTarget,
        activator: this.hasTriggerTarget ? this.triggerTarget : null,
      });
      attachDismisser(this);
    }
    if (this.hasLoaderTarget)
      attachVisibility(this, { element: this.loaderTarget, visibility: 'contentLoaderVisibility' });
  }

  async dismissed() {
    await this.close();
  }

  async open() {
    if (!this.hasPanelTarget) return;
    await this.visibility.show();
  }

  async close() {
    if (!this.hasPanelTarget) return;
    await this.visibility.hide();
  }

  async toggle() {
    this.visibility?.visible ? await this.close() : await this.open();
  }

  async closeOnSelect() {
    if (this.closeOnSelectValue) await this.close();
  }

  async shown() {
    await this.load();
    if (this.hasPanelTarget) focusFirst(this.panelTarget);
    announce(this.announceOpenValue);
  }

  async hidden() {
    if (this.hasTriggerTarget) this.triggerTarget.focus();
    announce(this.announceCloseValue);
  }

  canLoad() {
    if (this.hasPanelTarget && this.panelTarget.tagName.toLowerCase() === 'turbo-frame') {
      if (this.hasUrlValue) this.panelTarget.setAttribute('src', this.urlValue);
      return false;
    }
    return true;
  }

  async contentLoading() {
    if (this.hasLoaderTarget) await this.contentLoaderVisibility.show();
  }

  async contentLoaded({ content }) {
    if (this.hasPanelTarget) {
      this.panelTarget.replaceChildren(this.getContentNode(content));
    }
    if (this.hasLoaderTarget) await this.contentLoaderVisibility.hide();
  }

  getContentNode(content) {
    if (typeof content === 'string') {
      const template = document.createElement('template');
      template.innerHTML = content;
      return document.importNode(template.content, true);
    }
    return document.importNode(content, true);
  }

  contentLoader() {
    if (!this.hasTemplateTarget) return;
    if (this.templateTarget instanceof HTMLTemplateElement) return this.templateTarget.content;

    return this.templateTarget.innerHTML;
  }
}
