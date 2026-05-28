import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/search");
  await page.waitForSelector("input[role='combobox']");
});

test("search — empty input", async ({ page }) => {
  await expect(page).toHaveScreenshot("empty.png");
});

test("search — populated input", async ({ page }) => {
  await page.getByLabel("Search").fill("hello");
  await expect(page).toHaveScreenshot("populated.png");
});

test("search — clear button visible", async ({ page }) => {
  await page.getByLabel("Search").fill("hello");
  await expect(page.getByRole("button", { name: "Clear search" })).toBeVisible();
  await expect(page).toHaveScreenshot("clear-visible.png");
});
