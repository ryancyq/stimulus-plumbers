import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");
const FIXED_YEAR = 2024;
const FIXED_MONTH = 2;
const FIXED_DAY = 29;

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
});

// ── Stimulus calendar ────────────────────────────────────────────────────────

test.describe("stimulus calendar", () => {
  test("current month grid", async ({ page }) => {
    await page.goto(
      `/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-month.png",
    );
  });

  test("28-cell grid (Feb 2026, no padding rows)", async ({ page }) => {
    await page.goto("/components/calendar_stimulus?year=2026&month=2");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-28-cell.png",
    );
  });

  test("35-cell grid (Apr 2026)", async ({ page }) => {
    await page.goto("/components/calendar_stimulus?year=2026&month=4");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-35-cell.png",
    );
  });

  test("42-cell grid (Jul 2023)", async ({ page }) => {
    await page.goto("/components/calendar_stimulus?year=2023&month=7");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-42-cell.png",
    );
  });

  test("other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-stimulus")).toHaveScreenshot(
      "stimulus-other-months.png",
    );
  });

  test("selected day", async ({ page }) => {
    await page.goto(
      `/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`,
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

// ── Turbo calendar ───────────────────────────────────────────────────────────

test.describe("turbo calendar", () => {
  test("current month grid", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-month.png",
    );
  });

  test("28-cell grid (Feb 2026, no padding rows)", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=2026&month=2&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-28-cell.png",
    );
  });

  test("35-cell grid (Apr 2026)", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=2026&month=4&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-35-cell.png",
    );
  });

  test("42-cell grid (Jul 2023)", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=2023&month=7&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-42-cell.png",
    );
  });

  test("non-selectable", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=false`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-non-selectable.png",
    );
  });

  test("selectable", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-selectable.png",
    );
  });

  test("other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-other-months.png",
    );
  });

  test("selectable with other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-selectable-other-months.png",
    );
  });

  test("month view (days-of-month grid)", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?view=month&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-view-month.png",
    );
  });

  test("year view (months-of-year grid)", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?view=year&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-view-year.png",
    );
  });

  test("decade view (years-of-decade grid)", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?view=decade&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-view-decade.png",
    );
  });
});
