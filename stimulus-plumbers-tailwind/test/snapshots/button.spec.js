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

  test("sizes", async ({ page }) => {
    await expect(page.locator("#button-sizes")).toHaveScreenshot("sizes.png");
  });

  test("group", async ({ page }) => {
    await expect(page.locator("#button-group")).toHaveScreenshot("group.png");
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
