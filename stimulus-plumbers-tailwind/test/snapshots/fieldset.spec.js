import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/fieldset");
  await page.waitForSelector("form");
});

test.describe("fieldset", () => {
  test.describe("radio buttons", () => {
    test("default", async ({ page }) => {
      await expect(page.locator("#fieldset-radio")).toHaveScreenshot(
        "fieldset-radio.png",
      );
    });

    test("error", async ({ page }) => {
      await expect(page.locator("#fieldset-radio-error")).toHaveScreenshot(
        "fieldset-radio-error.png",
      );
    });

    test("required", async ({ page }) => {
      await expect(page.locator("#fieldset-radio-required")).toHaveScreenshot(
        "fieldset-radio-required.png",
      );
    });
  });

  test.describe("check boxes", () => {
    test("default", async ({ page }) => {
      await expect(page.locator("#fieldset-checkbox")).toHaveScreenshot(
        "fieldset-checkbox.png",
      );
    });

    test("error", async ({ page }) => {
      await expect(page.locator("#fieldset-checkbox-error")).toHaveScreenshot(
        "fieldset-checkbox-error.png",
      );
    });

    test("required", async ({ page }) => {
      await expect(page.locator("#fieldset-checkbox-required")).toHaveScreenshot(
        "fieldset-checkbox-required.png",
      );
    });

    test("hint", async ({ page }) => {
      await expect(page.locator("#fieldset-checkbox-hint")).toHaveScreenshot(
        "fieldset-checkbox-hint.png",
      );
    });
  });

  test.describe("radio hint", () => {
    test("hint", async ({ page }) => {
      await expect(page.locator("#fieldset-radio-hint")).toHaveScreenshot(
        "fieldset-radio-hint.png",
      );
    });
  });
});
