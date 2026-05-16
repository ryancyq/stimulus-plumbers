import { test, expect } from "@playwright/test";

test("sign up form — default state", async ({ page }) => {
  await page.goto("/form/sign_up");
  await page.waitForSelector("form");
  await expect(page).toHaveScreenshot("sign-up-default.png");
});

test("sign up form — password revealed", async ({ page }) => {
  await page.goto("/form/sign_up");
  await page.waitForSelector("form");
  await page.getByLabel("Show password").click();
  await expect(page).toHaveScreenshot("sign-up-password-revealed.png");
});

test("field error form — error state", async ({ page }) => {
  await page.goto("/form/field_error");
  await page.waitForSelector("form");
  await expect(page).toHaveScreenshot("field-error.png");
});
