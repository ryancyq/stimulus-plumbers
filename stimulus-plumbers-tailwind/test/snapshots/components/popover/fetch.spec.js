import { test, expect } from "@playwright/test";
import { settled } from "../../../support/playwright.js";

// Waits for the panel to settle, then clips the section and panel.
async function screenshotWithPanel(page, section, filename) {
  const panel = section.locator("[data-popover-target='panel']");
  await panel.waitFor({ state: "visible" });
  await settled(panel);
  const sBox = await section.boundingBox();
  const pBox = await panel.boundingBox();
  const x = Math.min(sBox.x, pBox.x);
  const y = Math.min(sBox.y, pBox.y);
  const right = Math.max(sBox.x + sBox.width, pBox.x + pBox.width);
  const bottom = Math.max(sBox.y + sBox.height, pBox.y + pBox.height);
  await expect(page).toHaveScreenshot(filename, {
    clip: { x, y, width: right - x, height: bottom - y },
  });
}

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
    await expect(section.getByRole("status")).toHaveText(
      "Content could not be loaded",
    );
    await screenshotWithPanel(page, section, "failed.png");
  });
});
