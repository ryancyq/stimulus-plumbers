import { Application } from '@hotwired/stimulus';
import { vi } from 'vitest';

const applications = new Set();
const plumbers = new Set();

/**
 * Lets pending work settle: microtasks (Stimulus connects from a MutationObserver) and one macrotask.
 * Under fake timers it advances them by zero instead.
 */
export async function flush() {
  if (vi.isFakeTimers()) {
    await vi.advanceTimersByTimeAsync(0);
  } else {
    await new Promise((resolve) => setTimeout(resolve, 0));
  }
}

/** Advances fake timers by `ms`, running due timers and the promises they settle. */
export const advance = (ms) => vi.advanceTimersByTimeAsync(ms);

/**
 * Starts a Stimulus application with `controllers` (`{ identifier: ControllerClass }`) registered.
 * It stops after the test (tests/setup.js).
 */
export function startApplication(controllers) {
  const application = Application.start();
  applications.add(application);
  for (const [identifier, controller] of Object.entries(controllers)) {
    application.register(identifier, controller);
  }
  return application;
}

/**
 * Empties `items` and runs `dispose` on each one, even when an earlier one throws;
 * rethrows the first error afterwards.
 */
export function disposeAll(items, dispose) {
  const pending = [...items];
  items.clear();
  let failure = null;
  for (const item of pending) {
    try {
      dispose(item);
    } catch (error) {
      failure ??= error;
    }
  }
  if (failure) throw failure;
}

/** Stops every application started by `startApplication()`. */
export function stopApplications() {
  disposeAll(applications, (application) => application.stop());
}

/** Disconnects `plumber` after the test (tests/setup.js) and returns it. */
export function autoDisconnect(plumber) {
  plumbers.add(plumber);
  return plumber;
}

/** Disconnects every plumber passed to `autoDisconnect()`. */
export function disconnectPlumbers() {
  disposeAll(plumbers, (plumber) => plumber.disconnect());
}
