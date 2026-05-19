import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/combobox");
  await page.waitForSelector("input[aria-label='Birthday']");
});

test("all pickers closed", async ({ page }) => {
  await expect(page).toHaveScreenshot("all-closed.png");
});

test("date picker open", async ({ page }) => {
  const trigger = page.getByRole("combobox", { name: "Birthday" });
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("date-picker-open.png");
});

test("time picker open", async ({ page }) => {
  const trigger = page.getByRole("combobox", { name: "Meeting Time" });
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("time-picker-open.png");
});

test("dropdown open", async ({ page }) => {
  const trigger = page.getByRole("combobox", { name: "Country" });
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("dropdown-open.png");
});

test("autocomplete open", async ({ page }) => {
  const trigger = page.getByRole("combobox", { name: "City" });
  await trigger.click();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("autocomplete-open.png");
});
