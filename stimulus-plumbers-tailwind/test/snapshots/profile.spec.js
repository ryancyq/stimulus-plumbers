import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/profile");
  await page.waitForSelector("[data-controller]");
});

test("profile page — default state", async ({ page }) => {
  await expect(page).toHaveScreenshot("default.png");
});

test("profile page — popover open", async ({ page }) => {
  const btn = page.getByRole("button", { name: "More options" });
  await btn.click();
  await expect(btn).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("popover-open.png");
});

test("profile page — date picker open", async ({ page }) => {
  await page.getByLabel("Date").click();
  await expect(page.getByLabel("Date")).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("datepicker-open.png");
});

test("profile page — date picker previous month", async ({ page }) => {
  await page.getByLabel("Date").click();
  await page.getByRole("button", { name: "Previous Month" }).click();
  await expect(page).toHaveScreenshot("datepicker-prev-month.png");
});

test("profile page — date picker next month", async ({ page }) => {
  await page.getByLabel("Date").click();
  await page.getByRole("button", { name: "Next Month" }).click();
  await expect(page).toHaveScreenshot("datepicker-next-month.png");
});
