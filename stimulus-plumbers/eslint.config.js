import js from "@eslint/js";
import globals from "globals";

// Timer callees whose promise is a real-time sleep.
const timer = "/^(setTimeout|setInterval|setImmediate|requestAnimationFrame)$/";
const sleepMessage = "Real-timer sleeps make tests slow and flaky; wait with fake timers or a tests/support helper.";
const pollMessage = "vi.waitFor, vi.waitUntil, and expect.poll poll on real timers; await flush() or advance() and assert directly.";

export default [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.node,
        // Vitest globals
        describe: "readonly",
        it: "readonly",
        expect: "readonly",
        beforeEach: "readonly",
        afterEach: "readonly",
        beforeAll: "readonly",
        afterAll: "readonly",
        vi: "readonly",
      },
    },
    rules: {
      "no-console": ["warn", { allow: ["warn", "error"] }],
      "no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    },
  },
  {
    // Test layer rules (CLAUDE.md "Testing"); shared helpers in tests/support may do these things.
    files: ["tests/**/*.js"],
    ignores: ["tests/support/**"],
    rules: {
      "no-restricted-syntax": [
        "error",
        {
          selector: `NewExpression[callee.name='Promise'] :matches(CallExpression[callee.name=${timer}], CallExpression[callee.property.name=${timer}], CallExpression[callee.property.value=${timer}])`,
          message: sleepMessage,
        },
        {
          selector: `NewExpression[callee.name='Promise'][arguments.0.name=${timer}], NewExpression[callee.name='Promise'][arguments.0.property.name=${timer}], NewExpression[callee.name='Promise'][arguments.0.property.value=${timer}]`,
          message: sleepMessage,
        },
        {
          selector: `:matches(CallExpression[callee.name='promisify'], CallExpression[callee.property.name='promisify']):matches([arguments.0.name=${timer}], [arguments.0.property.name=${timer}], [arguments.0.property.value=${timer}])`,
          message: sleepMessage,
        },
        {
          selector: ":matches(ImportDeclaration, ImportExpression)[source.value=/^(node:)?timers.promises$/]",
          message: sleepMessage,
        },
        {
          selector:
            "CallExpression[callee.object.name='vi']:matches([callee.property.name=/^(waitFor|waitUntil)$/], [callee.property.value=/^(waitFor|waitUntil)$/])",
          message: pollMessage,
        },
        {
          selector:
            "VariableDeclarator[init.name='vi'] > ObjectPattern > Property:matches([key.name=/^(waitFor|waitUntil)$/], [key.value=/^(waitFor|waitUntil)$/])",
          message: pollMessage,
        },
        {
          selector: "CallExpression[callee.object.name='expect']:matches([callee.property.name='poll'], [callee.property.value='poll'])",
          message: pollMessage,
        },
        {
          selector: "CallExpression[callee.property.name='spyOn'][arguments.1.value=/^(add|remove)EventListener$/]",
          message: "Listener spies pin wiring; dispatch the event and assert its effect (or its absence after disconnect).",
        },
        {
          selector:
            "ImportDeclaration[source.value='@hotwired/stimulus'] > :matches(ImportSpecifier[imported.name='Application'], ImportNamespaceSpecifier)",
          message: "Start controllers with startApplication() from tests/support/stimulus so every test stops its application.",
        },
      ],
    },
  },
];
