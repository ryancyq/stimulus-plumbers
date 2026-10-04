import { defineConfig } from "@playwright/test";
import base from "./playwright.base.js";

export default defineConfig({
  ...base,
  testDir: "test/snapshots",
  ignoreSnapshots: false,
  snapshotDir: "test/snapshots/__snapshots__",

  // {testFilePath}, not {testFileName} — same-named specs in different dirs would collide.
  projects: base.projects.map((p) => ({
    ...p,
    snapshotPathTemplate: `{snapshotDir}/${p.metadata.form}/${p.metadata.device}/{platform}/{testFilePath}/{arg}{ext}`,
  })),
});
