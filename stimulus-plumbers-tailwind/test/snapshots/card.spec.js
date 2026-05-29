import { test, expect } from "@playwright/test";

test("card — default state", async ({ page }) => {
  await page.goto("/components/card");
  await page.waitForSelector("h1");
  await expect(page).toHaveScreenshot("default.png");
});
