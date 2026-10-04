import { defineConfig, devices } from "@playwright/test";

const PORT = process.env.PORT || 4001;

// metadata.form + metadata.device name the snapshot folders.
const project = (form, device, use) => ({
  name: device.startsWith(form) ? device : `${form}-${device}`,
  metadata: { form, device },
  use,
});

// One desktop viewport so engines are the only variable; mobile keeps each device's own.
const desktop = { viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 };

export default defineConfig({
  ignoreSnapshots: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 3,

  use: {
    baseURL: `http://127.0.0.1:${PORT}`,
    animations: "disabled",
  },

  projects: [
    project("desktop", "desktop-chrome", { ...devices["Desktop Chrome"], channel: "chromium", ...desktop }),
    project("desktop", "desktop-firefox", { ...devices["Desktop Firefox"], ...desktop }),
    project("desktop", "desktop-safari", { ...devices["Desktop Safari"], ...desktop }),
    project("mobile", "pixel-10", { ...devices["Pixel 10"], channel: "chromium" }),
    project("mobile", "iphone-17", devices["iPhone 17"]),
  ],

  webServer: {
    command: `RAILS_ENV=test bundle exec puma test/sandbox/config.ru --bind tcp://127.0.0.1:${PORT}`,
    url: `http://127.0.0.1:${PORT}/up`,
  },
});
