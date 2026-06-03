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
    const trigger = page.locator("#combobox-date").getByRole("combobox", { name: "Birthday" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-date")).toHaveScreenshot(
      "date-picker-open.png",
    );
  });

  test("time picker — open", async ({ page }) => {
    const trigger = page.locator("#combobox-time").getByRole("combobox", { name: "Meeting Time" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-time")).toHaveScreenshot(
      "time-picker-open.png",
    );
  });

  test("dropdown — open", async ({ page }) => {
    const trigger = page.locator("#combobox-dropdown").getByRole("combobox", { name: "Country" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-dropdown")).toHaveScreenshot(
      "dropdown-open.png",
    );
  });

  test("typeahead — open", async ({ page }) => {
    const trigger = page.locator("#combobox-typeahead").getByRole("combobox", { name: "City" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot(
      "typeahead-open.png",
    );
  });

  test("typeahead — loading", async ({ page }) => {
    const trigger = page.locator("#combobox-typeahead").getByRole("combobox", { name: "City" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");

    const loading = page.locator(
      "#combobox-typeahead [data-combobox-dropdown-target='loading']",
    );
    await loading.evaluate((el) => el.removeAttribute("hidden"));

    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot(
      "typeahead-loading.png",
    );
  });

  test("typeahead — empty", async ({ page }) => {
    const trigger = page.locator("#combobox-typeahead").getByRole("combobox", { name: "City" });
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");

    const empty = page.locator(
      "#combobox-typeahead [data-combobox-dropdown-target='empty']",
    );
    await empty.evaluate((el) => el.removeAttribute("hidden"));

    await expect(page.locator("#combobox-typeahead")).toHaveScreenshot(
      "typeahead-empty.png",
    );
  });

  test("date picker error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-date-error")).toHaveScreenshot(
      "date-picker-error-closed.png",
    );
  });

  test("date picker error — open", async ({ page }) => {
    const trigger = page.locator("#combobox-date-error input[role='combobox']");
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-date-error")).toHaveScreenshot(
      "date-picker-error-open.png",
    );
  });

  test("time picker error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-time-error")).toHaveScreenshot(
      "time-picker-error-closed.png",
    );
  });

  test("time picker error — open", async ({ page }) => {
    const trigger = page.locator("#combobox-time-error input[role='combobox']");
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-time-error")).toHaveScreenshot(
      "time-picker-error-open.png",
    );
  });

  test("dropdown error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-dropdown-error")).toHaveScreenshot(
      "dropdown-error-closed.png",
    );
  });

  test("dropdown error — open", async ({ page }) => {
    const trigger = page.locator(
      "#combobox-dropdown-error input[role='combobox']",
    );
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#combobox-dropdown-error")).toHaveScreenshot(
      "dropdown-error-open.png",
    );
  });

  test("typeahead error — closed", async ({ page }) => {
    await expect(page.locator("#combobox-typeahead-error")).toHaveScreenshot(
      "typeahead-error-closed.png",
    );
  });
});
