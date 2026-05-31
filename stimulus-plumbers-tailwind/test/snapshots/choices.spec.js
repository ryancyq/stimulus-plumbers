import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/choices");
  await page.waitForSelector("form");
});

// ── Choices Overview ─────────────────────────────────────────────────────

test.describe("choices overview", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#choices-default")).toHaveScreenshot("choices-default.png");
  });
});

// ── Single Checkbox ───────────────────────────────────────────────────────

test.describe("single checkbox", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#single-checkbox-default")).toHaveScreenshot(
      "single-checkbox-default.png"
    );
  });

  test("with hint", async ({ page }) => {
    await expect(page.locator("#single-checkbox-hint")).toHaveScreenshot(
      "single-checkbox-hint.png"
    );
  });

  test("checked", async ({ page }) => {
    await page.locator('#single-checkbox-default input[type="checkbox"]').check();
    await expect(page.locator("#single-checkbox-default")).toHaveScreenshot(
      "single-checkbox-checked.png"
    );
  });
});

// ── Collection Checkbox ───────────────────────────────────────────────────

test.describe("collection checkbox", () => {
  test("stacked — default", async ({ page }) => {
    await expect(page.locator("#collection-checkbox-stacked")).toHaveScreenshot(
      "collection-checkbox-stacked-default.png"
    );
  });

  test("stacked — checked", async ({ page }) => {
    await page.locator('#collection-checkbox-stacked input[type="checkbox"]').first().check();
    await expect(page.locator("#collection-checkbox-stacked")).toHaveScreenshot(
      "collection-checkbox-stacked-checked.png"
    );
  });

  test("button — default", async ({ page }) => {
    await expect(page.locator("#collection-checkbox-button")).toHaveScreenshot(
      "collection-checkbox-button-default.png"
    );
  });

  test("button — checked", async ({ page }) => {
    await page.locator('#collection-checkbox-button input[type="checkbox"]').first().check();
    await expect(page.locator("#collection-checkbox-button")).toHaveScreenshot(
      "collection-checkbox-button-checked.png"
    );
  });

  test("card — default", async ({ page }) => {
    await expect(page.locator("#collection-checkbox-card")).toHaveScreenshot(
      "collection-checkbox-card-default.png"
    );
  });

  test("card — checked", async ({ page }) => {
    await page.locator('#collection-checkbox-card input[type="checkbox"]').first().check();
    await expect(page.locator("#collection-checkbox-card")).toHaveScreenshot(
      "collection-checkbox-card-checked.png"
    );
  });
});

// ── Collection Radio ──────────────────────────────────────────────────────

test.describe("collection radio", () => {
  test("stacked — default", async ({ page }) => {
    await expect(page.locator("#collection-radio-stacked")).toHaveScreenshot(
      "collection-radio-stacked-default.png"
    );
  });

  test("stacked — selected", async ({ page }) => {
    await page.locator('#collection-radio-stacked input[type="radio"]').first().check();
    await expect(page.locator("#collection-radio-stacked")).toHaveScreenshot(
      "collection-radio-stacked-selected.png"
    );
  });

  test("button — default", async ({ page }) => {
    await expect(page.locator("#collection-radio-button")).toHaveScreenshot(
      "collection-radio-button-default.png"
    );
  });

  test("button — selected", async ({ page }) => {
    await page.locator("#collection-radio-button label").first().click();
    await expect(page.locator("#collection-radio-button")).toHaveScreenshot(
      "collection-radio-button-selected.png"
    );
  });

  test("card — default", async ({ page }) => {
    await expect(page.locator("#collection-radio-card")).toHaveScreenshot(
      "collection-radio-card-default.png"
    );
  });

  test("card — selected", async ({ page }) => {
    await page.locator("#collection-radio-card label").first().click();
    await expect(page.locator("#collection-radio-card")).toHaveScreenshot(
      "collection-radio-card-selected.png"
    );
  });
});
