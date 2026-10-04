import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/progress");
  await page.waitForSelector("h1");
});

test.describe("progress field", () => {
  test("percent readout", async ({ page }) => {
    await expect(page.locator("#progress-field-percent")).toHaveScreenshot(
      "percent.png",
    );
  });

  test("percent readout with hint", async ({ page }) => {
    await expect(page.locator("#progress-field-hint")).toHaveScreenshot(
      "hint.png",
    );
  });

  test("segmented", async ({ page }) => {
    await expect(page.locator("#progress-field-segmented")).toHaveScreenshot(
      "segmented.png",
    );
  });
});
