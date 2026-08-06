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

  // A range is labelable, so it takes a real <label for> — unlike the progress field.
  test("keeps a native label association", async ({ page }) => {
    const section = page.locator("#range-field-default");
    await expect(section.locator("label")).toHaveAttribute(
      "for",
      "preferences_volume",
    );
    await expect(section.locator("input[type=range]")).toHaveCount(1);
  });

  test("readout tracks the value as the slider moves", async ({ page }) => {
    const input = page.locator("#range-field-readout input[type=range]");
    await input.fill("80");
    await expect(
      page.locator("#range-field-readout [data-progress-target=value]"),
    ).toHaveText("80%");
    await expect(input).toHaveAttribute("style", /--sp-progress-percent:\s*80/);
  });
});
