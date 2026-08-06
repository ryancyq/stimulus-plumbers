import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/form/sign_up");
  await page.waitForSelector("form");
});

test.describe("sign up form", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#sign-up")).toHaveScreenshot(
      "sign-up-default.png",
    );
  });

  test("floating labels", async ({ page }) => {
    await expect(page.locator("#sign-up-floating")).toHaveScreenshot(
      "sign-up-floating.png",
    );
  });

  test("floating labels — filled", async ({ page }) => {
    const section = page.locator("#sign-up-floating");
    await section.locator("input[type='text']").fill("Jane Doe");
    await section.locator("input[type='email']").fill("jane@example.com");
    await section.locator("input[type='password']").fill("secret123");
    await expect(section).toHaveScreenshot("sign-up-floating-filled.png");
  });

  test("icon-only submit", async ({ page }) => {
    await expect(page.locator("#sign-up-submit-icon-only")).toHaveScreenshot(
      "sign-up-submit-icon-only.png",
    );
  });
});
