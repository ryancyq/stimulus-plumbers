import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/button");
  await page.waitForSelector("button");
});

test.describe("button", () => {
  test("variants", async ({ page }) => {
    await expect(page.locator("#button-variants")).toHaveScreenshot(
      "variants.png",
    );
  });

  test("semantic", async ({ page }) => {
    await expect(page.locator("#button-semantic")).toHaveScreenshot(
      "semantic.png",
    );
  });

  test("sizes", async ({ page }) => {
    await expect(page.locator("#button-sizes")).toHaveScreenshot("sizes.png");
  });

  test("icons", async ({ page }) => {
    await expect(page.locator("#button-icons")).toHaveScreenshot("icons.png");
  });

  test("link", async ({ page }) => {
    await expect(page.locator("#button-link")).toHaveScreenshot("link.png");
  });

  test("disabled", async ({ page }) => {
    await expect(page.locator("#button-disabled")).toHaveScreenshot(
      "disabled.png",
    );
  });
});
