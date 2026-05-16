import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
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
