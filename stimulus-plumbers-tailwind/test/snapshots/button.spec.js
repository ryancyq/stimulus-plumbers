import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/button");
  await page.waitForSelector("button");
});

test.describe("button", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#button-default")).toHaveScreenshot(
      "default.png",
    );
  });

  test("outline", async ({ page }) => {
    await expect(page.locator("#button-outline")).toHaveScreenshot(
      "outline.png",
    );
  });

  test("ghost", async ({ page }) => {
    await expect(page.locator("#button-ghost")).toHaveScreenshot("ghost.png");
  });

  test("fab", async ({ page }) => {
    await expect(page.locator("#button-fab")).toHaveScreenshot("fab.png");
  });

  test("fab-outline", async ({ page }) => {
    await expect(page.locator("#button-fab-outline")).toHaveScreenshot(
      "fab-outline.png",
    );
  });

  test("dashed", async ({ page }) => {
    await expect(page.locator("#button-dashed")).toHaveScreenshot("dashed.png");
  });

  test("card", async ({ page }) => {
    await expect(page.locator("#button-card")).toHaveScreenshot("card.png");
  });

  test("sizes", async ({ page }) => {
    await expect(page.locator("#button-sizes")).toHaveScreenshot("sizes.png");
  });

  test("icons", async ({ page }) => {
    await expect(page.locator("#button-icons")).toHaveScreenshot("icons.png");
  });

  test("card-icons", async ({ page }) => {
    await expect(page.locator("#button-card-icons")).toHaveScreenshot(
      "card-icons.png",
    );
  });

  test("disabled", async ({ page }) => {
    await expect(page.locator("#button-disabled")).toHaveScreenshot(
      "disabled.png",
    );
  });
});
