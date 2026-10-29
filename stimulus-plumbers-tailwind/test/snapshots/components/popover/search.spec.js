import { test, expect } from "@playwright/test";

// Union the section and its open popover panel into a single clip rect.
async function screenshotWithPanel(page, sectionLocator, filename) {
  const panel = sectionLocator.locator("[popover]");
  await panel.waitFor({ state: "visible" });
  await expect(panel).toHaveCSS("transform", "matrix(1, 0, 0, 1, 0, 0)");
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
  await page.goto("/components/popover/search");
  await page.waitForSelector("input[role='combobox']");
});

test.describe("search", () => {
  test("empty", async ({ page }) => {
    await expect(page.locator("#search-default")).toHaveScreenshot("empty.png");
  });

  test("populated", async ({ page }) => {
    await page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" })
      .fill("hello");
    await expect(page.locator("#search-default")).toHaveScreenshot(
      "populated.png",
    );
  });

  test("error", async ({ page }) => {
    await expect(page.locator("#search-error")).toHaveScreenshot("error.png");
  });

  test("clear — hidden after typing to empty", async ({ page }) => {
    const input = page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" });
    await input.fill("hello");
    for (let i = 0; i < 5; i++) await input.press("Backspace");
    await expect(page.locator("#search-default")).toHaveScreenshot(
      "clear-hidden-after-typing.png",
    );
  });

  test("clear — hidden after click", async ({ page }) => {
    await page
      .locator("#search-default")
      .getByRole("combobox", { name: "Search" })
      .fill("hello");
    await page
      .locator("#search-default")
      .getByRole("button", { name: "Clear search" })
      .click();
    await expect(page.locator("#search-default")).toHaveScreenshot(
      "clear-hidden-after-click.png",
    );
  });

  test("suggestions — closed", async ({ page }) => {
    await expect(page.locator("#search-suggestions")).toHaveScreenshot(
      "suggestions-closed.png",
    );
  });

  test("suggestions — open", async ({ page }) => {
    const section = page.locator("#search-suggestions");
    await section.getByRole("combobox", { name: "City" }).fill("S");
    await screenshotWithPanel(page, section, "suggestions-open.png");
  });
});
