import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/avatar");
  await page.waitForSelector("[role='img']");
});

test.describe("avatar", () => {
  test("initials", async ({ page }) => {
    await expect(page.locator("#avatar-initials")).toHaveScreenshot(
      "initials.png",
    );
  });

  test("image", async ({ page }) => {
    await expect(page.locator("#avatar-image")).toHaveScreenshot("image.png");
  });

  test("fallback", async ({ page }) => {
    await expect(page.locator("#avatar-fallback")).toHaveScreenshot(
      "fallback.png",
    );
  });

  test("sizes", async ({ page }) => {
    await expect(page.locator("#avatar-sizes")).toHaveScreenshot("sizes.png");
  });

  test("explicit variants", async ({ page }) => {
    await expect(page.locator("#avatar-variants")).toHaveScreenshot(
      "variants.png",
    );
  });
});
