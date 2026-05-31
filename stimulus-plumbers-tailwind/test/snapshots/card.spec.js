import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/card");
  await page.waitForSelector("h1");
});

test.describe("card", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#card")).toHaveScreenshot("default.png");
  });
});
