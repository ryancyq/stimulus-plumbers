import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/field_error");
  await page.waitForSelector("form");
});

test.describe("field error form", () => {
  test("required", async ({ page }) => {
    await expect(page.locator("#field-error-required")).toHaveScreenshot(
      "field-error-required.png",
    );
  });

  test("hint", async ({ page }) => {
    await expect(page.locator("#field-error-hint")).toHaveScreenshot(
      "field-error-hint.png",
    );
  });

  test("model error", async ({ page }) => {
    await expect(page.locator("#field-error-model")).toHaveScreenshot(
      "field-error-model.png",
    );
  });

  test("error override", async ({ page }) => {
    await expect(page.locator("#field-error-override")).toHaveScreenshot(
      "field-error-override.png",
    );
  });

  test("hidden label", async ({ page }) => {
    await expect(page.locator("#field-error-hidden-label")).toHaveScreenshot(
      "field-error-hidden-label.png",
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
