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
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "stimulus-month.png",
    );
  });

  test("28-cell grid (Feb 2026, no padding rows)", async ({ page }) => {
    await page.goto("/components/calendar_stimulus?year=2026&month=2");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "stimulus-28-cell.png",
    );
  });

  test("35-cell grid (Apr 2026)", async ({ page }) => {
    await page.goto("/components/calendar_stimulus?year=2026&month=4");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "stimulus-35-cell.png",
    );
  });

  test("42-cell grid (Jul 2023)", async ({ page }) => {
    await page.goto("/components/calendar_stimulus?year=2023&month=7");
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "stimulus-42-cell.png",
    );
  });
});

// ── Stimulus calendar drill-down ─────────────────────────────────────────────

test.describe("stimulus calendar drill-down", () => {
  test("month picker view", async ({ page }) => {
    await page.goto(
      `/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`,
    );
    await page.waitForSelector("[role='grid']");
    await page.waitForSelector("[data-combobox-date-target='monthGrid']", { state: "attached" });
    await page.locator("[data-combobox-date-target='viewSwitch']").dispatchEvent("click");
    await page.waitForFunction(
      () => !document.querySelector("[data-combobox-date-target='monthGrid']")?.hidden,
    );
    await expect(page.locator("[data-combobox-date-target='monthGrid']")).toHaveScreenshot(
      "stimulus-month-picker.png",
    );
  });

  test("year picker view", async ({ page }) => {
    await page.goto(
      `/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`,
    );
    await page.waitForSelector("[role='grid']");
    await page.waitForSelector("[data-combobox-date-target='yearGrid']", { state: "attached" });
    await page.locator("[data-combobox-date-target='viewSwitch']").dispatchEvent("click");
    await page.locator("[data-combobox-date-target='viewSwitch']").dispatchEvent("click");
    await page.waitForFunction(
      () => !document.querySelector("[data-combobox-date-target='yearGrid']")?.hidden,
    );
    await expect(page.locator("[data-combobox-date-target='yearGrid']")).toHaveScreenshot(
      "stimulus-year-picker.png",
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
    await expect(page.locator("#calendar")).toHaveScreenshot("turbo-month.png");
  });

  test("selectable", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "turbo-selectable.png",
    );
  });

  test("other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "turbo-other-months.png",
    );
  });

  test("selectable with other months visible", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&show_other_months=true`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "turbo-selectable-other-months.png",
    );
  });
});

// ── Turbo calendar drill-down ────────────────────────────────────────────────

test.describe("turbo calendar drill-down", () => {
  test("month view", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?view=month&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "turbo-drill-month.png",
    );
  });

  test("year view", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?view=year&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "turbo-drill-year.png",
    );
  });

  test("decade view", async ({ page }) => {
    await page.goto(
      `/components/calendar_turbo?view=decade&year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#calendar")).toHaveScreenshot(
      "turbo-drill-decade.png",
    );
  });
});

// ── SSR month/year picker (standalone) ───────────────────────────────────────

test.describe("SSR month picker", () => {
  test("month grid", async ({ page }) => {
    await page.goto(
      `/components/calendar_month_picker?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#month-picker")).toHaveScreenshot(
      "ssr-month-picker.png",
    );
  });
});

test.describe("SSR year picker", () => {
  test("year grid", async ({ page }) => {
    await page.goto(
      `/components/calendar_year_picker?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`,
    );
    await page.waitForSelector("[role='grid']");
    await expect(page.locator("#year-picker")).toHaveScreenshot(
      "ssr-year-picker.png",
    );
  });
});
