import Plumber from './plumber';
import { tryParseDate } from './plumber/date';
import { Requestor } from '../requestor';

const defaultOptions = {
  content: null,
  url: '',
  reload: 'never',
  stale: 3600,
  onLoad: 'canLoad',
  onLoaded: 'contentLoaded',
};

export class ContentLoader extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);

    const config = Object.assign({}, defaultOptions, options);
    const { content, url, reload, stale } = config;
    this.content = content;
    this.url = url;
    this.reload = typeof reload === 'string' ? reload : defaultOptions.reload;
    this.stale = typeof stale === 'number' ? stale : defaultOptions.stale;

    const { onLoad, onLoaded } = config;
    this.onLoad = onLoad;
    this.onLoaded = onLoaded;

    this._requestor = new Requestor();
    this.enhance();
  }

  get reloadable() {
    switch (this.reload) {
      case 'never':
        return false;
      case 'always':
        return true;
      default: {
        const loadedAt = tryParseDate(this.loadedAt);
        return loadedAt && new Date() - loadedAt > this.stale * 1000;
      }
    }
  }

  contentLoadable = ({ url }) => !!url;

  contentLoader = async () => '';

  remoteContentLoader = async (url) => {
    const res = await this._requestor.request(url);
    return res.text();
  };

  load = async () => {
    if (this.loadedAt && !this.reloadable) return;

    const loadableCallback = this.findCallback(this.onLoad);
    const loadable = await this.awaitCallback(loadableCallback || this.contentLoadable, { url: this.url });
    this.dispatch('load', { detail: { url: this.url } });
    if (!loadable) return;

    this.dispatch('loading', { detail: { url: this.url } });
    const content = this.url ? await this.remoteContentLoader(this.url) : await this.contentLoader();
    if (!content) return;

    await this.awaitCallback(this.onLoaded, { url: this.url, content });
    this.loadedAt = new Date().getTime();
    this.dispatch('loaded', { detail: { url: this.url, content } });
  };

  enhance() {
    const context = this;
    Object.assign(this.controller, {
      load: context.load.bind(context),
    });
  }
}

export const attachContentLoader = (controller, options) => new ContentLoader(controller, options);
