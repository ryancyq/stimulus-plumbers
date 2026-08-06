import { defineConfig, devices } from "@playwright/test";

const PORT = process.env.PORT || 4001;

export default defineConfig({
  testDir: "test/snapshots",
  snapshotDir: "test/snapshots/__screenshots__",
  // {testFilePath}, not {testFileName} — same-named specs in different dirs would collide.
  snapshotPathTemplate: "{snapshotDir}/{testFilePath}/{arg}-{projectName}-{platform}{ext}",

  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 3,

  use: {
    baseURL: `http://127.0.0.1:${PORT}`,
    animations: "disabled",
  },

  projects: [
    { name: "desktop", use: { channel: "chromium", viewport: { width: 1280, height: 800 } } },
    { name: "mobile",  use: { ...devices["Pixel 7"], channel: "chromium" } },
  ],

  webServer: {
    command: `RAILS_ENV=test bundle exec puma test/sandbox/config.ru --bind tcp://127.0.0.1:${PORT}`,
    url: `http://127.0.0.1:${PORT}/up`,
  },
});
