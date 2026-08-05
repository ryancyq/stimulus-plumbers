import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/progress");
  await page.waitForSelector("h1");
});

test.describe("progress field", () => {
  test("percent readout", async ({ page }) => {
    await expect(page.locator("#progress-field-percent")).toHaveScreenshot(
      "percent.png",
    );
  });

  test("percent readout with hint", async ({ page }) => {
    await expect(page.locator("#progress-field-hint")).toHaveScreenshot(
      "hint.png",
    );
  });

  test("segmented", async ({ page }) => {
    await expect(page.locator("#progress-field-segmented")).toHaveScreenshot(
      "segmented.png",
    );
  });

  // The label names the bar via aria-labelledby; a <label for> would be invalid here.
  test("label is not a label element", async ({ page }) => {
    const section = page.locator("#progress-field-percent");
    await expect(section.locator("label")).toHaveCount(0);
    await expect(section.locator("[role='progressbar']")).toHaveAttribute(
      "aria-labelledby",
      /completion_label$/,
    );
  });
});
