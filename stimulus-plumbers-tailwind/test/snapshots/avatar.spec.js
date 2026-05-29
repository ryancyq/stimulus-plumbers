import { test, expect } from "@playwright/test";

test("avatar — default state", async ({ page }) => {
  await page.goto("/components/avatar");
  await page.waitForSelector("[aria-label='Initials avatar']");
  await expect(page).toHaveScreenshot("default.png");
});
