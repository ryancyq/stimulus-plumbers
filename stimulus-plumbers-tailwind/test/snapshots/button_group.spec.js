import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/button_group");
  await page.waitForSelector("button");
});

test.describe("button_group", () => {
  test("inline", async ({ page }) => {
    await expect(page.locator("#button-group-inline")).toHaveScreenshot(
      "group-inline.png",
    );
  });

  test("stacked", async ({ page }) => {
    await expect(page.locator("#button-group-stacked")).toHaveScreenshot(
      "group-stacked.png",
    );
  });
});
