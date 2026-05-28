import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover");
  await page.waitForSelector("[data-controller='popover']");
});

test("popover — closed state", async ({ page }) => {
  await expect(page).toHaveScreenshot("closed.png");
});

test("popover — open state", async ({ page }) => {
  const btn = page.getByRole("button", { name: "Open menu" });
  await btn.click();
  await expect(btn).toHaveAttribute("aria-expanded", "true");
  await expect(page).toHaveScreenshot("open.png");
});
