import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/action_list");
  await page.waitForSelector("[role='list']");
});

test.describe("action list", () => {
  test("plain", async ({ page }) => {
    await expect(page.locator("#action-list-plain")).toHaveScreenshot(
      "plain.png",
    );
  });

  test("with links", async ({ page }) => {
    await expect(page.locator("#action-list-with-links")).toHaveScreenshot(
      "with-links.png",
    );
  });

  test("active item", async ({ page }) => {
    await expect(page.locator("#action-list-active")).toHaveScreenshot(
      "active-item.png",
    );
  });
});
