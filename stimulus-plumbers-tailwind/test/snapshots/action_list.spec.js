import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/action_list");
  await page.waitForSelector("[role='list']");
});

test.describe("action list", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#action-list")).toHaveScreenshot("default.png");
  });
});
