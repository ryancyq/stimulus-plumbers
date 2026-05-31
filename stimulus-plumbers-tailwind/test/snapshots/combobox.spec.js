import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/combobox");
  await page.waitForSelector("input[aria-label='Birthday']");
});

test.describe("combobox", () => {
  test("all pickers — closed", async ({ page }) => {
    await expect(page.locator("#combobox")).toHaveScreenshot("all-closed.png");
  });

  test("date picker — open", async ({ page }) => {
    const trigger = page.getByRole("combobox", { name: "Birthday" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-date")).toHaveScreenshot("date-picker-open.png");
  });

  test("time picker — open", async ({ page }) => {
    const trigger = page.getByRole("combobox", { name: "Meeting Time" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-time")).toHaveScreenshot("time-picker-open.png");
  });

  test("dropdown — open", async ({ page }) => {
    const trigger = page.getByRole("combobox", { name: "Country" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-dropdown")).toHaveScreenshot("dropdown-open.png");
  });

  test("typeahead — open", async ({ page }) => {
    const trigger = page.getByRole("combobox", { name: "City" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot("typeahead-open.png");
  });

  test("typeahead — loading", async ({ page }) => {
    const trigger = page.getByRole("combobox", { name: "City" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");

    const comboboxRoot = page.locator('[data-controller~="input-combobox"]').filter({ has: trigger });
    const loading = comboboxRoot.locator('[data-combobox-dropdown-target="loading"]');
    await loading.evaluate((el) => el.removeAttribute("hidden"));

    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot("typeahead-loading.png");
  });

  test("typeahead — empty", async ({ page }) => {
    const trigger = page.getByRole("combobox", { name: "City" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");

    const comboboxRoot = page.locator('[data-controller~="input-combobox"]').filter({ has: trigger });
    const empty = comboboxRoot.locator('[data-combobox-dropdown-target="empty"]');
    await empty.evaluate((el) => el.removeAttribute("hidden"));

    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot("typeahead-empty.png");
  });
});
