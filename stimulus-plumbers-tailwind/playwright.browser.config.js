import { defineConfig } from "@playwright/test";
import base from "./playwright.base.js";

// Engine-native behavior: native dialog, Popover API, CSS anchor positioning.
export default defineConfig({
  ...base,
  testDir: "test/browser",
});
