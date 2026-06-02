import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/search");
  await page.waitForSelector("input[role='combobox']");
});

test.describe("search", () => {
  test("empty", async ({ page }) => {
    await expect(page.locator("#search")).toHaveScreenshot("empty.png");
  });

  test("populated", async ({ page }) => {
    await page.getByRole("combobox", { name: "Search" }).fill("hello");
    await expect(page.locator("#search")).toHaveScreenshot("populated.png");
  });

  test("clear — visible", async ({ page }) => {
    await page.getByRole("combobox", { name: "Search" }).fill("hello");
    await expect(
      page.getByRole("button", { name: "Clear search" }),
    ).toBeVisible();
    await expect(page.locator("#search")).toHaveScreenshot("clear-visible.png");
  });
});
