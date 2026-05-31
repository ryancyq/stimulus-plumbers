import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/button");
  await page.waitForSelector("button");
});

test.describe("button", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#button")).toHaveScreenshot("default.png");
  });
});
