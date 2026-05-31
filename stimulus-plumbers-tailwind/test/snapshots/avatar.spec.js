import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/avatar");
  await page.waitForSelector("[aria-label='Initials avatar']");
});

test.describe("avatar", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#avatar")).toHaveScreenshot("default.png");
  });
});
