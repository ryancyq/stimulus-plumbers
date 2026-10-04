import { defineConfig, devices } from "@playwright/test";
import base from "./playwright.config.js";

// Engine-native behavior (dialog, popover, anchor positioning) that jsdom and Chrome-only suites can't cover.
export default defineConfig({
  ...base,
  testDir: "test/browser",

  projects: [
    { name: "desktop", use: { channel: "chromium", viewport: { width: 1280, height: 800 } } },
    { name: "mobile",  use: { ...devices["Pixel 7"], channel: "chromium" } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit",  use: { ...devices["Desktop Safari"] } },
  ],
});
