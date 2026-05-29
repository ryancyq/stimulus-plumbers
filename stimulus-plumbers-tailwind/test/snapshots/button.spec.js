import { test, expect } from "@playwright/test";

test("button — default state", async ({ page }) => {
  await page.goto("/components/button");
  await page.waitForSelector("button");
  await expect(page).toHaveScreenshot("default.png");
});
