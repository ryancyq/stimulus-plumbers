import { test, expect } from "@playwright/test";
import { screenshotWithPanel } from "../../../support/playwright.js";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover/fetch");
  await page.waitForSelector(
    "#popover-fetch [data-controller~='popover-fetch']",
  );
});

test.describe("popover fetch", () => {
  test("loaded", async ({ page }) => {
    const section = page.locator("#popover-fetch");
    await section.getByRole("button", { name: "Account" }).click();
    await expect(section.getByRole("link", { name: "Profile" })).toBeVisible();
    await screenshotWithPanel(page, section, "loaded.png");
  });

  test("failed", async ({ page }) => {
    const section = page.locator("#popover-fetch-error");
    await section.getByRole("button", { name: "Billing" }).click();
    await expect(
      section.getByText("Content could not be loaded"),
    ).toBeVisible();
    await screenshotWithPanel(page, section, "failed.png");
  });
});
