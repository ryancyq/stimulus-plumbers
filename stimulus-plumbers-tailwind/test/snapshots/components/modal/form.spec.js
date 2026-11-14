import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/modal/form");
  await page.waitForSelector("#modal-form form");
});

test.describe("modal form", () => {
  test("direct route", async ({ page }) => {
    await expect(page.locator("#modal-form")).toHaveScreenshot("direct.png");
  });
});
