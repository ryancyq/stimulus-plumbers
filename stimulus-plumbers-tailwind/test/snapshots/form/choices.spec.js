import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/choices");
  await page.waitForSelector("form");
});

test.describe("choices overview", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#choices-default")).toHaveScreenshot(
      "choices-default.png",
    );
  });
});
