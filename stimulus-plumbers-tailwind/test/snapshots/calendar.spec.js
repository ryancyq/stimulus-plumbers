import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");
const FIXED_YEAR = 2024;
const FIXED_MONTH = 2;
const FIXED_DAY = 29;

// ── Stimulus calendar ────────────────────────────────────────────────────────

test("calendar stimulus — current month grid", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(`/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`);
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("stimulus-month.png");
});

test("calendar stimulus — 28-cell grid (Feb 2026, no padding rows)", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/calendar_stimulus?year=2026&month=2");
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("stimulus-28-cell.png");
});

test("calendar stimulus — 35-cell grid (Apr 2026)", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/calendar_stimulus?year=2026&month=4");
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("stimulus-35-cell.png");
});

test("calendar stimulus — 42-cell grid (Jul 2023)", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/calendar_stimulus?year=2023&month=7");
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("stimulus-42-cell.png");
});

// ── Turbo calendar ───────────────────────────────────────────────────────────

test("calendar turbo — current month grid", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(
    `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`
  );
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("turbo-month.png");
});

test("calendar turbo — selectable", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(
    `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true`
  );
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("turbo-selectable.png");
});

test("calendar turbo — other months visible", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(
    `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&show_other_months=true`
  );
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("turbo-other-months.png");
});

test("calendar turbo — selectable with other months visible", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(
    `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}&selectable=true&show_other_months=true`
  );
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("turbo-selectable-other-months.png");
});
