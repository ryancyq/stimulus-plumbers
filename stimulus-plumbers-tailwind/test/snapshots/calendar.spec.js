import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");
const FIXED_YEAR = 2024;
const FIXED_MONTH = 2;
const FIXED_DAY = 29;

test("calendar stimulus — current month grid", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(`/components/calendar_stimulus?year=${FIXED_YEAR}&month=${FIXED_MONTH}`);
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("stimulus-month.png");
});

test("calendar turbo — current month grid", async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto(
    `/components/calendar_turbo?year=${FIXED_YEAR}&month=${FIXED_MONTH}&today_year=${FIXED_YEAR}&today_month=${FIXED_MONTH}&today_day=${FIXED_DAY}`
  );
  await page.waitForSelector("[role='grid']");
  await expect(page).toHaveScreenshot("turbo-month.png");
});
