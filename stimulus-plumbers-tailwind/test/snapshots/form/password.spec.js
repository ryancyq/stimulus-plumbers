import { test, expect } from "@playwright/test";

const expectHidden = async (section) => {
  await expect(
    section.locator("input[data-input-revealable-target='input']"),
  ).toHaveAttribute("type", "password");
  await expect(section.getByLabel("Show password")).toBeVisible();
  await expect(
    section.locator("[data-input-revealable-target='revealIcon']"),
  ).toBeVisible();
  await expect(
    section.locator("[data-input-revealable-target='concealIcon']"),
  ).toBeHidden();
};

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

// A dead controller can render identical pixels, so every test asserts state
// before screenshotting — the rule form.spec.js already applies to reveal.
test.describe("password", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/password");
    await page.waitForSelector("#password-default form");
  });

  test("default", async ({ page }) => {
    await expect(page.locator("#password-default")).toHaveScreenshot(
      "default.png",
    );
  });

  test.describe("revealable", () => {
    test("hidden", async ({ page }) => {
      const section = page.locator("#password-revealable");
      await expectHidden(section);
      await expect(section).toHaveScreenshot("revealable-hidden.png");
    });

    test("revealed", async ({ page }) => {
      const section = page.locator("#password-revealable");
      await section.getByLabel("Show password").click();
      await expectRevealed(section);
      await expect(section).toHaveScreenshot("revealable-revealed.png");
    });
  });

  test.describe("strength", () => {
    const fill = async (page, value) => {
      const section = page.locator("#password-strength");
      await section.locator("input[type='password']").fill(value);
      return section;
    };

    test("empty", async ({ page }) => {
      const section = page.locator("#password-strength");
      await expect(section.locator("meter")).toHaveAttribute("value", "0");
      await expect(
        section.locator('[data-password-strength-target="level"]'),
      ).toHaveText("Weak password");
      await expect(section.locator("li[data-rule='length']")).toHaveAttribute(
        "data-satisfied",
        "false",
      );
      await expect(section).toHaveScreenshot("strength-empty.png");
    });

    test("weak", async ({ page }) => {
      const section = await fill(page, "abcd");
      await expect(section.locator("meter")).toHaveAttribute("value", "0");
      await expect(
        section.locator('[data-password-strength-target="level"]'),
      ).toHaveText("Weak password");
      await expect(section.locator("li[data-rule='digit']")).toHaveAttribute(
        "data-satisfied",
        "false",
      );
      await expect(section).toHaveScreenshot("strength-weak.png");
    });

    test("fine", async ({ page }) => {
      const section = await fill(page, "Abcdefghijkl");
      await expect(section.locator("meter")).toHaveAttribute("value", "50");
      await expect(
        section.locator('[data-password-strength-target="level"]'),
      ).toHaveText("Fine password");
      await expect(
        section.locator("li[data-rule='uppercase']"),
      ).toHaveAttribute("data-satisfied", "true");
      await expect(section.locator("li[data-rule='symbol']")).toHaveAttribute(
        "data-satisfied",
        "false",
      );
      await expect(section).toHaveScreenshot("strength-fine.png");
    });

    test("strong", async ({ page }) => {
      const section = await fill(page, "Abcdef123456!");
      await expect(section.locator("meter")).toHaveAttribute("value", "100");
      await expect(
        section.locator('[data-password-strength-target="level"]'),
      ).toHaveText("Strong password");
      await expect(section.locator("li[data-rule='symbol']")).toHaveAttribute(
        "data-satisfied",
        "true",
      );
      await expect(section).toHaveScreenshot("strength-strong.png");
    });
  });

  test("strength revealed", async ({ page }) => {
    const section = page.locator("#password-strength-revealable");
    await section.locator("input[type='password']").fill("Abcdef123456!");
    await section.getByLabel("Show password").click();

    await expect(section.locator("meter")).toHaveAttribute("value", "100");
    await expect(
      section.locator('[data-password-strength-target="level"]'),
    ).toHaveText("Strong password");
    await expect(section.locator("li[data-rule='digit']")).toHaveAttribute(
      "data-satisfied",
      "true",
    );
    await expectRevealed(section);
    await expect(section).toHaveScreenshot("strength-revealed.png");
  });

  test("error", async ({ page }) => {
    await expect(page.locator("#password-error")).toHaveScreenshot("error.png");
  });
});
