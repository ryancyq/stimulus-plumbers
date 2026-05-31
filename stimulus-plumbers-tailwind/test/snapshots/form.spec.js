import { test, expect } from "@playwright/test";

// ── Sign up form ─────────────────────────────────────────────────────────────

test.describe("sign up form", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/sign_up");
    await page.waitForSelector("form");
  });

  test("default", async ({ page }) => {
    await expect(page.locator("#sign-up")).toHaveScreenshot("sign-up-default.png");
  });

  test("password revealed", async ({ page }) => {
    await page.getByLabel("Show password").click();
    await expect(page.locator("#sign-up")).toHaveScreenshot("sign-up-password-revealed.png");
  });
});

// ── Field error form ─────────────────────────────────────────────────────────

test.describe("field error form", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/field_error");
    await page.waitForSelector("form");
  });

  test("error state", async ({ page }) => {
    await expect(page.locator("#field-error")).toHaveScreenshot("field-error.png");
  });
});
