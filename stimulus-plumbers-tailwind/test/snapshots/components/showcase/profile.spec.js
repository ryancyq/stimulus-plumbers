import { test, expect } from "@playwright/test";
import { settled } from "../../../support/playwright.js";

const FIXED_DATE = new Date("2024-02-29T12:00:00Z");

test.beforeEach(async ({ page }) => {
  await page.clock.setFixedTime(FIXED_DATE);
  await page.goto("/components/showcase/profile");
  await page.waitForSelector("[data-controller]");
});

test.describe("profile", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#profile-default")).toHaveScreenshot(
      "default.png",
    );
  });

  test("popover — open", async ({ page }) => {
    const btn = page
      .locator("#profile-default")
      .getByRole("button", { name: "More options" });
    await btn.click();
    await expect(
      page.getByRole("dialog", { name: "More options" }),
    ).toBeVisible();
    await expect(page.locator("#profile-default")).toHaveScreenshot(
      "popover-open.png",
    );
  });

  // The section can outgrow a phone viewport, so these capture the viewport.
  test.describe("date combobox", () => {
    const open = async (page) => {
      const input = page
        .locator("#profile-default")
        .getByRole("combobox", { name: "Date" });
      await input.click();
      const panel = page.locator("#profile-default :popover-open");
      await expect(panel).toBeVisible();
      await settled(panel);
    };

    test("open", async ({ page }) => {
      await open(page);
      await expect(page).toHaveScreenshot("date-open.png");
    });

    test("previous month", async ({ page }) => {
      await open(page);
      await page
        .locator("#profile-default")
        .getByRole("button", { name: "Previous month" })
        .click();
      await expect(
        page
          .locator("#profile-default")
          .getByRole("heading", { name: "January 2024" }),
      ).toBeVisible();
      await expect(page).toHaveScreenshot("date-previous-month.png");
    });

    test("next month", async ({ page }) => {
      await open(page);
      await page
        .locator("#profile-default")
        .getByRole("button", { name: "Next month" })
        .click();
      await expect(
        page
          .locator("#profile-default")
          .getByRole("heading", { name: "March 2024" }),
      ).toBeVisible();
      await expect(page).toHaveScreenshot("date-next-month.png");
    });
  });
});
