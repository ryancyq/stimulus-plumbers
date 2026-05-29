import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/choices");
  await page.waitForSelector("form");
});

test("choices form — default state", async ({ page }) => {
  await expect(page).toHaveScreenshot("choices-default.png");
});
