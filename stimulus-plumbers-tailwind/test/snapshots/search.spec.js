import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/search");
  await page.waitForSelector("input[role='combobox']");
});

test.describe("search", () => {
  test("empty", async ({ page }) => {
    await expect(page.locator("#search-default")).toHaveScreenshot("empty.png");
  });

  test("populated", async ({ page }) => {
    await page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" })
      .fill("hello");
    await expect(page.locator("#search-default")).toHaveScreenshot(
      "populated.png",
    );
  });

  test("error", async ({ page }) => {
    await expect(page.locator("#search-error")).toHaveScreenshot("error.png");
  });

  test("clear — hidden after typing to empty", async ({ page }) => {
    const input = page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" });
    await input.fill("hello");
    for (let i = 0; i < 5; i++) await input.press("Backspace");
    await expect(page.locator("#search-default")).toHaveScreenshot(
      "clear-hidden-after-typing.png",
    );
  });

  test("clear — hidden after click", async ({ page }) => {
    await page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" })
      .fill("hello");
    await page
      .locator("#search-default")
      .getByRole("button", { name: "Clear search" })
      .click();
    await expect(page.locator("#search-default")).toHaveScreenshot(
      "clear-hidden-after-click.png",
    );
  });

  test("focus returned after clear", async ({ page }) => {
    await page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" })
      .fill("hello");
    await page
      .locator("#search-default")
      .getByRole("button", { name: "Clear search" })
      .click();
    const inputId = await page
      .locator("#search-default input[role='combobox']")
      .getAttribute("id");
    const activeId = await page.evaluate(() => document.activeElement?.id);
    expect(activeId).toBe(inputId);
  });
});
