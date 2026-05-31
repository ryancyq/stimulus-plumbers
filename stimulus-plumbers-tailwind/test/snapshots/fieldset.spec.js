import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/fieldset");
  await page.waitForSelector("form");
});

test.describe("fieldset", () => {
  test("radio buttons", async ({ page }) => {
    await expect(page.locator("#fieldset-radio")).toHaveScreenshot("fieldset-radio.png");
  });

  test("radio buttons with error", async ({ page }) => {
    await expect(page.locator("#fieldset-radio-error")).toHaveScreenshot("fieldset-radio-error.png");
  });

  test("radio buttons required", async ({ page }) => {
    await expect(page.locator("#fieldset-radio-required")).toHaveScreenshot("fieldset-radio-required.png");
  });

  test("check boxes", async ({ page }) => {
    await expect(page.locator("#fieldset-checkbox")).toHaveScreenshot("fieldset-checkbox.png");
  });

  test("check boxes with error", async ({ page }) => {
    await expect(page.locator("#fieldset-checkbox-error")).toHaveScreenshot("fieldset-checkbox-error.png");
  });
});
