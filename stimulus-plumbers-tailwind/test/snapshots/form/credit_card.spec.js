import { test, expect } from "@playwright/test";

test.describe("credit card", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/credit_card");
    await page.waitForSelector("#credit-card-default form");
  });

  test("empty", async ({ page }) => {
    const field = page.locator(
      "#credit-card-default [data-input-formatter-format-value='creditCard']",
    );

    await expect(field).toHaveScreenshot("empty.png");
  });

  test("formatted and filled", async ({ page }) => {
    const field = page.locator(
      "#credit-card-default [data-input-formatter-format-value='creditCard']",
    );
    const input = field.getByRole("textbox", { name: "Card number" });
    await input.fill("4242424242424242");

    await expect(input).toHaveValue("4242 4242 4242 4242");
    await expect(field).toHaveScreenshot("filled.png");
  });

  test("separator empty", async ({ page }) => {
    const field = page.locator(
      "#credit-card-separator [data-input-formatter-format-value='creditCard']",
    );

    await expect(field).toHaveScreenshot("separator-empty.png");
  });

  test("separator formatted and filled", async ({ page }) => {
    const field = page.locator(
      "#credit-card-separator [data-input-formatter-format-value='creditCard']",
    );
    const input = field.getByRole("textbox", { name: "Card number" });
    await input.fill("4242424242424242");

    await expect(input).toHaveValue("4242 4242 4242 4242");
    await expect(field).toHaveScreenshot("separator-filled.png");
  });
});
