import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/range");
  await page.waitForSelector("h1");
});

test.describe("range field", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#range-field-default")).toHaveScreenshot(
      "default.png",
    );
  });

  test("percent readout", async ({ page }) => {
    await expect(page.locator("#range-field-readout")).toHaveScreenshot(
      "readout.png",
    );
  });

  test("disabled", async ({ page }) => {
    await expect(page.locator("#range-field-disabled")).toHaveScreenshot(
      "disabled.png",
    );
  });

  // The gradient fill is most likely to break at the boundaries.
  test("at minimum", async ({ page }) => {
    await expect(page.locator("#range-field-min")).toHaveScreenshot("min.png");
  });

  test("at maximum", async ({ page }) => {
    await expect(page.locator("#range-field-max")).toHaveScreenshot("max.png");
  });
});
