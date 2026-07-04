import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/ordered_list");
  await page.waitForSelector("[role='list']");
});

test.describe("ordered list", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#ordered-list-default")).toHaveScreenshot(
      "default.png",
    );
  });

  test("with links", async ({ page }) => {
    await expect(page.locator("#ordered-list-with-links")).toHaveScreenshot(
      "with-links.png",
    );
  });

  test("custom handle icon", async ({ page }) => {
    await expect(
      page.locator("#ordered-list-custom-handle-icon"),
    ).toHaveScreenshot("custom-handle-icon.png");
  });
});
