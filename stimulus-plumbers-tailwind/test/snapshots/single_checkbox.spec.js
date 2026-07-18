import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/single_checkbox");
  await page.waitForSelector("form");
});

test.describe("single checkbox", () => {
  test("unchecked", async ({ page }) => {
    await expect(page.locator("#single-checkbox-default")).toHaveScreenshot(
      "single-checkbox-unchecked.png",
    );
  });

  test("with hint", async ({ page }) => {
    await expect(page.locator("#single-checkbox-hint")).toHaveScreenshot(
      "single-checkbox-hint.png",
    );
  });

  test("checked", async ({ page }) => {
    await page
      .locator('#single-checkbox-default input[type="checkbox"]')
      .locator("xpath=ancestor::label")
      .click();
    await expect(page.locator("#single-checkbox-default")).toHaveScreenshot(
      "single-checkbox-checked.png",
    );
  });

  test("error", async ({ page }) => {
    await expect(page.locator("#single-checkbox-error")).toHaveScreenshot(
      "single-checkbox-error.png",
    );
  });

  test("required", async ({ page }) => {
    await expect(page.locator("#single-checkbox-required")).toHaveScreenshot(
      "single-checkbox-required.png",
    );
  });
});
