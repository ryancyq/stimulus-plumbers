import { test, expect } from "@playwright/test";

test("divider — default state", async ({ page }) => {
  await page.goto("/components/divider");
  await page.waitForSelector("h1");
  await expect(page).toHaveScreenshot("default.png");
});
