import { describe, it, expect, beforeEach } from 'vitest';
import InputCodeController from '../../../src/controllers/input_code_controller';
import InputFormatterController from '../../../src/controllers/input_formatter_controller';
import { flush, startApplication } from '../../support/stimulus';

describe('InputCodeController', () => {
  beforeEach(async () => {
    startApplication({ 'input-code': InputCodeController, 'input-formatter': InputFormatterController });
    document.body.innerHTML = `
      <div data-controller="input-formatter input-code"
           data-input-formatter-format-value="code"
           data-input-formatter-options-value='{"charset":"digits","length":6}'
           data-action="input-formatter:formatted->input-code#draw">
        <div class="cells">${'<span data-input-code-target="cell"></span>'.repeat(6)}</div>
        <input data-input-formatter-target="input" data-input-code-target="input"
               data-action="input->input-formatter#onInput focus->input-code#draw blur->input-code#draw selectionchange->input-code#draw click->input-code#onClick" />
      </div>
    `;
    await flush();
  });

  const cells = () => [...document.querySelectorAll('[data-input-code-target="cell"]')];
  const input = () => document.querySelector('input');
  const marked = (attribute) => cells().map((cell) => cell.hasAttribute(attribute));

  const type = (value, caret = value.length) => {
    input().value = value;
    input().setSelectionRange(caret, caret);
    input().dispatchEvent(new Event('input', { bubbles: true }));
  };

  const select = (start, end) => {
    input().setSelectionRange(start, end);
    input().dispatchEvent(new Event('selectionchange'));
  };

  it('hides the cells from assistive technology', () => {
    cells().forEach((cell) => expect(cell.getAttribute('aria-hidden')).toBe('true'));
  });

  it('draws each character of the value in its own cell', () => {
    type('482');

    expect(cells().map((cell) => cell.textContent)).toEqual(['4', '8', '2', '', '', '']);
    expect(marked('data-filled')).toEqual([true, true, true, false, false, false]);
  });

  it('draws the caret on the next empty cell only while focused', () => {
    input().focus();
    type('48');

    expect(marked('data-caret')).toEqual([false, false, true, false, false, false]);

    input().blur();

    expect(marked('data-caret')).toEqual([false, false, false, false, false, false]);
  });

  it('draws the caret where the input caret moves', () => {
    input().focus();
    type('482913');

    select(2, 2);

    expect(marked('data-caret')).toEqual([false, false, true, false, false, false]);
  });

  it('draws the caret after a character inserted mid-code', () => {
    input().focus();

    type('48213', 3);

    expect(marked('data-caret')).toEqual([false, false, false, true, false, false]);
  });

  it('marks the selected cells and draws no caret', () => {
    input().focus();
    type('482913');

    select(1, 3);

    expect(marked('data-selected')).toEqual([false, true, true, false, false, false]);
    expect(marked('data-caret')).toEqual([false, false, false, false, false, false]);
  });

  describe('clicking', () => {
    beforeEach(() => {
      cells().forEach((cell, index) => {
        cell.getBoundingClientRect = () => ({ left: index * 40, right: index * 40 + 36 });
      });
      input().focus();
    });

    const clickAt = (clientX) => input().dispatchEvent(new MouseEvent('click', { clientX, bubbles: true }));

    it('puts the caret before the clicked cell', () => {
      type('482913');

      clickAt(85);

      expect(input().selectionStart).toBe(2);
      expect(marked('data-caret')).toEqual([false, false, true, false, false, false]);
    });

    it('puts the caret after the value when an empty cell is clicked', () => {
      type('48');

      clickAt(165);

      expect(input().selectionStart).toBe(2);
    });

    it('keeps a selection the click made', () => {
      type('482913');
      input().setSelectionRange(0, 6);

      clickAt(85);

      expect(input().selectionEnd).toBe(6);
    });
  });

  it('draws the value into a cell added after connect', async () => {
    type('4829');
    const cell = document.createElement('span');
    cell.setAttribute('data-input-code-target', 'cell');
    cells()[3].replaceWith(cell);
    await flush();

    expect(cell.textContent).toBe('9');
    expect(cell.getAttribute('aria-hidden')).toBe('true');
  });
});
