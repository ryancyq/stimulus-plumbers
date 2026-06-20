import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/list");
  await page.waitForSelector("[role='list']");
});

test.describe("list", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#list-default")).toHaveScreenshot("default.png");
  });

  test("with links", async ({ page }) => {
    await expect(page.locator("#list-with-links")).toHaveScreenshot(
      "with-links.png",
    );
  });

  test("active item", async ({ page }) => {
    await expect(page.locator("#list-active")).toHaveScreenshot(
      "active-item.png",
    );
  });

  test("with icons", async ({ page }) => {
    await expect(page.locator("#list-with-icons")).toHaveScreenshot(
      "with-icons.png",
    );
  });

  test("nested sections", async ({ page }) => {
    await expect(page.locator("#list-nested")).toHaveScreenshot("nested.png");
  });

  test("hierarchical sections", async ({ page }) => {
    await expect(page.locator("#list-hierarchical")).toHaveScreenshot(
      "hierarchical.png",
    );
  });
});
