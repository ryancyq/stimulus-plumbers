import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/icon");
  await page.waitForSelector("svg");
});

test.describe("icon", () => {
  test("decorative", async ({ page }) => {
    await expect(page.locator("#icon-decorative")).toHaveScreenshot(
      "decorative.png",
    );
  });

  test("functional", async ({ page }) => {
    await expect(page.locator("#icon-functional")).toHaveScreenshot(
      "functional.png",
    );
  });

  test("in-button", async ({ page }) => {
    await expect(page.locator("#icon-in-button")).toHaveScreenshot(
      "in-button.png",
    );
  });
});
