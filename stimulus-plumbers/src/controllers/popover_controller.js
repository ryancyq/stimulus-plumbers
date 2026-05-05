import { Controller } from '@hotwired/stimulus';
import { attachContentLoader, attachVisibility } from '../plumbers';

export default class extends Controller {
  static targets = ['content', 'template', 'loader', 'activator'];
  static classes = ['hidden'];
  static values = {
    url: String,
    loadedAt: String,
    reload: { type: String, default: 'never' },
    staleAfter: { type: Number, default: 3600 },
  };

  connect() {
    attachContentLoader(this, {
      element: this.hasContentTarget ? this.contentTarget : null,
      url: this.hasUrlValue ? this.urlValue : null,
    });

    if (this.hasContentTarget) {
      attachVisibility(this, {
        element: this.contentTarget,
        activator: this.hasActivatorTarget ? this.activatorTarget : null,
      });
    }
    if (this.hasLoaderTarget)
      attachVisibility(this, { element: this.loaderTarget, visibility: 'contentLoaderVisibility' });
  }

  async show() {
    await this.visibility.show();
  }

  async hide() {
    await this.visibility.hide();
  }

  async shown() {
    await this.load();
  }

  canLoad() {
    if (this.hasContentTarget && this.contentTarget.tagName.toLowerCase() === 'turbo-frame') {
      if (this.hasUrlValue) this.contentTarget.setAttribute('src', this.urlValue);
      return false;
    }
    return true;
  }

  async contentLoading() {
    if (this.hasLoaderTarget) await this.contentLoaderVisibility.show();
  }

  async contentLoaded({ content }) {
    if (this.hasContentTarget) {
      this.contentTarget.replaceChildren(this.getContentNode(content));
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
