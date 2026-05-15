export class Requestor {
  constructor() {
    this._abortController = null;
    this._timer = null;
  }

  schedule(fn, delay) {
    clearTimeout(this._timer);
    this._timer = setTimeout(fn, delay);
  }

  async request(url, options = {}) {
    this._abortController?.abort();
    this._abortController = new AbortController();
    const res = await fetch(url, { ...options, signal: this._abortController.signal });
    if (!res.ok) throw new Error(`${res.status}`);
    return res;
  }

  cancel() {
    clearTimeout(this._timer);
    this._abortController?.abort();
  }
}
