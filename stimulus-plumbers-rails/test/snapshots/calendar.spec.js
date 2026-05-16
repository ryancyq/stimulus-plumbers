import { test, expect } from "@playwright/test";

test("calendar stimulus — current month grid", async ({ page }) => {
  await page.goto("/components/calendar_stimulus");
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("stimulus-month.png");
});

test("calendar turbo — current month grid", async ({ page }) => {
  await page.goto("/components/calendar_turbo");
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("turbo-month.png");
});
