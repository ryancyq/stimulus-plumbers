import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/indicator");
  await page.waitForSelector("h1");
});

test.describe("indicator", () => {
  test("dot", async ({ page }) => {
    await expect(page.locator("#indicator-dot")).toHaveScreenshot("dot.png");
  });

  test("pulse", async ({ page }) => {
    await expect(page.locator("#indicator-pulse")).toHaveScreenshot(
      "pulse.png",
    );
  });

  test("badge", async ({ page }) => {
    await expect(page.locator("#indicator-badge")).toHaveScreenshot(
      "badge.png",
    );
  });
});
