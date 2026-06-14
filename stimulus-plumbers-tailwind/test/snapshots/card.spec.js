import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/card");
  await page.waitForSelector("h1");
});

test.describe("card", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#card-default")).toHaveScreenshot("default.png");
  });

  test("cta", async ({ page }) => {
    await expect(page.locator("#card-cta")).toHaveScreenshot("cta.png");
  });

  test("variants", async ({ page }) => {
    await expect(page.locator("#card-variants")).toHaveScreenshot("variants.png");
  });
});
