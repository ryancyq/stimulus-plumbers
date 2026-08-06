import { test, expect } from "@playwright/test";

// A broken toggle still renders unchanged pixels, so assert reveal state directly.
const expectRevealed = async (section) => {
  await expect(
    section.locator("input[data-input-revealable-target='input']"),
  ).toHaveAttribute("type", "text");
  await expect(section.getByLabel("Hide password")).toBeVisible();
  await expect(
    section.locator("[data-input-revealable-target='revealIcon']"),
  ).toBeHidden();
  await expect(
    section.locator("[data-input-revealable-target='concealIcon']"),
  ).toBeVisible();
};

test.beforeEach(async ({ page }) => {
  await page.goto("/form/floating_label");
  await page.waitForSelector("form");
});

test.describe("floating label form", () => {
  test.describe("filled", () => {
    test("optional", async ({ page }) => {
      await expect(page.locator("#floating-filled-optional")).toHaveScreenshot(
        "floating-filled-optional.png",
      );
    });

    test("hint", async ({ page }) => {
      await expect(page.locator("#floating-filled-hint")).toHaveScreenshot(
        "floating-filled-hint.png",
      );
    });

    test("empty", async ({ page }) => {
      await expect(page.locator("#floating-filled")).toHaveScreenshot(
        "floating-filled-empty.png",
      );
    });

    test("typed", async ({ page }) => {
      await page
        .locator("#floating-filled input:not([type='hidden'])")
        .fill("Jane Doe");
      await expect(page.locator("#floating-filled")).toHaveScreenshot(
        "floating-filled-typed.png",
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

    test("typed", async ({ page }) => {
      await page
        .locator("#floating-outlined input:not([type='hidden'])")
        .fill("Jane Doe");
      await expect(page.locator("#floating-outlined")).toHaveScreenshot(
        "floating-outlined-typed.png",
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

    test("typed", async ({ page }) => {
      await page
        .locator("#floating-standard input:not([type='hidden'])")
        .fill("Jane Doe");
      await expect(page.locator("#floating-standard")).toHaveScreenshot(
        "floating-standard-typed.png",
      );
    });

    test("error", async ({ page }) => {
      await expect(page.locator("#floating-standard-error")).toHaveScreenshot(
        "floating-standard-error.png",
      );
    });
  });

  test.describe("outlined revealable", () => {
    test("hidden", async ({ page }) => {
      await expect(
        page.locator("#floating-outlined-revealable"),
      ).toHaveScreenshot("floating-outlined-revealable-hidden.png");
    });

    test("revealed", async ({ page }) => {
      const section = page.locator("#floating-outlined-revealable");
      await section.getByLabel("Show password").click();
      await expectRevealed(section);
      await expect(section).toHaveScreenshot(
        "floating-outlined-revealable-revealed.png",
      );
    });
  });

  test.describe("filled revealable", () => {
    test("hidden", async ({ page }) => {
      await expect(
        page.locator("#floating-filled-revealable"),
      ).toHaveScreenshot("floating-filled-revealable-hidden.png");
    });

    test("revealed", async ({ page }) => {
      const section = page.locator("#floating-filled-revealable");
      await section.getByLabel("Show password").click();
      await expectRevealed(section);
      await expect(section).toHaveScreenshot(
        "floating-filled-revealable-revealed.png",
      );
    });
  });
});
