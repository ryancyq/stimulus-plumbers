import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");
const FIXED_YEAR = 2024;
const FIXED_MONTH = 2;

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
});

test.describe("stimulus calendar", () => {
  test("current month grid", async ({ page }) => {
    await page.goto(
      `/components/calendar/stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-month.png",
    );
  });

  test("28-cell grid (Feb 2026, no padding rows)", async ({ page }) => {
    await page.goto("/components/calendar/stimulus?year=2026&month=2");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-28-cell.png",
    );
  });

  test("42-cell grid (Jul 2023)", async ({ page }) => {
    await page.goto("/components/calendar/stimulus?year=2023&month=7");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-42-cell.png",
    );
  });

  test("other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar/stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-other-months.png",
    );
  });

  test("date range", async ({ page }) => {
    await page.goto(
      "/components/calendar/stimulus?year=2026&month=4&since=2026-03-30&till=2026-04-20",
    );
    await page.waitForSelector("#calendar-stimulus [role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-range.png",
    );
  });

  test("date range with other months visible", async ({ page }) => {
    await page.goto(
      "/components/calendar/stimulus?year=2026&month=4&since=2026-03-30&till=2026-04-20&show_other_months=true",
    );
    await page.waitForSelector("#calendar-stimulus [role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-range-other-months.png",
    );
  });

  test("selected date", async ({ page }) => {
    await page.goto(
      `/components/calendar/stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`,
    );
    await page.waitForSelector("#calendar-stimulus [role='gridcell']");
    await page
      .locator("#calendar-stimulus [role='gridcell']")
      .filter({ hasText: /^15$/ })
      .click();
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-selected.png",
    );
  });
});
