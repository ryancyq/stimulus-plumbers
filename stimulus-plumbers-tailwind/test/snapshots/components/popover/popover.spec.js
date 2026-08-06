import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/popover");
  await page.waitForSelector("[data-controller='popover']");
});

test.describe("popover", () => {
  test("closed", async ({ page }) => {
    await expect(page.locator("#popover-default")).toHaveScreenshot(
      "closed.png",
    );
  });

  test("open", async ({ page }) => {
    const btn = page.getByRole("button", { name: "Open menu" });
    await btn.click();
    await expect(btn).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator("#popover-default")).toHaveScreenshot("open.png");
  });
});
