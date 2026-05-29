import { test, expect } from "@playwright/test";

test("action list — default state", async ({ page }) => {
  await page.goto("/components/action_list");
  await page.waitForSelector("[role='list']");
  await expect(page).toHaveScreenshot("default.png");
});
