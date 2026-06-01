import { test, expect } from "@playwright/test";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/profile");
  await page.waitForSelector("[data-controller]");
});

test.describe("profile", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#profile")).toHaveScreenshot("default.png");
  });

  test("popover — open", async ({ page }) => {
    const btn = page.getByRole("button", { name: "More options" });
    await btn.click();
    await expect(btn).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#profile")).toHaveScreenshot("popover-open.png");
  });

  test.describe("date picker", () => {
    test("open", async ({ page }) => {
      const datePicker = page.getByRole("combobox", { name: "Date" });
      await datePicker.click();
      await expect(datePicker).toHaveAttribute("aria-expanded", "true");
      await expect(page.locator("#profile")).toHaveScreenshot(
        "datepicker-open.png",
      );
    });

    test("previous month", async ({ page }) => {
      const datePicker = page.getByRole("combobox", { name: "Date" });
      await datePicker.click();
      await expect(datePicker).toHaveAttribute("aria-expanded", "true");
      await page.getByRole("button", { name: "Previous Month" }).click();
      await expect(page.locator("#profile")).toHaveScreenshot(
        "datepicker-prev-month.png",
      );
    });

    test("next month", async ({ page }) => {
      const datePicker = page.getByRole("combobox", { name: "Date" });
      await datePicker.click();
      await expect(datePicker).toHaveAttribute("aria-expanded", "true");
      await page.getByRole("button", { name: "Next Month" }).click();
      await expect(page.locator("#profile")).toHaveScreenshot(
        "datepicker-next-month.png",
      );
    });
  });
});
