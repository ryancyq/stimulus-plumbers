import { test, expect } from "@playwright/test";

test("fieldset — default state", async ({ page }) => {
  await page.goto("/form/fieldset");
  await page.waitForSelector("form");
  await expect(page).toHaveScreenshot("default.png");
});
