import { beforeEach, afterEach, vi } from 'vitest';
import WindowObserver from '../src/plumbers/plumber/window_observer';
import { disconnectPlumbers, disposeAll, stopApplications } from './support/stimulus';

// Records every window observer a test starts; the record lives outside the mock registry.
const windowObservers = new Set();
const observe = WindowObserver.prototype.observe;
WindowObserver.prototype.observe = function (handler) {
  windowObservers.add(this);
  return observe.call(this, handler);
};

// Mock window.matchMedia
beforeEach(() => {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });

  // Set default viewport dimensions
  Object.defineProperty(window, 'innerWidth', {
    writable: true,
    configurable: true,
    value: 1024,
  });

  Object.defineProperty(window, 'innerHeight', {
    writable: true,
    configurable: true,
    value: 768,
  });

  Object.defineProperty(document.documentElement, 'clientWidth', {
    writable: true,
    configurable: true,
    value: 1024,
  });

  Object.defineProperty(document.documentElement, 'clientHeight', {
    writable: true,
    configurable: true,
    value: 768,
  });
});

// Clean up after each test; every step runs even when an earlier one throws.
afterEach(() => {
  const steps = new Set([
    stopApplications,
    disconnectPlumbers,
    () => disposeAll(windowObservers, (observer) => observer.disconnect()),
    () => (document.body.innerHTML = ''),
    () => vi.clearAllMocks(),
    () => vi.useRealTimers(),
  ]);
  disposeAll(steps, (step) => step());
});
