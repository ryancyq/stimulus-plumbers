import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import InputFormatterController from '../../../src/controllers/input_formatter_controller';
import ClipboardController from '../../../src/controllers/clipboard_controller';
import { flush, startApplication } from '../../support/stimulus';

describe('InputFormatterController', () => {
  let application;

  beforeEach(() => {
    application = startApplication({ 'input-formatter': InputFormatterController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-formatter"]'),
      'input-formatter'
    );

  describe('plain type (default) — non-input display target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter">
          <output data-input-formatter-target="input">hello</output>
        </div>
      `;
      await flush();
    });

    it('attaches formatter on connect', () => {
      expect(getController().formatter).toBeDefined();
    });

    it('renders existing textContent as the formatted value', () => {
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('hello');
    });

    it('format(value) writes formatted value to the input target', async () => {
      getController().format('world');
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('world');
    });

    it('onChange(event) writes event.detail.value to the input target', () => {
      getController().onChange({ detail: { value: 'world' } });
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('world');
    });

    it('dispatches input-formatter:formatted after writing', () => {
      const el = document.querySelector('[data-controller="input-formatter"]');
      const spy = vi.fn();
      el.addEventListener('input-formatter:formatted', spy);
      getController().format('x');
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail.value).toBe('x');
    });
  });

  describe('plain type — <input> display target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter">
          <input type="text" value="initial" data-input-formatter-target="input">
        </div>
      `;
      await flush();
    });

    it('reads existing .value on connect and writes it back formatted', () => {
      expect(document.querySelector('[data-input-formatter-target="input"]').value).toBe('initial');
    });

    it('format(value) writes to .value on <input> targets', () => {
      getController().format('updated');
      expect(document.querySelector('[data-input-formatter-target="input"]').value).toBe('updated');
    });
  });

  describe('creditCard type', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <output data-input-formatter-target="input">4242424242424242</output>
        </div>
      `;
      await flush();
    });

    it('formats the initial value on connect', () => {
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('4242 4242 4242 4242');
    });
  });

  describe('caret after reformatting', () => {
    let input;

    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <input type="text" data-input-formatter-target="input" data-action="input->input-formatter#onInput">
        </div>
      `;
      await flush();
      input = document.querySelector('input');
      input.focus();
    });

    const type = (value, caret) => {
      input.value = value;
      input.setSelectionRange(caret, caret);
      input.dispatchEvent(new Event('input', { bubbles: true }));
    };

    it('stays after a digit inserted mid-number', () => {
      type('42142 4242', 3);

      expect(input.value).toBe('4214 2424 2');
      expect(input.selectionStart).toBe(3);
    });

    it('moves past a separator the reformat inserts', () => {
      type('42421 4242', 5);

      expect(input.value).toBe('4242 1424 2');
      expect(input.selectionStart).toBe(6);
    });
  });

  describe('typing at the cap', () => {
    const mount = async (format, options, value) => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="${format}"
             data-input-formatter-options-value='${options}'>
          <input value="${value}" data-input-formatter-target="input"
                 data-action="input->input-formatter#onInput beforeinput->input-formatter#onBeforeinput">
        </div>
      `;
      await flush();
      document.querySelector('input').focus();
    };

    const input = () => document.querySelector('input');

    const typeAt = (caret, data) => {
      input().setSelectionRange(caret, caret);
      const event = new InputEvent('beforeinput', { inputType: 'insertText', data, bubbles: true, cancelable: true });
      input().dispatchEvent(event);
      return event;
    };

    it('replaces the code character after the caret', async () => {
      await mount('code', '{"charset":"digits","length":6}', '482913');

      const event = typeAt(2, '7');

      expect(event.defaultPrevented).toBe(true);
      expect(input().value).toBe('487913');
      expect(input().selectionStart).toBe(3);
    });

    it('leaves a character typed below the cap to the browser', async () => {
      await mount('code', '{"charset":"digits","length":6}', '4829');

      expect(typeAt(2, '7').defaultPrevented).toBe(false);
    });

    it('leaves a character the formatter drops to the browser', async () => {
      await mount('code', '{"charset":"digits","length":6}', '482913');

      expect(typeAt(2, 'a').defaultPrevented).toBe(false);
    });

    it('ignores a character typed after a full code', async () => {
      await mount('code', '{"charset":"digits","length":6}', '482913');

      expect(typeAt(6, '7').defaultPrevented).toBe(true);
      expect(input().value).toBe('482913');
    });

    it('lets a 16-digit card number grow toward 19 digits', async () => {
      await mount('creditCard', '{}', '4242 4242 4242 4242');

      expect(typeAt(2, '7').defaultPrevented).toBe(false);
    });

    it('replaces the Amex digit after the caret, past its separators', async () => {
      await mount('creditCard', '{}', '3782 822463 10005');

      typeAt(5, '9');

      expect(input().value).toBe('3782 922463 10005');
      expect(input().selectionStart).toBe(6);
    });
  });

  describe('without an input target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `<div data-controller="input-formatter"></div>`;
      await flush();
    });

    it('dispatches formatted event even with no input target', () => {
      const el = document.querySelector('[data-controller="input-formatter"]');
      const spy = vi.fn();
      el.addEventListener('input-formatter:formatted', spy);
      getController().format('test');
      expect(spy).toHaveBeenCalledTimes(1);
    });

    it('does not throw when no input target', () => {
      expect(() => getController().format('test')).not.toThrow();
    });
  });

  describe('formatValueChanged', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="plain">
          <output data-input-formatter-target="input">4242424242424242</output>
        </div>
      `;
      await flush();
    });

    it('re-attaches the formatter when typeValue changes', async () => {
      const el = document.querySelector('[data-controller="input-formatter"]');
      el.setAttribute('data-input-formatter-format-value', 'creditCard');
      await flush();
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('4242 4242 4242 4242');
    });
  });

  describe('optionsValueChanged', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="currency"
             data-input-formatter-options-value='{"currency":"USD"}'>
          <output data-input-formatter-target="input">1234.56</output>
        </div>
      `;
      await flush();
    });

    it('re-formats when optionsValue changes', async () => {
      const el = document.querySelector('[data-controller="input-formatter"]');
      el.setAttribute('data-input-formatter-options-value', JSON.stringify({ currency: 'EUR', locale: 'de-DE' }));
      await flush();
      const text = document.querySelector('[data-input-formatter-target="input"]').textContent;
      expect(text).toContain('1');
      expect(text.length).toBeGreaterThan(0);
    });
  });

  describe('onPaste', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <output data-input-formatter-target="input"></output>
        </div>
      `;
      await flush();
    });

    const pasted = (text) => new CustomEvent('clipboard:pasted', { detail: { text }, cancelable: true });

    it('normalizes and formats a valid pasted value', () => {
      getController().onPaste(pasted('4242424242424242'));
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('4242 4242 4242 4242');
    });

    it('does not write when the normalized value fails validation', () => {
      const output = document.querySelector('[data-input-formatter-target="input"]');
      output.textContent = 'original';
      getController().onPaste(pasted('not-a-card'));
      expect(output.textContent).toBe('original');
    });

    it('does not write when pasted text is empty', () => {
      const output = document.querySelector('[data-input-formatter-target="input"]');
      output.textContent = 'original';
      getController().onPaste(pasted(''));
      expect(output.textContent).toBe('original');
    });

    it('does not throw when there is no formatter', async () => {
      document.body.innerHTML = `<div data-controller="input-formatter"></div>`;
      await flush();
      expect(() => getController().onPaste(pasted('4242424242424242'))).not.toThrow();
    });

    describe('with the clipboard controller', () => {
      beforeEach(async () => {
        application.register('clipboard', ClipboardController);
        document.body.innerHTML = `
          <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
            <input data-input-formatter-target="input"
                   data-controller="clipboard"
                   data-action="paste->clipboard#onPaste clipboard:pasted->input-formatter#onPaste">
          </div>
        `;
        await flush();
      });

      const paste = (text) => {
        const event = new Event('paste', { bubbles: true, cancelable: true });
        Object.defineProperty(event, 'clipboardData', { value: { getData: () => text, types: ['text/plain'] } });
        document.querySelector('input').dispatchEvent(event);
        return event;
      };

      it('replaces the native paste with a formatted full card number', () => {
        const event = paste('4242424242424242');

        expect(event.defaultPrevented).toBe(true);
        expect(document.querySelector('input').value).toBe('4242 4242 4242 4242');
      });

      it('lets a partial card number paste natively', () => {
        const event = paste('4242 4242');

        expect(event.defaultPrevented).toBe(false);
      });
    });
  });

  describe('code type', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter"
             data-input-formatter-format-value="code"
             data-input-formatter-options-value='{"charset":"digits","length":6}'>
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `;
      await flush();
    });

    const input = () => document.querySelector('[data-input-formatter-target="input"]');

    it('reformats the restored value after a form reset without dispatching filled', async () => {
      document.body.innerHTML = `
        <form>
          <div data-controller="input-formatter"
               data-input-formatter-format-value="code"
               data-input-formatter-options-value='{"charset":"digits","length":6}'>
            <input value="123456" data-input-formatter-target="input"
                   data-action="input->input-formatter#onInput form:reset->input-formatter#onFormReset" />
          </div>
        </form>
      `;
      await flush();
      input().value = '48';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      const filled = vi.fn();
      document.addEventListener('input-formatter:filled', filled);

      document.querySelector('form').reset();
      input().dispatchEvent(new CustomEvent('form:reset'));
      document.removeEventListener('input-formatter:filled', filled);

      expect(input().value).toBe('123456');
      expect(filled).not.toHaveBeenCalled();
    });

    it('filters non-charset characters and writes back to the input', () => {
      input().value = '4 8-29 13';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(input().value).toBe('482913');
    });

    it('keeps the first length characters of a longer paste', () => {
      input().value = '4829137';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(input().value).toBe('482913');
    });

    it('dispatches input-formatter:filled at configured length', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '482913';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail).toEqual({ value: '482913' });
    });

    it('does not dispatch filled below configured length', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '4829';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).not.toHaveBeenCalled();
    });

    it('does not dispatch filled again when a 7th char is typed and truncated back to the same 6 chars', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '482913';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
      input().value = '4829137';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
    });

    it('fires filled again after the value drops below length and is refilled', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '482913';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
      input().value = '48291';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      input().value = '482913';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(2);
    });
  });

  describe('filled dispatch on connect with a prefilled value', () => {
    it('does not dispatch filled on connect even when the initial value is already full', async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter"
             data-input-formatter-format-value="code"
             data-input-formatter-options-value='{"charset":"digits","length":6}'>
          <input data-input-formatter-target="input" value="482913"
                 data-action="input->input-formatter#onInput" />
        </div>
      `;
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      await flush();
      expect(spy).not.toHaveBeenCalled();
    });
  });

  describe('filled dispatch generalizes beyond the code formatter', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `;
      await flush();
    });

    const input = () => document.querySelector('[data-input-formatter-target="input"]');

    it('dispatches filled for a valid creditCard value at its filled length', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '4242424242424242';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail).toEqual({ value: '4242424242424242' });
    });

    it('dispatches filled for a valid 15-digit Amex number', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '378282246310005';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
    });
  });

  describe('creditCard type with groups', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard"
             data-input-formatter-options-value='{"groups":[4,4,4,4,3]}'>
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `;
      await flush();
    });

    const input = () => document.querySelector('[data-input-formatter-target="input"]');

    it('groups the input value at the given breaks', () => {
      input().value = '1234567890123456785';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(input().value).toBe('1234 5678 9012 3456 785');
    });

    it('dispatches filled once the full 19-digit valid number is entered', () => {
      const spy = vi.fn();
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy);
      input().value = '1234567890123456785';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      expect(spy).toHaveBeenCalledTimes(1);
    });

    it('regroups the input value when the groups change', async () => {
      input().value = '378282246310005';
      input().dispatchEvent(new Event('input', { bubbles: true }));
      document
        .querySelector('[data-controller="input-formatter"]')
        .setAttribute('data-input-formatter-options-value', '{"groups":[3,3,3,3,3]}');
      await flush();
      expect(input().value).toBe('378 282 246 310 005');
    });
  });
});
