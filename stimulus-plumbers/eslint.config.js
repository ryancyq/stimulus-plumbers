import js from "@eslint/js";
import globals from "globals";

// Timer callees whose promise is a real-time sleep.
const timer = "/^(setTimeout|setInterval|setImmediate|requestAnimationFrame)$/";
const sleepMessage = "Real-timer sleeps make tests slow and flaky; wait with fake timers or a tests/support helper.";

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
