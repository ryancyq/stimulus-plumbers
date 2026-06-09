import { test, expect } from "@playwright/test";

// ── Sign up form ─────────────────────────────────────────────────────────────

test.describe("sign up form", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/sign_up");
    await page.waitForSelector("form");
  });

  test("default", async ({ page }) => {
    await expect(page.locator("#sign-up")).toHaveScreenshot(
      "sign-up-default.png",
    );
  });

  test("password revealed", async ({ page }) => {
    await page.locator("#sign-up").getByLabel("Show password").click();
    await expect(page.locator("#sign-up")).toHaveScreenshot(
      "sign-up-password-revealed.png",
    );
  });

  test("floating labels", async ({ page }) => {
    await expect(page.locator("#sign-up-floating")).toHaveScreenshot(
      "sign-up-floating.png",
    );
  });
});

// ── Field error form ─────────────────────────────────────────────────────────

test.describe("field error form", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/field_error");
    await page.waitForSelector("form");
  });

  test("error state", async ({ page }) => {
    await expect(page.locator("#field-error")).toHaveScreenshot(
      "field-error.png",
    );
  });
});

// ── Floating label form ───────────────────────────────────────────────────────

test.describe("floating label form", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/floating_label");
    await page.waitForSelector("form");
  });

  test.describe("filled", () => {
    test("empty", async ({ page }) => {
      await expect(page.locator("#floating-filled")).toHaveScreenshot(
        "floating-filled-empty.png",
      );
    });

    test("focused", async ({ page }) => {
      await page.locator("#floating-filled input:not([type='hidden'])").focus();
      await expect(page.locator("#floating-filled")).toHaveScreenshot(
        "floating-filled-focused.png",
      );
    });

    test("error", async ({ page }) => {
      await expect(page.locator("#floating-filled-error")).toHaveScreenshot(
        "floating-filled-error.png",
      );
    });
  });

  test.describe("outlined", () => {
    test("empty", async ({ page }) => {
      await expect(page.locator("#floating-outlined")).toHaveScreenshot(
        "floating-outlined-empty.png",
      );
    });

    test("focused", async ({ page }) => {
      await page.locator("#floating-outlined input:not([type='hidden'])").focus();
      await expect(page.locator("#floating-outlined")).toHaveScreenshot(
        "floating-outlined-focused.png",
      );
    });

    test("error", async ({ page }) => {
      await expect(page.locator("#floating-outlined-error")).toHaveScreenshot(
        "floating-outlined-error.png",
      );
    });
  });

  test.describe("standard", () => {
    test("empty", async ({ page }) => {
      await expect(page.locator("#floating-standard")).toHaveScreenshot(
        "floating-standard-empty.png",
      );
    });

    test("focused", async ({ page }) => {
      await page.locator("#floating-standard input:not([type='hidden'])").focus();
      await expect(page.locator("#floating-standard")).toHaveScreenshot(
        "floating-standard-focused.png",
      );
    });

    test("error", async ({ page }) => {
      await expect(page.locator("#floating-standard-error")).toHaveScreenshot(
        "floating-standard-error.png",
      );
    });
  });
});
