import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { ContentLoader, attachContentLoader } from '../../../src/plumbers/content_loader'

describe('ContentLoader', () => {
  let mockController
  let element

  beforeEach(() => {
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'content-loader',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    element.getBoundingClientRect = () => ({ top: 100, left: 100, width: 200, height: 200 })

    global.fetch = vi.fn(async () => ({
      ok: true,
      text: () => Promise.resolve('<p>Loaded content</p>'),
    }))
  })

  afterEach(() => {
    vi.clearAllMocks()
    vi.restoreAllMocks()
  })

  describe('constructor', () => {
    it('initializes with default options', () => {
      const loader = new ContentLoader(mockController)

      expect(loader.controller).toBe(mockController)
      expect(loader.content).toBe(null)
      expect(loader.url).toBe('')
      expect(loader.reload).toBe('never')
      expect(loader.stale).toBe(3600)
      expect(loader.onLoad).toBe('canLoad')
      expect(loader.onLoaded).toBe('contentLoaded')
    })

    it('accepts custom url', () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      expect(loader.url).toBe('/api/content')
    })

    it('accepts custom reload option', () => {
      const loader = new ContentLoader(mockController, { reload: 'always' })
      expect(loader.reload).toBe('always')
    })

    it('accepts custom stale time', () => {
      const loader = new ContentLoader(mockController, { stale: 7200 })
      expect(loader.stale).toBe(7200)
    })

    it('accepts custom callbacks', () => {
      const loader = new ContentLoader(mockController, {
        onLoad: 'customLoad',
        onLoaded: 'customLoaded',
      })
      expect(loader.onLoad).toBe('customLoad')
      expect(loader.onLoaded).toBe('customLoaded')
    })

    it('enhances controller with load method', () => {
      new ContentLoader(mockController)
      expect(mockController.load).toBeTypeOf('function')
    })
  })

  describe('canLoad', () => {
    it('returns true when url is provided', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      expect(await loader.contentLoadable({ url: '/api/content' })).toBe(true)
    })

    it('returns false when url is empty', async () => {
      const loader = new ContentLoader(mockController, { url: '' })
      expect(await loader.contentLoadable({ url: '' })).toBe(false)
    })

    it('can be overridden for custom loading conditions', async () => {
      const loader = new ContentLoader(mockController, { url: '' })
      loader.canLoad = vi.fn(async () => true)
      const result = await loader.canLoad({ url: '' })
      expect(loader.canLoad).toHaveBeenCalled()
      expect(result).toBe(true)
    })
  })

  describe('remoteContentLoader', () => {
    it('fetches content from url', async () => {
      const loader = new ContentLoader(mockController)
      const content = await loader.remoteContentLoader('/api/content')
      expect(global.fetch).toHaveBeenCalledWith('/api/content', expect.objectContaining({ signal: expect.any(AbortSignal) }))
      expect(content).toBe('<p>Loaded content</p>')
    })
  })

  describe('contentLoader', () => {
    it('returns empty string by default', async () => {
      const loader = new ContentLoader(mockController)
      const content = await loader.contentLoader()
      expect(content).toBe('')
    })

    it('can be overridden to provide static content', async () => {
      const loader = new ContentLoader(mockController)
      loader.contentLoader = vi.fn(async () => '<p>Static content</p>')
      const content = await loader.contentLoader()
      expect(content).toBe('<p>Static content</p>')
    })
  })

  describe('reloadable', () => {
    it('returns false when reload is "never"', () => {
      const loader = new ContentLoader(mockController, { reload: 'never' })
      expect(loader.reloadable).toBe(false)
    })

    it('returns true when reload is "always"', () => {
      const loader = new ContentLoader(mockController, { reload: 'always' })
      expect(loader.reloadable).toBe(true)
    })

    it('returns false when no loadedAt timestamp exists', () => {
      const loader = new ContentLoader(mockController, { reload: 'stale' })
      expect(loader.reloadable).toBeFalsy()
    })

    it('returns false when content is fresh (within stale time)', () => {
      const loader = new ContentLoader(mockController, { reload: 'stale', stale: 3600 })
      loader.loadedAt = Date.now()
      expect(loader.reloadable).toBe(false)
    })

    it('returns true when content is stale (beyond stale time)', () => {
      const loader = new ContentLoader(mockController, { reload: 'stale', stale: 1 })
      loader.loadedAt = Date.now() - 2000
      expect(loader.reloadable).toBe(true)
    })
  })

  describe('load', () => {
    it('does nothing when onLoad returns false', async () => {
      const loader = new ContentLoader(mockController, { url: '' })
      await loader.load()
      expect(mockController.dispatch).toHaveBeenCalledWith('load', expect.any(Object))
      expect(mockController.dispatch).not.toHaveBeenCalledWith('loading', expect.any(Object))
      expect(global.fetch).not.toHaveBeenCalled()
    })

    it('does nothing when already loaded and reload is "never"', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content', reload: 'never' })
      loader.loadedAt = Date.now()
      await loader.load()
      expect(global.fetch).not.toHaveBeenCalled()
    })

    it('dispatches load, loading, and loaded events', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      await loader.load()
      expect(mockController.dispatch).toHaveBeenCalledWith('load', expect.objectContaining({ detail: { url: '/api/content' } }))
      expect(mockController.dispatch).toHaveBeenCalledWith('loading', expect.objectContaining({ detail: { url: '/api/content' } }))
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.objectContaining({
        detail: expect.objectContaining({ url: '/api/content', content: '<p>Loaded content</p>' }),
      }))
    })

    it('fetches content from url', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      await loader.load()
      expect(global.fetch).toHaveBeenCalledWith('/api/content', expect.objectContaining({ signal: expect.any(AbortSignal) }))
    })

    it('calls canLoad to check if loadable', async () => {
      const contentLoad = vi.fn(async () => true)
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      loader.canLoad = contentLoad
      await loader.load()
      expect(contentLoad).toHaveBeenCalledWith({ url: '/api/content' })
    })

    it('calls remoteContentLoader to fetch content from url', async () => {
      const remoteContentLoader = vi.fn(async () => '<p>Custom content</p>')
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      loader.remoteContentLoader = remoteContentLoader
      await loader.load()
      expect(remoteContentLoader).toHaveBeenCalledWith('/api/content')
    })

    it('dispatches loaded event with content after fetching', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      await loader.load()
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.objectContaining({
        detail: expect.objectContaining({ url: '/api/content', content: '<p>Loaded content</p>' }),
      }))
    })

    it('sets loadedAt timestamp after loading', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      const before = Date.now()
      await loader.load()
      const after = Date.now()
      expect(loader.loadedAt).toBeGreaterThanOrEqual(before)
      expect(loader.loadedAt).toBeLessThanOrEqual(after)
    })

    it('uses contentLoader when no url provided', async () => {
      const loader = new ContentLoader(mockController, { url: '' })
      loader.canLoad = vi.fn(async () => true)
      loader.contentLoader = vi.fn(async () => '<p>Static content</p>')
      await loader.load()
      expect(loader.contentLoader).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.objectContaining({
        detail: expect.objectContaining({ url: '', content: '<p>Static content</p>' }),
      }))
    })

    it('does nothing when content is empty', async () => {
      global.fetch = vi.fn(async () => ({ ok: true, text: () => Promise.resolve('') }))
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      await loader.load()
      expect(mockController.dispatch).toHaveBeenCalledWith('load', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('loading', expect.any(Object))
      expect(mockController.dispatch).not.toHaveBeenCalledWith('loaded', expect.any(Object))
    })

    it('reloads when reload is "always"', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content', reload: 'always' })
      loader.loadedAt = Date.now()
      await loader.load()
      expect(global.fetch).toHaveBeenCalledOnce()
    })

    it('awaits async canLoad callback', async () => {
      const contentLoad = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 10))
        return true
      })
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      loader.canLoad = contentLoad
      await loader.load()
      expect(contentLoad).toHaveBeenCalled()
      expect(global.fetch).toHaveBeenCalled()
    })

    it('can override contentLoaded callback on loader instance', async () => {
      const loader = new ContentLoader(mockController, { url: '/api/content' })
      const contentLoadedSpy = vi.fn()
      loader.contentLoaded = contentLoadedSpy
      await loader.load()
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.any(Object))
    })
  })

  describe('enhance', () => {
    it('adds load method to controller', () => {
      new ContentLoader(mockController)
      expect(mockController.load).toBeDefined()
      expect(typeof mockController.load).toBe('function')
    })
  })

  describe('attachContentLoader', () => {
    it('creates and returns a ContentLoader instance', () => {
      const loader = attachContentLoader(mockController, { url: '/api/content' })
      expect(loader).toBeInstanceOf(ContentLoader)
      expect(loader.url).toBe('/api/content')
    })
  })
})
