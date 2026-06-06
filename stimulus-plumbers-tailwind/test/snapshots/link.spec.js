import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/link");
  await page.waitForSelector("a");
});

test.describe("link", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#link-default")).toHaveScreenshot("default.png");
  });

  test("inline", async ({ page }) => {
    await expect(page.locator("#link-inline")).toHaveScreenshot("inline.png");
  });

  test("icons", async ({ page }) => {
    await expect(page.locator("#link-icons")).toHaveScreenshot("icons.png");
  });

  test("button", async ({ page }) => {
    await expect(page.locator("#link-button")).toHaveScreenshot("button.png");
  });

  test("card", async ({ page }) => {
    await expect(page.locator("#link-card")).toHaveScreenshot("card.png");
  });

  test("button-icons", async ({ page }) => {
    await expect(page.locator("#link-button-icons")).toHaveScreenshot(
      "button-icons.png",
    );
  });
});
