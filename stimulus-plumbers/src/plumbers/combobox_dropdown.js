import Plumber from './plumber';

export class ComboboxDropdown extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);
    this.debounceTimer = null;
    this.abortController = null;
  }

  fuzzyFilter(listbox, query) {
    const needle = query.toLowerCase();
    let visible = 0;
    listbox.querySelectorAll('[role="option"]').forEach((opt) => {
      const match = this.fuzzyMatch(needle, opt.textContent.trim().toLowerCase());
      opt.hidden = !match;
      if (match) visible++;
    });
    return visible;
  }

  fuzzyMatch(needle, haystack) {
    let ni = 0;
    for (let i = 0; i < haystack.length && ni < needle.length; i++) {
      if (haystack[i] === needle[ni]) ni++;
    }
    return ni === needle.length;
  }

  scheduleFetch(query, delay, callback) {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => this.fetch(query, callback), delay);
  }

  async fetch(query, { url, field, onLoading, onLoaded, onError }) {
    this.abortController?.abort();
    this.abortController = new AbortController();
    onLoading?.(true);
    const fetchUrl = new URL(url, window.location.href);
    fetchUrl.searchParams.set(field, query);
    try {
      const res = await fetch(fetchUrl, {
        signal: this.abortController.signal,
        headers: { Accept: 'text/html', 'X-Requested-With': 'XMLHttpRequest' },
      });
      if (!res.ok) throw new Error(`${res.status}`);
      onLoaded?.(await res.text());
    } catch (err) {
      if (err.name !== 'AbortError') onError?.(err);
    } finally {
      onLoading?.(false);
    }
  }

  cancel() {
    clearTimeout(this.debounceTimer);
    this.abortController?.abort();
  }
}

export const initComboboxDropdown = (controller, options) => new ComboboxDropdown(controller, options);
