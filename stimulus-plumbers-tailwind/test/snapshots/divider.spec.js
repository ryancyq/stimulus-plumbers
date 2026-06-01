import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/divider");
  await page.waitForSelector("h1");
});

test.describe("divider", () => {
  test("plain", async ({ page }) => {
    await expect(page.locator("#divider-plain")).toHaveScreenshot("plain.png");
  });

  test("labeled", async ({ page }) => {
    await expect(page.locator("#divider-labeled")).toHaveScreenshot(
      "labeled.png",
    );
  });
});
