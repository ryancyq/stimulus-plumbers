import { test, expect } from "@playwright/test";

// Union the section and its open popover panel into a single clip rect.
async function screenshotWithPanel(page, sectionLocator, filename) {
  const panel = sectionLocator.locator("[data-popover-target='panel']");
  await panel.waitFor({ state: "visible" });
  const sBox = await sectionLocator.boundingBox();
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
