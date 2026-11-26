import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { isFailedResponse, isFrameEvent } from '../../../../src/plumbers/plumber/turbo_frame';

describe('turbo frame helpers', () => {
  describe('isFrameEvent', () => {
    let frame;

    const eventOn = (target) => ({ target });

    beforeEach(() => {
      document.body.innerHTML = `
        <turbo-frame id="frame"><span id="inside"></span><turbo-frame id="nested"></turbo-frame></turbo-frame>
        <turbo-frame id="other"></turbo-frame>`;
      frame = document.querySelector('#frame');
    });

    afterEach(() => {
      document.body.innerHTML = '';
    });

    it('is true for an event from the frame itself', () => {
      expect(isFrameEvent(eventOn(frame), frame)).toBe(true);
    });

    it('is true for an event from an element inside the frame', () => {
      expect(isFrameEvent(eventOn(document.querySelector('#inside')), frame)).toBe(true);
    });

    it('is false for an event from a frame nested in the frame', () => {
      expect(isFrameEvent(eventOn(document.querySelector('#nested')), frame)).toBe(false);
    });

    it('is false for an event from a frame outside the frame', () => {
      expect(isFrameEvent(eventOn(document.querySelector('#other')), frame)).toBe(false);
    });

    it('is false without a frame', () => {
      expect(isFrameEvent(eventOn(document.body), null)).toBe(false);
    });

    it('is false for a target that is not an element', () => {
      expect(isFrameEvent(eventOn(window), frame)).toBe(false);
    });
  });

  describe('isFailedResponse', () => {
    const responseEvent = (fetchResponse) => ({ detail: { fetchResponse } });

    it('is true for a failed response', () => {
      expect(isFailedResponse(responseEvent({ succeeded: false, isHTML: true }))).toBe(true);
    });

    it('is true for a successful response that is not HTML', () => {
      expect(isFailedResponse(responseEvent({ succeeded: true, isHTML: false }))).toBe(true);
    });

    it('is true without a response', () => {
      expect(isFailedResponse(responseEvent(undefined))).toBe(true);
    });

    it('is true without a detail', () => {
      expect(isFailedResponse({})).toBe(true);
    });

    it('is false for a successful HTML response', () => {
      expect(isFailedResponse(responseEvent({ succeeded: true, isHTML: true }))).toBe(false);
    });
  });
});
