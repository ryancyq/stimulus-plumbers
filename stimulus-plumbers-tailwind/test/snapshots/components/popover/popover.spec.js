import { test, expect } from "@playwright/test";
import { screenshotWithPanel } from "../../../support/playwright.js";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover");
  await page.waitForSelector("#popover-default [data-controller='popover']");
});

test.describe("popover", () => {
  test("closed", async ({ page }) => {
    await expect(page.locator("#popover-default")).toHaveScreenshot(
      "closed.png",
    );
  });

  test("open", async ({ page }) => {
    const section = page.locator("#popover-default");
    await section.getByRole("button", { name: "Open menu" }).click();
    await screenshotWithPanel(page, section, "open.png");
  });

  test("reduced motion — open without a panel transition", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    const section = page.locator("#popover-default");
    await section.getByRole("button", { name: "Open menu" }).click();
    await expect(section.locator("[data-popover-target='panel']")).toHaveCSS(
      "transition-duration",
      "0s",
    );
  });

  test("details — open", async ({ page }) => {
    const section = page.locator("#popover-details");
    await section.getByRole("button", { name: "Open details" }).click();
    await screenshotWithPanel(page, section, "details-open.png");
  });

  test("help — open", async ({ page }) => {
    const section = page.locator("#popover-help");
    await section.getByRole("button", { name: "Open help" }).click();
    await screenshotWithPanel(page, section, "help-open.png");
  });
});
