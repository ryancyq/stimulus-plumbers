import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

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
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/combobox");
  await page.waitForSelector("input[aria-label='Birthday']");
});

test.describe("combobox", () => {
  test("date — closed", async ({ page }) => {
    await expect(page.locator("#combobox-date")).toHaveScreenshot(
      "date-closed.png",
    );
  });

  test("time — closed", async ({ page }) => {
    await expect(page.locator("#combobox-time")).toHaveScreenshot(
      "time-closed.png",
    );
  });

  test("dropdown — closed", async ({ page }) => {
    await expect(page.locator("#combobox-dropdown")).toHaveScreenshot(
      "dropdown-closed.png",
    );
  });

  test("typeahead — closed", async ({ page }) => {
    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot(
      "typeahead-closed.png",
    );
  });

  test("date — open", async ({ page }) => {
    const section = page.locator("#combobox-date");
    await section.getByRole("combobox", { name: "Birthday" }).click();
    await screenshotWithPanel(page, section, "date-open.png");
  });

  test("time — open", async ({ page }) => {
    const section = page.locator("#combobox-time");
    await section.getByRole("combobox", { name: "Meeting Time" }).click();
    await screenshotWithPanel(page, section, "time-open.png");
  });

  test("dropdown — open", async ({ page }) => {
    const section = page.locator("#combobox-dropdown");
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "dropdown-open.png");
  });

  test("typeahead — open", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).click();
    await screenshotWithPanel(page, section, "typeahead-open.png");
  });

  test("typeahead — loading", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).click();
    await section
      .locator("[data-combobox-dropdown-target='loading']")
      .evaluate((el) => el.removeAttribute("hidden"));
    await screenshotWithPanel(page, section, "typeahead-loading.png");
  });

  test("typeahead — empty", async ({ page }) => {
    const section = page.locator("#combobox-typeahead");
    await section.getByRole("combobox", { name: "City" }).click();
    await section
      .locator("[data-combobox-dropdown-target='empty']")
      .evaluate((el) => el.removeAttribute("hidden"));
    await screenshotWithPanel(page, section, "typeahead-empty.png");
  });

  test("preselected — closed", async ({ page }) => {
    await expect(page.locator("#combobox-preselected")).toHaveScreenshot(
      "preselected-closed.png",
    );
  });

  test("preselected — open", async ({ page }) => {
    const section = page.locator("#combobox-preselected");
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "preselected-open.png");
  });

  test("disabled option — open", async ({ page }) => {
    const section = page.locator("#combobox-disabled-option");
    await section.getByRole("combobox", { name: "Country" }).click();
    await screenshotWithPanel(page, section, "disabled-option-open.png");
  });

  test("date error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-date-error")).toHaveScreenshot(
      "date-error-closed.png",
    );
  });

  test("date error — open", async ({ page }) => {
    const section = page.locator("#combobox-date-error");
    await section.locator("input[role='combobox']").click();
    await screenshotWithPanel(page, section, "date-error-open.png");
  });

  test("time error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-time-error")).toHaveScreenshot(
      "time-error-closed.png",
    );
  });

  test("time error — open", async ({ page }) => {
    const section = page.locator("#combobox-time-error");
    await section.locator("input[role='combobox']").click();
    await screenshotWithPanel(page, section, "time-error-open.png");
  });

  test("dropdown error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-dropdown-error")).toHaveScreenshot(
      "dropdown-error-closed.png",
    );
  });

  test("dropdown error — open", async ({ page }) => {
    const section = page.locator("#combobox-dropdown-error");
    await section.locator("input[role='combobox']").click();
    await screenshotWithPanel(page, section, "dropdown-error-open.png");
  });

  test("typeahead error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-typeahead-error")).toHaveScreenshot(
      "typeahead-error-closed.png",
    );
  });

  test("typeahead error — open", async ({ page }) => {
    const section = page.locator("#combobox-typeahead-error");
    await section.locator("input[role='combobox']").click();
    await screenshotWithPanel(page, section, "typeahead-error-open.png");
  });
});
