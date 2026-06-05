import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/link");
  await page.waitForSelector("a");
});

test.describe("link", () => {
  test("variants", async ({ page }) => {
    await expect(page.locator("#link-variants")).toHaveScreenshot("variants.png");
  });

  test("inline", async ({ page }) => {
    await expect(page.locator("#link-inline")).toHaveScreenshot("inline.png");
  });

  test("icons", async ({ page }) => {
    await expect(page.locator("#link-icons")).toHaveScreenshot("icons.png");
  });

  test("navigation", async ({ page }) => {
    await expect(page.locator("#link-navigation")).toHaveScreenshot(
      "navigation.png",
    );
  });

  test("button type", async ({ page }) => {
    await expect(page.locator("#link-button")).toHaveScreenshot("button.png");
  });

  test("button type icons", async ({ page }) => {
    await expect(page.locator("#link-button-icons")).toHaveScreenshot(
      "button-icons.png",
    );
  });
});
