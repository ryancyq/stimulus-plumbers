import { test, expect } from "@playwright/test";

test.describe("credit card", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/credit_card");
    await page.waitForSelector("#credit-card-default form");
  });

  test("empty", async ({ page }) => {
    const input = page
      .locator("#credit-card-default")
      .getByRole("textbox", { name: "Card number" });

    await expect(input).toHaveScreenshot("empty.png");
  });

  test("formatted and filled", async ({ page }) => {
    const input = page
      .locator("#credit-card-default")
      .getByRole("textbox", { name: "Card number" });
    await input.fill("4242424242424242");
    await expect(input).toHaveScreenshot("filled.png");
  });

  test("separator empty", async ({ page }) => {
    const input = page
      .locator("#credit-card-separator")
      .getByRole("textbox", { name: "Card number" });

    await expect(input).toHaveScreenshot("separator-empty.png");
  });

  test("separator formatted and filled", async ({ page }) => {
    const input = page
      .locator("#credit-card-separator")
      .getByRole("textbox", { name: "Card number" });
    await input.fill("4242424242424242");
    await expect(input).toHaveScreenshot("separator-filled.png");
  });
});
