import { test, expect } from "@playwright/test";

test.describe("code", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/code");
    await page.waitForSelector("#code-default form");
  });

  test("empty", async ({ page }) => {
    const field = page.locator(
      "#code-default [data-input-formatter-format-value='code']",
    );

    await expect(field).toHaveScreenshot("empty.png");
  });

  test("filled", async ({ page }) => {
    const field = page.locator(
      "#code-default [data-input-formatter-format-value='code']",
    );
    const input = field.getByRole("textbox", { name: "Verification code" });
    await input.fill("482913");

    await expect(input).toHaveValue("482913");
    await expect(field).toHaveScreenshot("filled.png");
  });
});
