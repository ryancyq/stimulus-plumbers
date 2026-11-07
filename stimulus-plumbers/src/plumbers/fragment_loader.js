const isElement = (element) => typeof HTMLElement !== 'undefined' && element instanceof HTMLElement;

const sameOrigin = (url) => {
  const resolved = new URL(url, window.location.href);
  if (resolved.origin !== window.location.origin) throw new Error(`${resolved.origin} is not the page origin`);
  return resolved;
};

/**
 * Fetches HTML and swaps in the response element whose id matches the target's.
 *
 * The response must be trusted, server-escaped HTML from the page origin; it is not sanitized.
 * The loader does not debounce, announce, or move focus.
 */
export class FragmentLoader {
  #element;
  #connected;
  #request;

  constructor(controller, options = {}) {
    this.#element = options.element;
    this.#connected = isElement(this.#element) && !!this.#element.id && this.#element !== controller.element;
    this.#request = null;
  }

  // The current target; each load replaces it.
  get element() {
    return this.#element;
  }

  get busy() {
    return this.#request !== null;
  }

  // Resolves to the swapped-in element, or null when cancelled or inert; rejects on a failed load.
  async load(url) {
    if (!this.#connected) return null;

    this.cancel();
    const target = sameOrigin(url);
    const request = new AbortController();
    const element = this.#element;
    this.#request = request;
    element.setAttribute('aria-busy', 'true');
    try {
      const response = await fetch(target, { headers: { Accept: 'text/html' }, signal: request.signal });
      if (!response.ok) throw new Error(`${response.status}`);

      const template = document.createElement('template');
      template.innerHTML = await response.text();
      if (request.signal.aborted) return null;

      const replacement = template.content.getElementById(element.id);
      if (!replacement) throw new Error(`Response has no #${element.id}`);

      element.replaceWith(replacement);
      this.#element = replacement;
      return replacement;
    } catch (error) {
      if (error.name === 'AbortError') return null;

      element.removeAttribute('aria-busy');
      throw error;
    } finally {
      if (this.#request === request) this.#request = null;
    }
  }

  cancel() {
    if (!this.#request) return;

    this.#request.abort();
    this.#request = null;
    this.#element?.removeAttribute('aria-busy');
  }

  disconnect() {
    this.cancel();
    this.#connected = false;
    this.#element = null;
  }
}

export const attachFragmentLoader = (controller, options) => new FragmentLoader(controller, options);
