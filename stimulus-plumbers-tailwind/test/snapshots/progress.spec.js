import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/progress");
  await page.waitForSelector("h1");
});

test.describe("progress", () => {
  test("bar", async ({ page }) => {
    await expect(page.locator("#progress-bar")).toHaveScreenshot("bar.png");
  });

  test("bar indeterminate", async ({ page }) => {
    await expect(page.locator("#progress-bar-indeterminate")).toHaveScreenshot(
      "bar-indeterminate.png",
    );
  });

  test("ring", async ({ page }) => {
    await expect(page.locator("#progress-ring")).toHaveScreenshot("ring.png");
  });

  test("ring indeterminate", async ({ page }) => {
    await expect(page.locator("#progress-ring-indeterminate")).toHaveScreenshot(
      "ring-indeterminate.png",
    );
  });

  test("meter", async ({ page }) => {
    await expect(page.locator("#progress-meter")).toHaveScreenshot("meter.png");
  });
});
