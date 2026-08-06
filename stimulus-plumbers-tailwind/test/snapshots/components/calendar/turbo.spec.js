import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");
const FIXED_YEAR = 2024;
const FIXED_MONTH = 2;
const FIXED_DAY = 29;

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
});

test.describe("turbo calendar", () => {
  test("current month grid", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-month.png",
    );
  });

  test("28-cell grid (Feb 2026, no padding rows)", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=2026&month=2&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-28-cell.png",
    );
  });

  test("42-cell grid (Jul 2023)", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=2023&month=7&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-42-cell.png",
    );
  });

  test("selectable", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-selectable.png",
    );
  });

  test("other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-other-months.png",
    );
  });

  test("selectable with other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-selectable-other-months.png",
    );
  });

  test("selected date", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&selected_date=2024-02-15`,
    );
    await page.waitForSelector("#calendar-turbo [role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-selected.png",
    );
  });

  test("date range", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=2026&month=4&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&since=2026-03-30&till=2026-04-20`,
    );
    await page.waitForSelector("#calendar-turbo [role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-range.png",
    );
  });

  test("date range (selectable)", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=2026&month=4&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&since=2026-03-30&till=2026-04-20`,
    );
    await page.waitForSelector("#calendar-turbo [role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-range-selectable.png",
    );
  });

  test("date range with other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?year=2026&month=4&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&since=2026-03-30&till=2026-04-20&show_other_months=true`,
    );
    await page.waitForSelector("#calendar-turbo [role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-range-other-months.png",
    );
  });

  test("month view (days-of-month grid)", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?view=month&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-view-month.png",
    );
  });

  test("year view (months-of-year grid)", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?view=year&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-view-year.png",
    );
  });

  test("decade view (years-of-decade grid)", async ({ page }) => {
    await page.goto(
      `/components/calendar/turbo?view=decade&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar-turbo")).toHaveScreenshot(
      "turbo-view-decade.png",
    );
  });
});
