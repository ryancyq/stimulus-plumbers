import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/field_error");
  await page.waitForSelector("form");
});

test.describe("field error form", () => {
  test("error state", async ({ page }) => {
    await expect(page.locator("#field-error")).toHaveScreenshot(
      "field-error.png",
    );
  });

  test("textarea error", async ({ page }) => {
    await expect(page.locator("#field-error-textarea")).toHaveScreenshot(
      "field-error-textarea.png",
    );
  });

  test("select error", async ({ page }) => {
    await expect(page.locator("#field-error-select")).toHaveScreenshot(
      "field-error-select.png",
    );
  });

  test("checkbox error", async ({ page }) => {
    await expect(page.locator("#field-error-checkbox")).toHaveScreenshot(
      "field-error-checkbox.png",
    );
  });

  test("file error", async ({ page }) => {
    await expect(page.locator("#field-error-file")).toHaveScreenshot(
      "field-error-file.png",
    );
  });
});
