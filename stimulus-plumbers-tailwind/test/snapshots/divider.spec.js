import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/divider");
  await page.waitForSelector("h1");
});

test.describe("divider", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#divider")).toHaveScreenshot("default.png");
  });
});
